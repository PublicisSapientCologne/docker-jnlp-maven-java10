FROM ubuntu:bionic

USER root

ARG uid=10000
ARG gid=10000

ENV HOME /home/jenkins
RUN groupadd -g ${gid} jenkins
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m jenkins

ARG JENKINS_REMOTING_VERSION=3.19 
ARG AGENT_WORKDIR=/home/jenkins/agent

RUN apt-get update
RUN apt-get -y install default-jdk maven python curl nano

# See https://github.com/jenkinsci/docker-slave/blob/master/Dockerfile#L31
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN chmod a+rwx /home/jenkins
RUN chmod 775 /usr/local/bin/jenkins-slave

USER jenkins 
ENV AGENT_WORKDIR=${AGENT_WORKDIR} 
RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

WORKDIR /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
