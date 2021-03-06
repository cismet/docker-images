#!/bin/bash

# Environment variables are no longer the recommended method for connecting to linked services. 
# Instead, you should use the link name (by default, the name of the linked service) as the hostname to connect to. 
# See the docker-compose.yml documentation for details.
# Environment variables will only be populated if you’re using the legacy version 1 Compose file format.
echo '###### CHECKING CIDS SERVER CONTAINER ######'
if test -z "${CIDS_SERVER_PORT_9986_TCP_ADDR}" -o -z "${CIDS_SERVER_PORT_9986_TCP_PORT}"; then
    echo -e "\e[31mERROR\e[39m: You must link this container with a CIDS-SERVER container first"
    export
    cat /etc/hosts
    exit 1
fi
echo '###### BUILD CIDS-SERVER-REST-LEGACY DISTRIBUTION ######'
mkdir -p ${CIDS_SERVER_REST_LEGACY_DIR}
cp ${CIDS_SERVER_REST_LEGACY_IMPORT_DIR}/pom.xml ${CIDS_SERVER_REST_LEGACY_DIR}/
cd ${CIDS_SERVER_REST_LEGACY_DIR}/
touch _cids-distribution
#sed -i -- "s#__CIDS_ACCOUNT_EXTENSION__#${CIDS_ACCOUNT_EXTENSION:-CidsReference}#g" pom.xml
#sed -i -- "s#__MAVEN_LIB_DIR__#${MAVEN_LIB_DIR:-/data/lib/m2/}#g" pom.xml
#sed -i -- "s#__DATA_DIR__#${DATA_DIR:-/data/}#g" pom.xml
mvn  -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -s ${DATA_DIR}/settings.xml -Dcids.generate-lib.checkSignature=false -Dcids.generate-lib.sign=false $* clean package ${UPDATE_SNAPSHOTS}
echo '###### START CIDS-SERVER-REST-LEGACY SERVER ######'
echo -e '\e[32mINFO\e[39m: connecting to cids-server at '${CIDS_SERVER_PORT_9986_TCP_ADDR:-localhost}':'${CIDS_SERVER_PORT_9986_TCP_PORT:-9986}
cp ${CIDS_SERVER_REST_LEGACY_IMPORT_DIR}/runtime.properties ${CIDS_SERVER_REST_LEGACY_DIR}/
sed -i -- "s/__CIDS_SERVER_HOST__/${CIDS_SERVER_PORT_9986_TCP_ADDR:-localhost}/g" ${CIDS_SERVER_REST_LEGACY_DIR}/runtime.properties
sed -i -- "s/__CIDS_SERVER_PORT__/${CIDS_SERVER_PORT_9986_TCP_PORT:-9986}/g" ${CIDS_SERVER_REST_LEGACY_DIR}/runtime.properties
cp ${CIDS_SERVER_REST_LEGACY_IMPORT_DIR}/log4j.properties ${CIDS_SERVER_REST_LEGACY_DIR}/
sed -i -- "s/__LOG4J_HOST__/${LOG4J_HOST:-localhost}/g" ${CIDS_SERVER_REST_LEGACY_DIR}/log4j.properties
sed -i -- "s/__LOG4J_PORT__/${LOG4J_PORT:-4445}/g" ${CIDS_SERVER_REST_LEGACY_DIR}/log4j.properties
/usr/bin/java -server -Xms64m -Xmx800m -Djava.security.policy=${DATA_DIR}/policy.file -Dlog4j.configuration=file:${CIDS_SERVER_REST_LEGACY_DIR}/log4j.properties -jar ${LIB_DIR}/starter${CIDS_ACCOUNT_EXTENSION}/${CIDS_SERVER_REST_LEGACY_STARTER:-cids-server-rest-legacy}-starter.jar @runtime.properties