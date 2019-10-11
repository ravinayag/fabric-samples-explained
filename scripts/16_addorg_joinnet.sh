echo "bringing up the org3 containers"
docker-compose -f docker-compose-org3.yaml up -d
sleep 20
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CHANNEL_NAME=mychannel2
sleep 20
echo "joining to channel"
docker exec Org3cli peer channel fetch 0 mychannel2.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

docker exec Org3cli peer channel join -b mychannel2.block

