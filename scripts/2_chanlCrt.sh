export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.le.com/msp/tlscacerts/tlsca.example.com-cert.pem
docker exec cli peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_TLS_ENABLED --cafile $ORDERER_CA

