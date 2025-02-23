FROM amazoncorretto:21.0.0-alpine

WORKDIR /app
EXPOSE 8080

# Copy the jar file to the container using ARG for version
ARG VERSION
COPY build/libs/cicd-application-${VERSION}.jar cicd-application.jar

ENTRYPOINT ["java", "-jar", "cicd-application.jar"]
