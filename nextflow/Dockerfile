FROM centos:7
MAINTAINER Tim Dudgeon

RUN yum -y install epel-release && yum -y update &&\
 yum -y install gcc gcc-c++ make cppunit cppunit-devel popt popt-devel curl zip unzip\
 numpy python-configparser openbabel openbabel-devel python-openbabel python-pip\
 java-1.8.0-openjdk-headless.x86_64 &&\
 yum clean all 
 
ENV RBT_FILE rDock_2013.1_src 
ENV RBT_ROOT /$RBT_FILE
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$RBT_ROOT/lib
ENV PATH $PATH:$RBT_ROOT/bin
ENV JAVA_HOME /usr/lib/jvm/jre-openjdk/
  
# build rdock  
RUN curl -kL -O -J https://sourceforge.net/projects/rdock/files/$RBT_FILE.tar.gz &&\
 tar -xvzf $RBT_FILE.tar.gz &&\
 rm $RBT_FILE.tar.gz &&\
 cd $RBT_FILE/build/ &&\
 make linux-g++-64 &&\
 make clean
 
RUN useradd -m rdock
USER rdock
WORKDIR $RBT_ROOT 

# get nextflow
WORKDIR /home/rdock
RUN curl -fsSL get.nextflow.io | bash && chmod 755 nextflow
USER root
RUN mv nextflow /usr/local/bin
USER rdock
