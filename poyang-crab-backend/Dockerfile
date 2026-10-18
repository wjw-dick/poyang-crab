# =============================================================
# 后端镜像：Java 17 + Spring Boot 3（多阶段构建）
# =============================================================
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
ENV TZ=Asia/Shanghai \
    JAVA_OPTS="-Xms512m -Xmx2048m -XX:+UseG1GC -Dfile.encoding=UTF-8"
COPY --from=builder /build/target/poyang-crab-backend-*.jar app.jar
RUN mkdir -p /app/logs /data/upload
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD wget -qO- http://127.0.0.1:8080/api/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar --spring.profiles.active=prod"]
