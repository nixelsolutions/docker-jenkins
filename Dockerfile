FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

ENV DEBIAN_FRONTEND=noninteractive

# Install Java
RUN apt-get update && apt-get -y install add-apt-repository
RUN add-apt-repository ppa:openjdk-r/ppa && apt-get update && apt-get -y install openjdk-8-jdk
# Install packages
RUN apt-get update && apt-get install -y wget
# Install docker
RUN wget -qO- https://get.docker.com/ | sh

ENV JENKINS_VERSION 1.609.3
ENV JENKINS_SHA f5ad5f749c759da7e1a18b96be5db974f126b71e
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_PORT 8080

# Install Jenkins
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

EXPOSE ${JENKINS_PORT}

VOLUME ${JENKINS_HOME}

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
