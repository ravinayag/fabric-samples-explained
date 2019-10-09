echo " Fetching the information from the channel and store to config_block.pb"

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CHANNEL_NAME=mychannel2
peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA


echo " Now converting the configuration to json and adding the new org"
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json

echo "Converting back to protobuf file"
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb
configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

echo "Wrap in an envelope message and encode to protobuf"

echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel2", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json
configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

echo "sign and submit the config updates from the org1 and org2"

peer channel signconfigtx -f org3_update_in_envelope.pb 

echo " Export the environment variables to sign as org2"

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

echo "bringing up the org3 containers"
docker-compose -f docker-compose-org3.yaml up -d
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
export CHANNEL_NAME=mychannel2

echo "joining to channel"
docker exec Org3cli peer channel fetch 0 mychannel2.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

docker exec Org3cli peer channel join -b mychannel2.block


export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt 
export CORE_PEER_ADDRESS=peer0.org3.example.com:11051

peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
peer chaincode query -C mychannel2 -n mycc -c '{"Args":["query","a"]}'

