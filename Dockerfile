FROM eclipse-temurin:17 AS builder
WORKDIR /app
ARG ARTIFACT_NAME
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./
RUN chmod +x ./mvnw
COPY ${ARTIFACT_NAME}/ ./${ARTIFACT_NAME}
RUN ./mvnw clean install
RUN ls ./${ARTIFACT_NAME}
COPY /app/${ARTIFACT_NAME}/target/${ARTIFACT_NAME}-3.2.4.jar ./application.jar
RUN java -Djarmode=layertools -jar application.jar extract
ARG DOCKERIZE_VERSION
RUN wget -O dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && tar xzf dockerize.tar.gz && chmod +x dockerize

FROM eclipse-temurin:17
WORKDIR /application
COPY --from=builder /app/dockerize ./dockerize
ARG EXPOSED_PORT
EXPOSE ${EXPOSED_PORT}
ENV SPRING_PROFILES_ACTIVE=docker
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
