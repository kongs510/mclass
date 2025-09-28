pipeline {
    //어떤 에이전트(실행서버)에서든 실행 가능
    agent any
    

    tools {
        //Maven 3.9.11 사용
        maven 'maven 3.9.11'
    }
    environment {
        //배포에 필요한 환경변수 설정
        DOCKER_IMAGE = 'demo-app' //도커 이미지 이름
        CONTAINER_NAME = 'springboot-container' //도커 컨테이너 이름
        JAR_FILE_NAME = 'app.jar' //복사할 JAR 파일 이름
        ROOT = "8081" //컨테이너와 연결할 포트
        REMOTE_USER = 'ec2-user' //원격 서버 사용자 이름
        REMOTE_HOST = '3.34.134.227' //원격(springboot) 서버 Public IP 주소
        REMOTE_DIR = '/home/ec2-user/deploy' //원격 서버의 파일 복사할 경로
        SSH_CREDENTIALS_ID = '5ebab6a5-eb7c-46ac-a96f-469bf0ad74da' //Jenkins에 등록된 SSH 자격증명 ID
    }
    stages {
        stage('Git Checkout') {
            //stage 안에서 실행 실행할 실제 명령어
            steps {
                //Jenkins가 연결된 Git 저장소에서 최신 코드 체크아웃
                checkout scm
            }
        }
        stage('Maven Build') {
            steps {
                // 테스트는 건너뛰고 Maven 빌드 수행

                //Maven 빌드 명령어 실행
                sh 'mvn clean package -DskipTests'
                //sh 'mvn Hello' : 리눅스 명령어 실행
            }
        }
        stage('Prepare Jar') {
            steps {
                //빌드된 JAR 파일을 원격 서버로 복사
                sh 'cp target/demo-0.0.1-SNAPSHOT.jar ${JAR_FILE_NAME}'
            }
        }
        stage('copy to Remote Server') {
            steps {
                // Jenkins에서 원격서버에 SSH에 접속할 수 있도록 에이전트 플러그인을 사용
                //JAR 파일을 원격 서버로 복사
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                    // 원격 서버에 배포 디렉토리 생성 ( 없으면 새로 만듦)
                    sh "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} \"mkdir -p ${REMOTE_DIR}\""
                    // JAR 파일과 Dockerfile을 원격 서버에 복사
                    sh "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${JAR_FILE_NAME} Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
                }
            }
        }
        stage('Remote Docker Build & Deploy'){
            steps {
                //원격 서버에서 도커 이미지 빌드 및 컨테이너 실행
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                    // 원격 서버에서 도커 이미지 빌드 및 컨테이너 실행
                                // 원격 서버에서 도커 컨테이너를 제거하고 새로 빌드 및 실행
                    sh """
                    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} << ENDSSH
                        cd ${REMOTE_DIR} || exit 1                          # 복사한 디렉토리로 이동
                        docker rm -f ${CONTAINER_NAME} || true             # 이전에 실행 중인 컨테이너 삭제 (없으면 무시)
                        docker build -t ${DOCKER_IMAGE} .                  # 현재 디렉토리에서 Docker 이미지 빌드
                        docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${DOCKER_IMAGE} # 새 컨테이너 실행
                    ENDSSH
                    """
                }
            }
        }

    }
}