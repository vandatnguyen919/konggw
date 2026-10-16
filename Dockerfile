FROM gradle:9.8.1-jdk27 AS build
WORKDIR /workspace
COPY . .
ARG SERVICE
RUN gradle :${SERVICE}:bootJar --no-daemon

FROM eclipse-temurin:27-jre
ARG SERVICE
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /workspace/${SERVICE}/build/libs/${SERVICE}-0.0.1-SNAPSHOT.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
