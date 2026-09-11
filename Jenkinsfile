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
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                echo 'Running application syntax validation test...'
                sh 'node --check server.js'
            }
        }

        stage('Build image') {
            steps {
                echo "Building Docker image for build #${BUILD_NUMBER}..."
                sh 'docker build -t holiday-app:latest .'
            }
        }

        // FULL AUTOMATION (PART 6): Triggering Ansible automatically
        stage('Deploy with Ansible') {
            steps {
                echo 'Triggering Ansible Deployment Playbook safely with Vault...'
                // We added the vault password file and included the secrets file
                sh 'ansible-playbook -i inventory.ini deploy.yml --vault-password-file .vault_pass -e @secrets.yml'
            }
        }

    }
    
    post {
        success {
            echo 'The entire CI/CD Pipeline completed successfully!'
        }
        failure {
            echo 'The Pipeline failed!'
        }
    }
}
