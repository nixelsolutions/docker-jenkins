FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

ENV DEBIAN_FRONTEND=noninteractive

# Install Java
RUN apt-get update && \
    apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get -y install openjdk-8-jdk

# Install packages
RUN apt-get update && \
    apt-get install -y wget curl pwgen unzip dos2unix git

ENV JENKINS_VERSION 1.609.3
ENV JENKINS_SHA f5ad5f749c759da7e1a18b96be5db974f126b71e
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_PORT 8080

ENV JENKINS_WAR_PATH /usr/share/jenkins/jenkins.war
ENV JENKINS_DOWNLOAD http://mirrors.jenkins-ci.org/war-stable/${JENKINS_VERSION}/jenkins.war
ENV JENKINS_PLUGIN_DOWNLOAD https://updates.jenkins-ci.org/download/plugins

ENV JQ_VERSION 1.5
ENV JQ_DOWNLOAD https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64

ENV SCRIPTS_GIT_REPO https://github.com/nixelsolutions/scripts.git
ENV SCRIPTS_PATH ${JENKINS_HOME}/scripts
ENV AWS_LB_SCRIPT ${SCRIPTS_PATH}/aws/lb/get_aws_instances/get_aws_instances.js

ENV DOCKER_COMPOSE_VERSION 1.4.1

# Install docker
RUN wget -qO- https://get.docker.com/ | sh

# Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install Jenkins
RUN mkdir -p /usr/share/jenkins
RUN curl -fL ${JENKINS_DOWNLOAD} -o ${JENKINS_WAR_PATH} && echo "${JENKINS_SHA} ${JENKINS_WAR_PATH}" | sha1sum -c -

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# Install jq
RUN curl -sSL ${JQ_DOWNLOAD} > /usr/local/bin/jq

EXPOSE ${JENKINS_PORT}

VOLUME ${JENKINS_HOME}

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

# Install plugins
ADD plugins.txt /plugins.txt
RUN /usr/local/bin/plugins.sh /plugins.txt

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
