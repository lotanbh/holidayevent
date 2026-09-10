pipeline {
    agent any

    triggers {
        pollSCM('* * * * *') // Checks for Git changes every minute
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from GitHub repository automatically...'
                checkout scm 
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies directly on Jenkins...'
                sh 'npm install' // החלפנו ל-install רגיל כמו שהאפליקציה הזו דורשת
            }
        }

        stage('Test') {
            steps {
                echo 'Running application syntax validation test...'
                sh 'node --check server.js' // מאחר ואין npm test באפליקציה הזו, הבדיקה הזו מוודאת שהקוד תקין ולא קורס
            }
        }

        stage('Build image') {
            steps {
                echo "Building Docker image for build #${BUILD_NUMBER}..."
                // בניית האימג' המקומי בדיוק כמו שלמדתם בכיתה, רק עם שם האפליקציה הנוכחית
                sh 'docker build -t holiday-app:${BUILD_NUMBER} -t holiday-app:latest .'
            }
        }

        // בפרויקט הנוכחי ג'נקינס מסיים כאן! הוא בנה את האימג' ומכין אותו עבור Ansible.
    }
    
    post {
        success {
            echo 'The Pipeline completed successfully!'
        }
        failure {
            echo 'The Pipeline failed!'
        }
    }
}
