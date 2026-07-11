pipeline {
    agent any
    
    // 1. Define the input parameter for the Jenkins UI
    parameters {
        string(
            name: 'TEST_CLASSES', 
            defaultValue: 'ContactServiceTest', 
            description: 'Enter the test class name(s) to run. For multiple classes, separate them with commas (e.g., TestClass1,TestClass2).'
        )
    }
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
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
                // 2. Read the parameter using %TEST_CLASSES% in the Windows batch command
                bat 'sf project deploy start --test-level RunSpecifiedTests --tests "%TEST_CLASSES%"'
            }
        }
    }
}