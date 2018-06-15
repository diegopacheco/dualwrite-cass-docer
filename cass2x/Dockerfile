FROM java:8-jdk
MAINTAINER Diego Pacheco - diego.pacheco.it@gmail.com

RUN apt-get update && apt-get install -y \
	autoconf \
	build-essential \
	dh-autoreconf \
	git \
	libssl-dev \
	libtool \
	python-software-properties \
	vim \
	unzip

# Install Java 8
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz"
RUN tar -xzvf jdk-8u161-linux-x64.tar.gz
RUN rm -rf jdk-8u161-linux-x64.tar.gz
RUN echo "alias cls='clear'\nexport JAVA_HOME=~/jdk1.8.0_161\nexport JRE_HOME=~/jdk1.8.0_161/jre\nexport PATH=$PATH:~/jdk1.8.0_161/bin:/~/jdk1.8.0_161/jre/bin" >> /etc/profile

# Install Cassandra 2.2
RUN wget https://archive.apache.org/dist/cassandra/2.2.12/apache-cassandra-2.2.12-bin.tar.gz
RUN tar -xzvf apache-cassandra-2.2.12-bin.tar.gz
RUN rm -rf apache-cassandra-2.2.12-bin.tar.gz
RUN mv apache-cassandra-2.2.12/ /cassandra/

# Configure the cluster
ADD start-cass.sh  /cassandra/
RUN chmod +x /cassandra/start-cass.sh
ADD cassandra-2.2.yaml /cassandra/conf/cassandra.yaml

EXPOSE 9160
EXPOSE 9042
EXPOSE 7199

CMD ["sh","-c","cd /cassandra/ && /cassandra/start-cass.sh"]
