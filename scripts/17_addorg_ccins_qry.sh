export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=peer0.org3.example.com:11051

peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
peer chaincode query -C mychannel2 -n mycc -c '{"Args":["query","a"]}'



export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=peer1.org3.example.com:12051

peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/

