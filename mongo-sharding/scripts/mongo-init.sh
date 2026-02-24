#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 --quiet<<EOF
rs.initiate(
  {
    _id : "cfgrs",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF

docker compose exec -T shard1 mongosh --port 27018 --quiet<<EOF
rs.initiate(
    {
      _id : "shard1rs",
      members: [
        { _id : 0, host : "shard1:27018" }
      ]
    }
);
exit();
EOF

docker compose exec -T shard2 mongosh --port 27019 --quiet<<EOF
rs.initiate(
    {
      _id : "shard2rs",
      members: [
        { _id : 1, host : "shard2:27019" }
      ]
    }
  );
exit();
EOF

docker compose exec -T mongos_router mongosh --port 27020 --quiet<<EOF
sh.addShard( "shard1rs/shard1:27018");
sh.addShard( "shard2rs/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments()
exit();
EOF

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF