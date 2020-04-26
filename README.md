# Fabric-Samples-Explained - First Network

# For Learning Basic Hyperlerger fabric and how it functions.

Audience:  Newcommers - To learn Hyplerledger fabric with default samples. forked from fabric-sample 1.4.3

Forked from [Fabric-samples](https://github.com/hyperledger/fabric-samples) first-network
Ensure all prerequesties are completed, if not refer this [Download_script](https://github.com/ravinayag/Hyperledger/blob/master/download_hlf.sh) 
and [prereq_script](https://github.com/ravinayag/Hyperledger/blob/master/prereqs_hlfv14.sh)

Note : The Recent Fabric samples masters, chaincode_example02 is not availble, Hence i update this folder here. you have to copy this folder under fabric-samples/chaincode folder.

Here is the Network Diagram for the fabric ![Networkdiag](network.png)

Ensure all prerequesties are completed,if not refer this 
* 1, Phy/Virtual Machine : Running Ubuntu OS 16.4 LTS
* 2, [Pre_req_script](https://github.com/ravinayag/Hyperledger/raw/master/prereqs_hlfv14.sh) for ref. (Installs : Docker, Docker-composer,Npm, node, python, ca-certs and sudo access.)
* 3, [Download_script](https://github.com/ravinayag/Hyperledger/raw/master/download_hlf.sh) for ref. (Installs : Fabric-samples, binaries, docker images )

*Note 1: This Will download Fabric-samples binaries in current folder and docker images.
I have run this script from my homefolder ex: /home/ravinayag and Fabric-samples folder will be created here.*

*Note 2 : The Recent Fabric samples masters(>1.4.3), chaincode_example02 is not availble. Hence i update this folder here. you have to copy this folder under fabric-samples/chaincode folder.*

#### * Explainer Video @ [YouTube - Part1 ](https://www.youtube.com/watch?v=HtAT1hSaVN0&t=25s)  & [YouTube - Part2 ](https://www.youtube.com/watch?v=PHImeydK1p0&t=18s) 

#### Check List for prereq readiness :
* 1, Docker, Docker-composer,Npm, node, python, ca-certs and sudo access.
* 2, Fabric-samples, binaries, docker images 

##### Do not proceed further if above pre req not completed. If you have issues, Please raise your hands over hyperledger chat or weekly call

#### Lets begin to dirt our hands.

###  1, Clone/download this repo and name it as "newnet" under fabric-samples folder and move as your working directory.

 
```
~newnet$ mv
yourhomepath/fabric-samples/fabric-samples-explaind yourhomepath/fabric-samples/newnet


set bin path 
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
 
```

## Stage -1 
#### 3, Now set the environment variables by running script which generates genisis block and run the docker contiainer

```
 $  source ./scripts/1_envsetup.sh
```
#### OR 

TechTip1 : Your Syschannel name should be different  from the public channel name. Syschannel name is used to create Genesis block. 
```

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

export SYS_CHANNEL=syschannel
export CHANNEL_NAME=mychannel2
export IMAGE_TAG=latest
export COMPOSE_PROJECT_NAME=newnet


```

####  1a,  Run the this script to genrate the artifacts given in crypto-config file and generate genesis block
Note: This script has to execute first time only or fresh install, If clone you no need to run unless you delete manually crypto-config & channel-artifacts folder
```
 $  ./scripts/1a_firsttimeonly.sh
```
#### OR 
```
### Generate artifacts
rm -rf crypto-config channel-artifacts
cryptogen generate --config=./crypto-config.yaml

### Create Sys channel for genesis block
mkdir channel-artifacts
configtxgen -profile TwoOrgsOrdererGenesis -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block

### create channel.tx file

configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

### create Anchor peer file for Org
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
```

####  Now you can Run the docker-compose  to get the network containers up
```
$ docker-compose -f docker-compose-cli.yaml up -d
$ docker ps -a   ## this will show you all  6 containers up and running. ( orderer, 2 peers on each org's (2 org) and cli)
Note : If you have errors at this stage(dockers not up), then delete crypto-config folder and run script/1a_firsttimeonly.sh file

```

####  2,  Create channel with script

```
 $  ./scripts/2_chanlCrt.sh
```
#### OR 
```
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CHANNEL_NAME=mychannel2
export CORE_PEER_TLS_ENABLED=true

docker exec cli peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_TLS_ENABLED --cafile $ORDERER_CA
```




#### 2a, Now join the peers to the channel one by one 


```
######### First peer0 of Org1 ########

newnet $ docker exec cli sh ./scripts/2a_peer0.org1_chljoin.sh
```
OR 

```
$ docker exec -it cli bash   ### you get the root prompt for  cli contianer and execute all commands from here.

set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org1MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CHANNEL_NAME=mychannel2
peer channel join -b $CHANNEL_NAME.block
```


#### 3, Now join the second peer of org1 to the channel  
######### Second, peer1 of Org1 ########
```
newnet$ docker exec cli sh ./scripts/3_peer1.org1_chljoin.sh

OR 


$ docker exec -it cli bash   ### you get the root prompt for contianer
set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org1MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer1.org1.example.com:8051
CHANNEL_NAME=mychannel2
peer channel join -b $CHANNEL_NAME.block
```

#### 4, Now join the first peer of org2 to the channel  
######### First peer of Org2 ##########
```
$ docker exec cli sh ./scripts/4_peer0.org2_chljoin.sh
```
OR
```
set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org2MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer0.org2.example.com:9051
CHANNEL_NAME=mychannel2
peer channel join -b $CHANNEL_NAME.block
```

#### 5, Now join the seond peer of org2 to the channel  
######### Second peer of Org2 ##########
```
$ docker exec cli sh ./scripts/5_peer1.org2_chljoin.sh
```
OR
```
set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org2MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer1.org2.example.com:10051
CHANNEL_NAME=mychannel2
peer channel join -b $CHANNEL_NAME.block
```
####  6, Update anchor PEER channel for orgs, so the second peers will interact with peer0(anchor peer0) for transactions and only peer0 is exposed to the world.
```
$ docker exec cli sh ./scripts/6_anchorpeerorg1.sh

OR 

$ docker exec -it cli bash   ### you get the root prompt for contianer
set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org1MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
```
#### 7, Now update anchor peer for org2 to the channel  
######### Repeat same from the second org - Org2 ##########

```
$ docker exec cli sh ./scripts/7_anchorpeerorg2.sh

```
OR 
```
set -x
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org2MSP
CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ID=cli
CORE_PEER_ADDRESS=peer0.org2.example.com:9051
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CHANNEL_NAME=mychannel2
peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
```
############################################################################################
#### Now the Network is ready and docker Containers up and communicating with Channel  
############################################################################################

#####################
##### Stage 2 #######
#####################

Now your network is up and running,  you have to deploy chaincode/smartcontracts over the network
your network consists of one orderer and 4 peers ( 2 from each org.)
we have one cli container to execute our binaries.

Lets install the chaincode on peer0.org1 export the variables first.
### Chaincode install/instantiate
```
newnet$ docker exec cli sh ./scripts/8_ccinstallpeer0.org1.sh
```
OR
```
$ docker exec -it cli bash   ### you get the root prompt for contianer

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
```
###### Do it same for Org2
Install chaincode on peer0.org2...
```
newnet$ docker exec cli sh ./scripts/9_ccinstallpeer0.org2.sh
```
OR 
```
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
```
Installing chaincode on peer1.org2...
```
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer1.org2.example.com:10051
peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
```

We have installed our chaincode/smartcontracts to peers, Now instantiate the chaincode/smartcontract to the network (channnel)
you can run the script or below with variables
```
newnet$ docker exec cli sh ./scripts/10_ccinstantiate.org2.sh
```
OR 

```
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel2 -n mycc -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P 'AND ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
```
Lets quickly go through the smart contact. you can refer the file under chaincode_example02/go/chaincode_example02.go. Where it declares the variables and functions with arithametic operations.
So we defined the variable for A = 10 and  B = 200, and endorsing peers are from Org1 and Org2 compulsory you can also appy "OR" which means that the endorsing peers from any of these Org's.


After instantiate the chaincode, you can do query the assets to confirm its been registerd in ledger. you will get the value of "A" is 100. 

Tips : The ledgers are stored in /var/hyperledger/production/ on each peer.

Querying chaincode on peer0.org1...


```
newnet$ docker exec cli sh ./scripts/11_ccquery.org1.sh
```
OR

```
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
peer chaincode query -C mychannel2 -n mycc -c '{"Args":["query","a"]}'
```

Im transferring the some value from A to B 
Lets invoke the transaction from "A" to "B"   and do query from pee1.org2 for transaction status


```
newnet$ docker exec cli sh ./scripts/12_ccinvoketransfer.sh
```
OR
 

Sending invoke transaction on peer0.org2...
```

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA  -C mychannel2 -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA  --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA -c '{"Args":["invoke","a","b","10"]}'

 ```

 Query from  Peer1.org2 and you should get value of "a" is 90.


```
newnet$ docker exec cli sh ./scripts/13_ccquery.org2.sh
```
OR

Querying chaincode on peer1.org2...
```
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=peer1.org2.example.com:10051
===================== Querying on peer1.org2 on channel 'mychannel2'... =====================
Attempting to Query peer1.org2 ...3 secs
peer chaincode query -C mychannel2 -n mycc -c '{"Args":["query","a"]}'
```

############################################################################################
#### Now the BYFN is tested with smartcontract transactions, 
#### Let's see how the new Org can join the exsisting network and read the transactions.
############################################################################################

#####################
##### Stage 3 #######
#####################

## Now add the new organizations (org3) to exsisting network

Copy files from first-network folder

#### 1, Directory  of org3-artifacts and file docker-compose-org3.yaml	
```
newnet$ cp -r ../first-network/org3-artifacts .  && cp ../first-network/docker-compose-org3.yaml .
```
Change dir to /yourhomepath/fabric-samples/newnet/org3-artifacts

#### 2,  Doing pre requesties for Org3
```
newnet$ ./scripts/14_prereq_addorg.sh
```
OR
```
 export PATH=${PWD}/../bin:${PWD}:$PATH
 export FABRIC_CFG_PATH=${PWD}

$ cryptogen generate --config=./org3-crypto.yaml    ### Note :  First time only.

$ export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
Note : If you have errors at this stage, then delete crypto-config folder and generate certs by cryptogen 

$ cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
$ sudo apt-get -y update && sudo apt-get -y install jq    ### Note :  First time only.
 
```
#### 3,  Gathering the Channel configurations and updating with new org to existing channel
```
newnet$ docker exec cli sh ./scripts/15_addorg_netup.sh
```
OR 
```
$ docker exec -it cli bash

## Update the environment settings
$ export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
$ export CHANNEL_NAME=mychannel2
$ peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

##Convert the Configuration to JSON  and add the new org 
$ configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
$ jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json

## Translate config.json back into a protobuf  and Encode modified_config.json to modified_config.pb
$ configtxlator proto_encode --input config.json --type common.Config --output config.pb
$ configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

## Identify the difference  between  protobuf and decode to readable json format.
$ configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb
$ configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

## Wrap in an envelope message and encode to protobuf
$ echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel2", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json
$ configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

##sign and submit the config updates from the org1 and org2 
$ peer channel signconfigtx -f org3_update_in_envelope.pb   ### org1 signoff for adding org3

## Export the environment variables to sign as org2 
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA
```

#### 4, Lets the org3 container make up and get into org3cli to join the network channel 

```
~newnet$ ./scripts/16_addorg_joinnet.sh
```
OR

```
$ docker-compose -f docker-compose-org3.yaml up -d
$ docker exec -it Org3cli bash

##export variables and join the channel
$ export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
$ export CHANNEL_NAME=mychannel2
$ peer channel fetch 0 mychannel2.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
$ peer channel join -b mychannel2.block
```
##### 4.a  Do this for second peer1.org3 ( this is optional for demo requirement)
```
newnet$ docker exec Org3cli sh ./scripts/17_addorg_ccins_qry.sh
```
OR

```
$ docker exec -it Org3cli bash
$ export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt 
$ export CORE_PEER_ADDRESS=peer1.org3.example.com:12051
$ peer channel join -b mychannel2.block
```
#### 5, Install Chaincode. 
### Comeback to peer0.org3 and install chaincode
### Query from org3 node for the assets Do this step after chaincode has instantiated from Org2.
```
$ export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt 
export CORE_PEER_ADDRESS=peer0.org3.example.com:11051

peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/

peer chaincode query -C mychannel2 -n mycc -c '{"Args":["query","a"]}'

```

Hope this helps you to understand the BYFN / EYFN. Give thumbsup to motivate me. 
Thank you  !!!




#########################################################################################
#########################################################################################
