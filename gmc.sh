#!/bin/bash
screen -S gmc gmc --etherbase '0x7be6f70c1a9903146c49685fb4811b18348bb91c' --rpc --rpcaddr "127.0.0.1" --rpcport 8101 --extradata 'mc.minecrypto.pro' console
screen -S gmc-backup gmc --etherbase '0x7be6f70c1a9903146c49685fb4811b18348bb91c' --rpc --rpcaddr "127.0.0.1" --rpcport 8103 --port 8104 --extradata 'mc.minecrypto.pro' --unlock '0x7be6f70c1a9903146c49685fb4811b18348bb91c' --password $WALLET_PASSWORD_FILE_PATH --datadir "/root/.musicoin-backup" console
