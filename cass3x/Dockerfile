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
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz" && \
	tar -xzvf jdk-8u171-linux-x64.tar.gz  && \
	rm -rf jdk-8u171-linux-x64.tar.gz && \
  echo "alias cls='clear'\nexport JAVA_HOME=~/jdk1.8.0_171\nexport JRE_HOME=~/jdk1.8.0_171/jre\nexport PATH=$PATH:~/jdk1.8.0_171/bin:/~/jdk1.8.0_171/jre/bin" >> /etc/profile

# Install Cassandra 3.9
WORKDIR /
RUN mkdir /cassandra/ && chmod 777 /cassandra/
RUN wget https://archive.apache.org/dist/cassandra/3.9/apache-cassandra-3.9-bin.tar.gz
RUN tar -xzvf apache-cassandra-3.9-bin.tar.gz
RUN rm -rf apache-cassandra-3.9-bin.tar.gz
RUN cp -rp /apache-cassandra-3.9/* /cassandra/
RUN rm -rf /apache-cassandra-3.9/

# Configure the cluster
ADD start-cass.sh  /cassandra/
RUN chmod +x /cassandra/start-cass.sh
ADD cassandra-3.9.yaml /cassandra/conf/cassandra.yaml
ADD cassandra-env.sh /cassandra/conf/cassandra-env.sh

EXPOSE 9160
EXPOSE 9042
EXPOSE 7199

CMD ["sh","-c","cd /cassandra/ && /cassandra/start-cass.sh"]
