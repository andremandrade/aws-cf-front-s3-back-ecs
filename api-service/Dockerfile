# BUILD
FROM maven:3.8.1-openjdk-11 AS builder

WORKDIR /service

COPY . .

RUN mvn package
VOLUME /root/.m2

#RUN
FROM openjdk:11.0.12-jre-slim

WORKDIR /service

COPY --from=builder /service/target/*.jar .

ENV JAR_FILE=*.jar

ENTRYPOINT java -jar ${JAR_FILE}
