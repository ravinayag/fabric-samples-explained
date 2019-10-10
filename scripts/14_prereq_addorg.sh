cd org3-artifacts
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
echo $PWD
pwd
sleep 10
#echo "execute this script from org3-artifacts folder"

cryptogen generate --config=./org3-crypto.yaml
sleep 30
export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
sleep  10

cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
ls org3-artifacts
sleep 10
ls org3-artifacts/crypto-config/
#sudo apt-get -y update && sudo apt-get -y install jq


