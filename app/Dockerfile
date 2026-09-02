
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests


FROM eclipse-temurin:17-jre-jammy


RUN groupadd -r 565956 && useradd -r -g 565956 -d /app -s /sbin/nologin 565956

WORKDIR /app
COPY --from=build /build/target/transacoes-api.jar /app/transacoes-api.jar

RUN chown -R 565956:565956 /app
USER 565956

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/transacoes-api.jar"]
