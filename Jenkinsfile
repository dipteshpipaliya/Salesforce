pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        
        // 1. Change this to match your target environment (e.g., https://test.salesforce.com for Sandboxes)
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
    }
    
    stages {
        stage('Checkout Code & PR Refs') {
            steps {
                script {
                    checkout scm
                    echo "Safely fetching open Pull Requests from GitHub..."
                    bat 'git fetch origin +refs/pull/*:refs/remotes/origin/pr/*'
                }
            }
        }
        
        stage('Extract Tests from PR') {
            steps {
                script {
                    echo "Checking PR commit history for Apex Test assignments..."
                    def commitLog = bat(script: 'git log origin/main..HEAD --pretty=%%B', returnStdout: true).trim()
                    
                    def matcher = (commitLog =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
                    
                    if (matcher.find()) {
                        def targetTests = matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
                        env.SF_DEPLOY_FLAGS = "--test-level RunSpecifiedTests --tests \"${targetTests}\""
                        echo "Successfully parsed Apex Tests from PR Commit. Running: ${targetTests}"
                    } else {
                        env.SF_DEPLOY_FLAGS = "--test-level NoTestRun"
                        echo "No valid Apex Tests found in PR comment format. Bypassing tests completely using NoTestRun strategy."
                    }
                }
            }
        }
        
        stage('Authenticate Target Org') {
            steps {
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
                        bat 'copy "%TEMP_JWT_KEY%" .\\server.key'
                        
                        // 2. Logs directly into your target sandbox or environment instead of a Dev Hub
                        bat 'sf org login jwt --client-id "%CLIENT_ID%" --jwt-key-file .\\server.key --username "%SF_USERNAME%" --instance-url "%INSTANCE_URL%" --set-default'
                        bat 'sf config set org-capitalize-record-types=true'
                    }
                }
            }
        }

        // REMOVED: Provision Scratch Org Stage is completely gone!

        stage('Deploy & Test to Target Org') {
            steps {
                // 3. Deploys straight to the authenticated default environment
                bat 'sf project deploy start %SF_DEPLOY_FLAGS%'
            }
        }
    }
    
    post {
        always {
            script {
                bat 'if exist .\\server.key del /f /q .\\server.key'
            }
        }
    }
}