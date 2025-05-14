# Base image
FROM ubuntu:24.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages: OpenJDK 17, Maven, wget, curl, unzip
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk maven wget curl unzip && \
    apt-get clean

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set working directory
WORKDIR /app

# Copy Maven project (pom.xml and src/)
COPY pom.xml .
COPY src ./src

# Build the project
RUN mvn clean package -DskipTests

# Download and extract Apache Tomcat
WORKDIR /opt
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz && \
    tar -xzf apache-tomcat-9.0.85.tar.gz && \
    mv apache-tomcat-9.0.85 tomcat && \
    rm apache-tomcat-9.0.85.tar.gz

# Deploy WAR file to Tomcat's webapps folder
RUN cp /app/target/*.war /opt/tomcat/webapps/

# Expose Tomcat's default port
EXPOSE 8080

# Start Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]

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
