#!/bin/bash
set -u
set -e
NETID=87234
BOOTNODE_KEYHEX=77bd02ffa26e3fb8f324bda24ae588066f1873d95680104de5bc2db9e7b2e510
BOOTNODE_ENODE=enode://6433e8fb82c4638a8a6d499d40eb7d8158883219600bfd49acb968e3a37ccced04c964fa87b3a78a2da1b71dc1b90275f4d055720bb67fad4a118a56925125dc@[127.0.0.1]:33445

GLOBAL_ARGS="--bootnodes $BOOTNODE_ENODE --networkid $NETID "

echo "[*] Starting Constellation nodes"
nohup constellation-node tm1.conf 2>> qdata/logs/constellation1.log &
sleep 1
nohup constellation-node tm2.conf 2>> qdata/logs/constellation2.log &
nohup constellation-node tm3.conf 2>> qdata/logs/constellation3.log &
nohup constellation-node tm4.conf 2>> qdata/logs/constellation4.log &
nohup constellation-node tm5.conf 2>> qdata/logs/constellation5.log &
nohup constellation-node tm6.conf 2>> qdata/logs/constellation6.log &
nohup constellation-node tm7.conf 2>> qdata/logs/constellation7.log &

echo "[*] Starting bootnode"
nohup bootnode --nodekeyhex "$BOOTNODE_KEYHEX" --addr="127.0.0.1:33445" 2>>qdata/logs/bootnode.log &
echo "wait for bootnode to start..."
sleep 6

echo "[*] Starting node 1"
PRIVATE_CONFIG=tm1.conf nohup geth --datadir qdata/dd1 $GLOBAL_ARGS --port 21000 --networkid $NETID --rpcport 22000 --rpc --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &

echo "[*] Starting node 2"
PRIVATE_CONFIG=tm2.conf nohup geth --datadir qdata/dd2 $GLOBAL_ARGS --voteaccount "0x0fbdc686b912d7722dc86510934589e0aaf3b55a" --votepassword "" --blockmakeraccount "0xca843569e3427144cead5e4d5999a3d0ccf92b8e" --blockmakerpassword "" --port 21001 --singleblockmaker --minblocktime 2 --maxblocktime 5 2>>qdata/logs/2.log &

echo "[*] Starting node 3"
PRIVATE_CONFIG=tm3.conf nohup geth --datadir qdata/dd3 $GLOBAL_ARGS --port 21002 2>>qdata/logs/3.log &

echo "[*] Starting node 4"
PRIVATE_CONFIG=tm4.conf nohup geth --datadir qdata/dd4 $GLOBAL_ARGS --voteaccount "0x9186eb3d20cbd1f5f992a950d808c4495153abd5" --votepassword "" --port 21003 2>>qdata/logs/4.log &

echo "[*] Starting node 5"
PRIVATE_CONFIG=tm5.conf nohup geth --datadir qdata/dd5 $GLOBAL_ARGS --voteaccount "0x0638e1574728b6d862dd5d3a3e0942c3be47d996" --votepassword "" --port 21004 2>>qdata/logs/5.log &

echo "[*] Starting node 6"
PRIVATE_CONFIG=tm6.conf nohup geth --datadir qdata/dd6 $GLOBAL_ARGS --port 21005 2>>qdata/logs/6.log &

echo "[*] Starting node 7"
PRIVATE_CONFIG=tm7.conf nohup geth --datadir qdata/dd7 $GLOBAL_ARGS --port 21006 2>>qdata/logs/7.log &

sleep 5
echo "[*] Sending first transaction"
PRIVATE_CONFIG=tm1.conf geth --exec 'loadScript("script1.js")' attach ipc:qdata/dd1/geth.ipc

echo "All nodes configured. See 'qdata/logs' for logs, and run e.g. 'geth attach qdata/dd1/geth.ipc' to attach to the first Geth node"
