pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
        SCRATCH_ALIAS = 'ScratchOrg_PR'
        
        // This variable will store the extracted test classes
        EXTRACTED_TESTS = ''
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Extract Tests from PR') {
            steps {
                script {
                    def prBody = env.PR_BODY ?: ""
                    echo "Scanning PR Description from Webhook Payload..."
                    
                    def matcher = (prBody =~ /(?i)## Apex Tests\s*\r?\n\s*([a-zA-Z0-9_,\s]+)/)
                    if (matcher.find()) {
                        EXTRACTED_TESTS = matcher[0][1].trim().replaceAll("\\s+", "")
                    } else {
                        EXTRACTED_TESTS = 'ContactServiceTest'
                    }
                    echo "Tests to run: ${EXTRACTED_TESTS}"
                }
            }
        }

        stage('Authenticate Dev Hub') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
                        // Windows uses 'copy' instead of 'cp'
                        // Enclosing variables in quotes handles spaces in Windows paths safely
                        bat 'copy "%TEMP_JWT_KEY%" .\\server.key'
                        
                        // Execute Salesforce login using Windows batch syntax
                        bat 'sf org login jwt --client-id "%CLIENT_ID%" --jwt-key-file .\\server.key --username "%SF_USERNAME%" --instance-url "%INSTANCE_URL%" --set-default-dev-hub'
                    }
                }
            }
        }

        stage('Provision Scratch Org') {
            steps {
                bat 'sf org create scratch --definition-file config/project-scratch-def.json --alias "%SCRATCH_ALIAS%" --set-default --duration-days 1'
            }
        }

        stage('Deploy & Test to Scratch Org') {
            steps {
                bat 'sf project deploy start --test-level RunSpecifiedTests --tests "%EXTRACTED_TESTS%"'
            }
        }
    }
    
    post {
        always {
            script {
                // Windows uses 'del' instead of 'rm -f'
                bat 'if exist .\\server.key del /f /q .\\server.key'
            }
        }
    }
}