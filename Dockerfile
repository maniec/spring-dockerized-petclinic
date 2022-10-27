# syntax=docker/dockerfile:1
FROM eclipse-temurin:17-jdk-jammy as base
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
# code is needed to attack a debugger ??
COPY src ./src

# docker build --tag java-docker:test . --target test
FROM base as test
# CMD ["./mvnw", "test"]
# Instead of CMD, RUN executes over the image rather than needed to spin up a container to execute CMD on it
# Therefore only "docker build --target test" is needed rather than "docker build --target test + docker run"
RUN ["./mvnw", "test"]

# docker build --tag java-docker:jdk . --target development
FROM base as development
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN ./mvnw package

# As last step in the file, no target is specified at build... it will be used by default to build the image
# docker build --tag java-docker:jre .
# This step doesn’t take the base target or a JDK image as reference in order to make image smaller
# This way only image only contains a runtime environment with the final application archive, just what is needed to start the application
FROM eclipse-temurin:17-jre-jammy as production
EXPOSE 8080
COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
