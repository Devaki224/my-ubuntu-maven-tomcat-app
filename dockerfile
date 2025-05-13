# Stage 1: Build WAR with Maven on Ubuntu
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN mvn clean package


# Stage 2: Run WAR on Tomcat on Ubuntu
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz && \
    tar -xvzf apache-tomcat-9.0.56.tar.gz && \
    mv apache-tomcat-9.0.56 /opt/tomcat && \
    rm apache-tomcat-9.0.56.tar.gz

COPY --from=builder /app/target/*.war /opt/tomcat/webapps/app.war

EXPOSE 8080
ENV CATALINA_HOME /opt/tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
