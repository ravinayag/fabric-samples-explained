echo " #####  Copy the Chaincode_exampl02 folder to path/to/fabric_samples/chaincode #####"
echo " #####  Note: Its important to take above step for install the chaincode contract ##### "

source scripts/1_envsetup.sh
## firsttime script ignored here
docker-compose -f docker-compose-cli.yaml up -d
docker ps
sleep 15
./scripts/2_chanlCrt.sh
sleep 3
docker exec cli sh ./scripts/2a_peer0.org1_chljoin.sh
sleep 1
docker exec cli sh ./scripts/3_peer1.org1_chljoin.sh
sleep 1
docker exec cli sh ./scripts/4_peer0.org2_chljoin.sh
sleep 1
docker exec cli sh ./scripts/5_peer1.org2_chljoin.sh
sleep 1

docker exec cli sh ./scripts/6_anchorpeerorg1.sh
sleep 2
docker exec cli sh ./scripts/7_anchorpeerorg2.sh
sleep 2

docker exec cli sh ./scripts/8_ccinstallpeer0.org1.sh
sleep 2
docker exec cli sh ./scripts/9_ccinstallpeer0.org2.sh
sleep 2
docker exec cli sh ./scripts/10_ccinstantiate.org2.sh
sleep 2
docker exec cli sh ./scripts/11_ccquery.org1.sh
sleep 1

docker exec cli sh ./scripts/12_ccinvoketransfer.sh
sleep 3
docker exec cli sh ./scripts/13_ccquery.org2.sh

echo "        ++++++++  Adding New Org now   +++++++++  "
sleep 10 

   
./scripts/14_prereq_addorg.sh
sleep 10 
docker exec cli sh ./scripts/15_addorg_netup.sh
sleep 15
./scripts/16_addorg_joinnet.sh
sleep 5
docker exec Org3cli sh ./scripts/17_addorg_ccins_qry.sh

echo " #####  Tested the first network -explained  #### "

