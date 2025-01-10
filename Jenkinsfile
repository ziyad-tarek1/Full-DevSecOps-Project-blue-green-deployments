pipeline {
    agent any
    tools {
        jdk 'jdk'
        nodejs 'nodejs'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key') 
        AWS_DEFAULT_REGION = 'us-east-1'       
        DOCKER_CREDENTIALS_ID = 'DockerHub-Cred'
        DOCKERHUB_REPO_FRONTEND = 'ziyadtarek99/frontend'
        DOCKERHUB_REPO_BACKEND = 'ziyadtarek99/backend'
        GITHUB_REPO = 'https://github.com/ziyad-tarek1/DevSecOps-ThreeTierWebApp.git'
        GITHUB_CREDENTIALS = 'GITHUB'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: "${GITHUB_CREDENTIALS}", url: "${GITHUB_REPO}"
            }
        }
        stage('Install Dependencies') {
            parallel {
                stage('Frontend Dependencies') {
                    steps {
                        dir('application/frontend') {
                            sh 'npm install'
                        }
                    }
                }
                stage('Backend Dependencies') {
                    steps {
                        dir('application/backend') {
                            sh 'npm install'
                        }
                    }
                }
            }
        }
        stage('Build Application') {
            parallel {
                stage('Build Frontend') {
                    steps {
                        dir('application/frontend') {
                            sh 'npm run build'
                        }
                    }
                }
                stage('Build Backend') {
                    steps {
                        dir('application/backend') {
                            sh 'npm run build'
                        }
                    }
                }
            }
        }
        stage('SonarQube Analysis') {
            parallel {
                stage('Frontend Analysis') {
                    steps {
                        dir('application/frontend') {
                            withSonarQubeEnv('sonar-server') {
                                sh """
                                ${SCANNER_HOME}/bin/sonar-scanner \
                                -Dsonar.projectName=three-tier-frontend \
                                -Dsonar.projectKey=three-tier-frontend
                                """
                            }
                        }
                    }
                }
                stage('Backend Analysis') {
                    steps {
                        dir('application/backend') {
                            withSonarQubeEnv('sonar-server') {
                                sh """
                                ${SCANNER_HOME}/bin/sonar-scanner \
                                -Dsonar.projectName=three-tier-backend \
                                -Dsonar.projectKey=three-tier-backend
                                """
                            }
                        }
                    }
                }
            }
        }
        stage('Trivy Scans') {
            parallel {
                stage('Frontend Trivy Scan') {
                    steps {
                        dir('application/frontend') {
                            sh 'trivy fs --format table -o frontend-fs-scan.html .'
                        }
                    }
                }
                stage('Backend Trivy Scan') {
                    steps {
                        dir('application/backend') {
                            sh 'trivy fs --format table -o backend-fs-scan.html .'
                        }
                    }
                }
            }
        }
        stage('Build Docker Images') {
            parallel {
                stage('Frontend Docker Image') {
                    steps {
                        dir('application/frontend') {
                            script {
                                def tag = "${env.BUILD_NUMBER}.0"
                                env.FRONTEND_IMAGE_TAG = tag
                                docker.build("${DOCKERHUB_REPO_FRONTEND}:${tag}")
                            }
                        }
                    }
                }
                stage('Backend Docker Image') {
                    steps {
                        dir('application/backend') {
                            script {
                                def tag = "${env.BUILD_NUMBER}.0"
                                env.BACKEND_IMAGE_TAG = tag
                                docker.build("${DOCKERHUB_REPO_BACKEND}:${tag}")
                            }
                        }
                    }
                }
            }
        }
        stage('Push Docker Images') {
            parallel {
                stage('Push Frontend Image') {
                    steps {
                        script {
                            docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                                docker.image("${DOCKERHUB_REPO_FRONTEND}:${FRONTEND_IMAGE_TAG}").push()
                                docker.image("${DOCKERHUB_REPO_FRONTEND}:${FRONTEND_IMAGE_TAG}").push('latest')
                            }
                        }
                    }
                }
                stage('Push Backend Image') {
                    steps {
                        script {
                            docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                                docker.image("${DOCKERHUB_REPO_BACKEND}:${BACKEND_IMAGE_TAG}").push()
                                docker.image("${DOCKERHUB_REPO_BACKEND}:${BACKEND_IMAGE_TAG}").push('latest')
                            }
                        }
                    }
                }
            }
        }
        stage('Update Kubernetes Manifests') {
            parallel {
                stage('Update Frontend Manifest') {
                    steps {
                        dir('k8s/Frontend') {
                            script {
                                sh """
                                sed -i "s|image: .*|image: ${DOCKERHUB_REPO_FRONTEND}:${FRONTEND_IMAGE_TAG}|" deployment.yaml
                                git add deployment.yaml
                                git commit -m "Update Frontend Deployment Image to ${FRONTEND_IMAGE_TAG}"
                                git push
                                """
                            }
                        }
                    }
                }
                stage('Update Backend Manifest') {
                    steps {
                        dir('k8s/Backend') {
                            script {
                                sh """
                                sed -i "s|image: .*|image: ${DOCKERHUB_REPO_BACKEND}:${BACKEND_IMAGE_TAG}|" deployment.yaml
                                git add deployment.yaml
                                git commit -m "Update Backend Deployment Image to ${BACKEND_IMAGE_TAG}"
                                git push
                                """
                            }
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                 dir('k8s/argocd') {                
                script {
                    // Deploy frontend via ArgoCD (blue-green enabled)
                    sh 'argocd app sync frontend --revision HEAD'
                    // Deploy backend via ArgoCD (rolling update)
                    sh 'argocd app sync backend --revision HEAD'
                    // Deploy Database via ArgoCD (rolling update)
                    sh 'argocd app sync db --revision HEAD'                    
                }
                 }
            }
        }

    }
    post {
        always {
            archiveArtifacts artifacts: '**/*.html', allowEmptyArchive: true
            emailext(
                subject: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\nMore info at: ${env.BUILD_URL}",
                body: "Please find the attached file created by Jenkins / Build URL: ${env.BUILD_URL}",
                to: 'ziyadtarek180@gmail.com',
                from: 'ziyadtarek180@gmail.com',
                replyTo: 'ziyadtarek180@gmail.com',
                attachLog: true,
                attachmentsPattern: '**/*.html'
            )
        }
    }
}
