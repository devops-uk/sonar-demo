# -------- Stage 1: Build the JAR --------
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /workspace

# Copy pom first to leverage Docker layer cache
COPY pom.xml .
COPY src ./src

# Build (skip tests for faster CD; CI already runs tests)
RUN mvn -DskipTests clean package

# -------- Stage 2: Run the app --------
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /workspace/target/*.jar /app/app.jar

# Optional: show jar exists in build logs (helpful while debugging)
# RUN ls -lah /app

ENTRYPOINT ["java","-jar","/app/app.jar"]
FROM tomcat:10.1-jdk17-temurin

# Clean default apps (optional)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR as ROOT.war so it serves at /
COPY target/sonar-demo.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
