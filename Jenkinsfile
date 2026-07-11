pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
        SCRATCH_ALIAS = 'ScratchOrg_PR'
    }
    
    stages {
       stage('Checkout Code & PR Refs') {
            steps {
                script {
                    // Standard checkout first
                    checkout scm
                    
                    echo "Safely fetching open Pull Requests from GitHub..."
                    
                    // Force-fetches the hidden PR references directly without breaking your local git config file
                    bat 'git fetch origin +refs/pull/*:refs/remotes/origin/pr/*'
                }
            }
        }
        
        stage('Extract Tests from PR') {
            steps {
                script {
                    echo "Checking PR commit history for Apex Test assignments..."
                    def commitLog = bat(script: 'git log origin/main..HEAD --pretty=%B', returnStdout: true).trim()
                    
                    echo "--- DEBUG INFO ---"
                    echo "PR Commit History scanned:\n${commitLog}"
                    echo "------------------"
                    
                    // 1. Look for the "Apex Tests [ClassName]" pattern
                    def matcher = (commitLog =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
                    
                    if (matcher.find()) {
                        def targetTests = matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
                        
                        // 2. Found valid text! Set up deployment to run this specific test
                        env.SF_DEPLOY_FLAGS = "--test-level RunSpecifiedTests --tests \"${targetTests}\""
                        echo "Successfully parsed Apex Tests from PR Commit. Running: ${targetTests}"
                    } else {
                        // 3. BYPASS BY DEFAULT: Switch deployment strategy to NoTestRun if parsing fails
                        env.SF_DEPLOY_FLAGS = "--test-level NoTestRun"
                        echo "No valid Apex Tests found in PR comment format. Bypassing tests completely using NoTestRun strategy."
                    }
                }
            }
        }
        
        stage('Authenticate Dev Hub') {
            steps {
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
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
                // FIXED: Now correctly executes using the dynamic bypass/specified-test environment flags
                bat 'sf project deploy start %SF_DEPLOY_FLAGS%'
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