pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
        SCRATCH_ALIAS = 'ScratchOrg_PR'
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
                    
                    // Fallback test class if regex misses
                    def targetTests = 'ContactServiceTest'
                    
                    // Upgraded regex: Matches "Apex Tests" followed by newline/spaces and text list
                    def matcher = (prBody =~ /(?i)Apex\s*Tests\s*\r?\n\s*([a-zA-Z0-9_,\s]+)/)
                    if (matcher.find()) {
                        targetTests = matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
                        echo "Found target Apex Tests in PR: ${targetTests}"
                    } else {
                        echo "No Apex Tests declared in PR body. Using fallback: ${targetTests}"
                    }
                    
                    // Injecting safely into pipeline environment mapping
                    env.RUN_THESE_TESTS = targetTests
                }
            }
        }

        stage('Authenticate Dev Hub') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
                        // Safe clean file copying syntax for Windows environments
                        bat 'copy "%TEMP_JWT_KEY%" .\\server.key'
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
                // Reading environment mapping using Windows variable conventions
                bat 'sf project deploy start --test-level RunSpecifiedTests --tests "%RUN_THESE_TESTS%"'
            }
        }
    }
    
    post {
        always {
            script {
                // Ensure transient authentication file cleanup occurs properly
                bat 'if exist .\\server.key del /f /q .\\server.key'
            }
        }
    }
}