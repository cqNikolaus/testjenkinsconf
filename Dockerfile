FROM jenkins/jenkins:latest

USER root

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY *.secrets /run/secrets/
COPY *.yaml /var/jenkins_home/casc_configs/

RUN apt-get update && apt-get -y install wget make gcc gawk bison python3 apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get -y install docker-ce docker-ce-cli && \
    wget http://ftp.gnu.org/gnu/glibc/glibc-2.37.tar.gz && tar zxvf glibc-2.37.tar.gz && \
    mkdir /usr/share/jenkins/tools && mkdir /usr/share/jenkins/tools/java && cd /usr/share/jenkins/tools/java && \
    wget https://download.java.net/java/jdk8u192/archive/b04/binaries/jdk-8u192-ea-bin-b04-linux-x64-01_aug_2018.tar.gz && \
    tar xzvf jdk-8u192-ea-bin-b04-linux-x64-01_aug_2018.tar.gz && mkdir /usr/share/jenkins/tools/maven && cd /usr/share/jenkins/tools/maven && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.4/apache-maven-3.5.4-bin.tar.gz && \
    tar xzvf apache-maven-3.5.4-bin.tar.gz && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.tar.gz && \
    tar xzvf apache-maven-3.6.3-bin.tar.gz && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.8.8/apache-maven-3.8.8-bin.tar.gz && \
    tar xzvf apache-maven-3.8.8-bin.tar.gz && \
    groupadd -f docker && usermod -aG docker jenkins && \
    jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --latest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc_configs
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER jenkins
