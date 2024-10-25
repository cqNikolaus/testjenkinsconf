# we want to use the latest lts version of jenkins
# FROM jenkins/jenkins:lts-jdk11
# FROM jenkins/jenkins:lts-jdk17
# FROM jenkins/jenkins:2.452.1-lts-jdk17
FROM jenkins/jenkins:2.462.1-lts-jdk17

USER root

RUN apt-get update && apt-get -y install wget make gcc gawk bison python3
RUN apt-get update && apt-get -y install docker.io

RUN wget http://ftp.gnu.org/gnu/glibc/glibc-2.37.tar.gz && tar zxvf glibc-2.37.tar.gz 
# && mkdir build && cd build && ../configure --prefix=/opt/glibc-2.37 && make -j4 && make install

# ##### https://stackoverflow.com/questions/73110198/jenkins-error-buildind-docker-lib-x86-64-linux-gnu-libc-so-6-version-glibc

RUN apt-get update && \
    apt-get -y install apt-transport-https \
         ca-certificates curl gnupg2 \
         software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" && \
    apt-get update && \
    apt-get -y install docker-ce 


RUN groupadd -f docker && usermod -aG docker jenkins

RUN mkdir -p /var/jenkins_home/casc_configs && \
    chown -R jenkins:jenkins /var/jenkins_home/casc_configs

RUN git clone https://github.com/cqNikolaus/jenkins_automation /tmp/repo && \
    cp /tmp/repo/*.yaml /var/jenkins_home/casc_configs/ && \
    rm -rf /tmp/repo




# ##### https://docs.docker.com/engine/install/ubuntu/ #####

# RUN yum clean all && rm -rf /var/cache/yum/*
# RUN yum install -y yum-utils wget
# RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# RUN yum install -y --nogpgcheck docker-buildx-plugin docker-ce-19.03.9-3.el7 docker-ce-cli containerd.io docker-compose-plugin

# ##### END https://docs.docker.com/engine/install/ubuntu/ #####


# install java & maven
RUN mkdir /usr/share/jenkins/tools && mkdir /usr/share/jenkins/tools/java && cd /usr/share/jenkins/tools/java && \
    wget https://download.java.net/java/jdk8u192/archive/b04/binaries/jdk-8u192-ea-bin-b04-linux-x64-01_aug_2018.tar.gz && \
    tar xzvf jdk-8u192-ea-bin-b04-linux-x64-01_aug_2018.tar.gz && mkdir /usr/share/jenkins/tools/maven && cd /usr/share/jenkins/tools/maven && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.4/apache-maven-3.5.4-bin.tar.gz && \
    tar xzvf apache-maven-3.5.4-bin.tar.gz && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.tar.gz && \
    tar xzvf apache-maven-3.6.3-bin.tar.gz && \
    wget --no-check-certificate https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.8.8/apache-maven-3.8.8-bin.tar.gz && \
    tar xzvf apache-maven-3.8.8-bin.tar.gz

USER jenkins

# skip the setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"

# groovy files for initial run
# TODO fkt nicht mehr ...
# COPY locale.groovy /usr/share/jenkins/ref/init.groovy.d/

# copy generated secrets
COPY *.secrets /run/secrets/

# casc preparation
COPY *.yaml /var/jenkins_home/casc_configs/

ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc_configs

# install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --latest

