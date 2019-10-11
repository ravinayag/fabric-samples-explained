#cp first-network.json.org first-network.json.var
echo " move to exploerer directory and run tnis"

export HOMEPATH=$FABRIC_CFG_PATH
echo
sed "s|{HOMEPATH}|$HOMEPATH|g" app/platform/fabric/connection-profile/first-network.json.var >app/platform/fabric/connection-profile/first-network.json1


export ORG1_MSPKEY=$(cd $HOMEPATH/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore && ls *_sk) 

sed "s|{ORG1_MSPKEY}|$ORG1_MSPKEY|g" app/platform/fabric/connection-profile/first-network.json1 >app/platform/fabric/connection-profile/first-network.json

rm -rf wallet/*
