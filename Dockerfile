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
