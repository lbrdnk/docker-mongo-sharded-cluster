#!/bin/bash

echo "start: Starting shard instance."
/usr/bin/mongod --port 17018 --dbpath /data/dbshard --shardsvr --replSet rs-shard --bind_ip_all &
sleep 5
echo "start: Done starting shard instance."

echo "start: Starting cfg instance."
/usr/bin/mongod --port 17019 --dbpath /data/dbcfg --configsvr --replSet rs-cfg --bind_ip_all &
sleep 5
echo "start: Done starting cfg instance."

echo "start: Starting rotuer instance."
/usr/bin/mongos --port 17017 --configdb rs-cfg/localhost:17019 --bind_ip_all &
sleep 5
echo "start: Done starting router instance."

echo "start: Initialize replica set on config and shard instance."
mongosh --host localhost:17019 --eval '
    rs.initiate({
    _id: "rs-cfg",
    configsvr: true, 
    members: [
        { _id: 0, host: "localhost:17019" }
    ]
})'
mongosh --host localhost:17018 --eval '
    rs.initiate({
    _id: "rs-shard",
    members: [
        { _id: 0, host: "localhost:17018" }
    ]
})'
sleep 5
echo "start: Done initializing replica set on config and shard instance."

echo "start: Add shard on router instance."
echo $(mongosh --host localhost:17017 --eval '
    sh.addShard("rs-shard/localhost:17018")
')
echo "start: Done Adding shard on router instance."

echo "start: Done."

wait