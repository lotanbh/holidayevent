pipeline {
    agent any

    environment {
        // הגדרת שם האימג' והמשתמש ב-Docker Hub
        DOCKER_USER   = 'lotanb'
        IMAGE_NAME    = 'holiday-app'
        IMAGE_TAG     = "${BUILD_NUMBER}" // שימוש במספר ה-Build של ג'נקינס כ-Tag מסודר
        REGISTRY_CRED = 'docker-hub-credentials' // ה-ID של ה-Credentials שנגדיר בג'נקינס
    }

    stages {
        // שלב 1: משיכת הקוד מ-GitHub (מבוצע אוטומטית ע"י ג'נקינס, אך נהוג לציין)
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // שלב 2: התקנת תלויות (Dependencies)
        stage('Install Dependencies') {
            steps {
                echo 'Installing npm dependencies...'
                sh 'npm install'
            }
        }

        // שלב 3: בדיקת האפליקציה (בדיקת סינטקס בסיסית מאחר ואין קובץ טסטים)
        stage('Test Application') {
            steps {
                echo 'Running syntax check / basic test...'
                sh 'node --check server.js'
            }
        }

        // שלב 4 & 5: בניית ה-Docker Image ותיוג שלו
        stage('Build & Tag Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:latest ."
            }
        }

        // שלב 6: דחיפת ה-Image ל-Container Registry (Docker Hub)
        stage('Push to Docker Hub') {
            steps {
                // שימוש ב-Credentials של ג'נקינס לצורך לוגין מאובטח (כדי לא לחשוף סיסמאות ב-GitHub)
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CRED}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo \$PASS | docker login -u \$USER --password-stdin"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
