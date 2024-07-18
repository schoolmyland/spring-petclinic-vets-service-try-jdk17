FROM eclipse-temurin:17 AS builder
WORKDIR /app
ARG ARTIFACT_NAME
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./
RUN chmod +x ./mvnw
COPY ${ARTIFACT_NAME}/ ./${ARTIFACT_NAME}
RUN ./mvnw clean install
RUN mv ./target/*jar ./target/app.jar

FROM eclipse-temurin:17
ENV DOCKERIZE_VERSION=v0.7.0
RUN apt-get update \
    && apt-get install -y wget \
    && wget -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzf - -C /usr/local/bin \
    && apt-get autoremove -yqq --purge wget && rm -rf /var/lib/apt/lists/*
COPY --from=builder app/target/app.jar ./
ENTRYPOINT ["java","-jar","/app.jar"]
