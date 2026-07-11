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
                    
                    // Default fallback test class if parsing fails completely
                    def targetTests = 'ContactServiceTest'
                    
                    // 1. Clean the string to remove markdown characters like '#' that can break regex bounds
                    def cleanBody = prBody.replaceAll("#", "").trim()
                    
                    // 2. REGEX: Look for "Apex Tests" followed by optional spaces, brackets, and alphanumeric text
                    // Matches: Apex Tests [test1,test2] OR Apex Tests test1,test2
                    def matcher = (cleanBody =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
                    
                    if (matcher.find()) {
                        // Strip out all whitespace, newlines, and carriage returns completely
                        targetTests = matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
                        echo "Successfully parsed Apex Tests from PR: ${targetTests}"
                    } else {
                        echo "Regex pattern match failed. PR body didn't match format."
                        echo "Using fallback execution: ${targetTests}"
                    }
                    
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