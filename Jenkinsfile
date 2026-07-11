pipeline {
    agent any
    
    environment {
        // Your Salesforce External Client App Consumer Key
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        // Your Salesforce deployment user email
        SF_USERNAME = 'orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com'
        // Use https://test.salesforce.com for Sandbox, login.salesforce.com for Prod
        INSTANCE_URL = 'https://login.salesforce.com/' 
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                // This checks out your Git repository files onto the Jenkins server
                checkout scm
            }
        }
        
        stage('Authorize Salesforce') {
            steps {
                // Retrieves the secret server.key file you uploaded to Jenkins Credentials
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'JWT_KEY_FILE')]) {
                    // Using %VARIABLE% syntax and carets ( ^ ) for Windows line breaks
                    bat '''
                        sf org login jwt ^
                            --client-id %CLIENT_ID% ^
                            --jwt-key-file %JWT_KEY_FILE% ^
                            --username %SF_USERNAME% ^
                            --instance-url %INSTANCE_URL% ^
                            --set-default
                    '''
                }
            }
        }
        
        stage('Deploy to Salesforce') {
            steps {
                // Deploys the metadata source code to your target Salesforce Org
                bat 'sf project deploy start'
            }
        }
    }
}