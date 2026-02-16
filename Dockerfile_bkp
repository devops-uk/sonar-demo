FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -DskipTests clean package

FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy any WAR produced by Maven into ROOT.war (no dependency on exact filename)
COPY --from=builder /workspace/target/*.war /usr/local/tomcat/webapps/ROOT.war
