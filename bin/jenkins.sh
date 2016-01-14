#! /bin/bash

set -e

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   # Install maintenance scripts
   rm -rf ${SCRIPTS_PATH}
   mkdir -p ${SCRIPTS_PATH}
   git clone ${SCRIPTS_GIT_REPO} ${SCRIPTS_PATH}/
   for directory in `find ${SCRIPTS_PATH} -type f -name package.json -exec dirname {} \;`; do cd ${directory} && npm install; done
 
   /usr/local/bin/plugins.sh /plugins.txt
   exec java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
