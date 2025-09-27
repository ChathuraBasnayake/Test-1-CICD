# Stage 1: Build the JAR (using Maven)
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build the jar
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime (use a slim JDK image)
FROM eclipse-temurin:21-jdk-jammy AS runtime

WORKDIR /app

# Copy the built JAR from stage 1
COPY --from=build /app/target/*.jar app.jar

# Expose port (Spring Boot default is 8080)
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
