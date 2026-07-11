pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com'
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
                    // Fetch the PR Description from Jenkins environment variables
                    // Note: CHANGE 'CHANGE_URL' or 'CHANGE_BODY' depending on your Git plugin settings
                    def prBody = env.CHANGE_BODY ?: ""
                    
                    echo "Scanning Pull Request Description..."
                    
                    // Regex looks for "## Apex Tests" followed by the class names
                    def matcher = (prBody =~ /(?i)## Apex Tests\s*\r?\n\s*([a-zA-Z0-9_,\s]+)/)
                    
                    if (matcher.find()) {
                        EXTRACTED_TESTS = matcher[0][1].trim().replaceAll("\\s+", "")
                        echo "Found target Apex Tests in PR: ${EXTRACTED_TESTS}"
                    } else {
                        // Fallback default test if no match is found to avoid breaking the build completely
                        EXTRACTED_TESTS = 'ContactServiceTest'
                        echo "No Apex Tests declared in PR body. Using fallback: ${EXTRACTED_TESTS}"
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