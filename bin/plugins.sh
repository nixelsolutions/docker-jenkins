#! /bin/bash

# Parse a support-core plugin -style txt file as specification for jenkins plugins to be installed
# in the reference directory, so user can define a derived Docker image with just :
#
# FROM jenkins
# COPY plugins.txt /plugins.txt
# RUN /usr/local/bin/plugins.sh /plugins.txt
#
# plugins.txt should contain something like this:
# plugin1:version1
# plugin2:version2
#

set -e

REF=${JENKINS_HOME}/plugins
mkdir -p $REF

while read spec || [ -n "$spec" ]; do
    plugin=(${spec//:/ });
    [[ ${plugin[0]} =~ ^# ]] && continue
    [[ ${plugin[0]} =~ ^\s*$ ]] && continue
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"

    if [ -e $REF/${plugin[0]}.jpi -a -e $REF/${plugin[0]}/META-INF/MANIFEST.MF ]; then
      dos2unix $REF/${plugin[0]}/META-INF/MANIFEST.MF
      currentVersion=`grep "Plugin-Version:" $REF/${plugin[0]}/META-INF/MANIFEST.MF | awk '{print $2}'` 2>/dev/null
      if [ ! -z ${currentVersion} ]; then
        echo "Comparing version for plugin ${plugin[0]} - Installed version: ${currentVersion} and required version: ${plugin[1]}"
        dpkg --compare-versions ${currentVersion} ge ${plugin[1]} && continue
      fi
    fi

    if [ -d $REF/${plugin[0]} ]; then
      echo "Deleting old version of plugin ${plugin[0]}:${currentVersion} ..."
      rm -rf $REF/${plugin[0]}
    fi

    echo "Downloading ${plugin[0]}:${plugin[1]} from ${JENKINS_PLUGIN_DOWNLOAD}/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi"
    curl -sSL -f ${JENKINS_PLUGIN_DOWNLOAD}/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi -o $REF/${plugin[0]}.jpi
    unzip -qqt $REF/${plugin[0]}.jpi
done  < $1
