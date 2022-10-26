# syntax=docker/dockerfile:1
FROM eclipse-temurin:17-jdk-jammy

# Sets the images's working directory > all subsequent commands will be relative to this path
WORKDIR /app

# Copy file(s)/dir(s) from host file system into the image file system, relative to the working dir
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Install dependencies
# First thing you do once downloaded a Java project using Maven for project management
# But need wrapper and pom in the correct place > therefore COPY first
RUN ./mvnw dependency:resolve

# Add source code into the image
COPY src ./src

# Tells Docker what command to run when our image is executed inside a container
# CMD ["./mvnw", "spring-boot:run"]

# Activate the MySQL Spring profile defined in the application and switch from an in-memory H2 database to the created MySQL server
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql"]
