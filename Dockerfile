FROM amazonlinux AS build
ENV M2_HOME /opt/maven
RUN export PATH
RUN yum install wget -y && \
    yum install gzip -y && \
    yum install tar -y && \
    yum install git -y
RUN yum install java -y
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz && \
    tar zxf apache-maven-3.9.12-bin.tar.gz && \
    mv apache-maven-3.9.12 /opt/maven

RUN mkdir /root/.ssh

COPY ./id_rsa /root/.ssh/id_rsa

RUN chmod -R 700 /root/.ssh  && \
    chown -R root:root /root/.ssh && \
    chmod 600 /root/.ssh/id_rsa && \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN git clone git@bitbucket.org:dptrealtime/java-login-app.git /opt/app
WORKDIR /opt/app
RUN /opt/maven/bin/mvn package

FROM amazonlinux
RUN yum install wget -y && \
    yum install gzip -y && \
    yum install tar -y
RUN yum install java -y
RUN https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.115/bin/apache-tomcat-9.0.115.tar.gz && \
    tar zxf apache-tomcat-9.0.115.tar.gz && \
    mv apache-tomcat-9.0.115 /opt/tomcat
COPY --from=build /opt/app/target/dptweb-1.0.war /opt/tomcat/webapps/
CMD  ["/opt/tomcat/bin/catalina.sh", "run"]
