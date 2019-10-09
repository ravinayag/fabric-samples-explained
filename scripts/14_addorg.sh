export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

echo "execute this script from org3-artifacts folder"

cryptogen generate --config=./org3-crypto.yaml
export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
sudo apt-get -y update && sudo apt-get -y install jq


