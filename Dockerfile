FROM openjdk:17-jdk
# JAR 파일이 저장될 작업 디렉토리 설정
WORKDIR /app
# maven 또는 gradle로 빌드한 JAR 파일을 컨테이너의 내부 /app 디렉토리에 app.jar 이름으로 복사
copy app.jar app.jar
# host (jenkins)에 생성된 app.jar 파일을 컨테이너 내부 /app/app.jar 파일로 복사

# 컨테이너가 외부와 통신하기 위한 PORT 설정
EXPOSE 8081

# 컨테이너가 시작될 때 자동으로 java -jar app.jar 명령어 실행
ENTRYPOINT ["java", "-jar", "app.jar"]