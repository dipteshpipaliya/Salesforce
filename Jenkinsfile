pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
        
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
            // Read the webhook variable directly
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
        // Securely inject the server.key file from Jenkins credential manager
        withCredentials([file(credentialsId: 'sf-jwt-key', variable: 'TEMP_JWT_KEY')]) {
            script {
                // 1. Copy the key file immediately to your active workspace directory
                // This prevents Jenkins from deleting it when this block closes
                sh "cp ${TEMP_JWT_KEY} ./server.key"
                
                // 2. Perform the login pointing to the permanent workspace copy
                sh "sf org login jwt --client-id ${SF_CLIENT_ID} --jwt-key-file ./server.key --username ${SF_USERNAME} --instance-url ${INSTANCE_URL} --set-default-dev-hub"
            }
        }
    }
}
        
        stage('Authorize Salesforce') {
            steps {
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'JWT_KEY_FILE')]) {
                    bat 'sf org login jwt --client-id "%CLIENT_ID%" --jwt-key-file "%JWT_KEY_FILE%" --username "%SF_USERNAME%" --instance-url "%INSTANCE_URL%" --set-default'
                }
            }
        }
        
        stage('Deploy to Salesforce') {
            steps {
                // Passes the dynamically extracted tests into the Windows batch command
                bat "sf project deploy start --test-level RunSpecifiedTests --tests ${EXTRACTED_TESTS}"
            }
        }
    }
}