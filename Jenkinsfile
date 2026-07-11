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
                    
                    echo "Configuring Git to see open Pull Requests..."
                    // 1. Manually tell the local Git workspace to look for GitHub Pull Requests
                    bat 'git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"'
                    bat 'git config --add remote.origin.fetch "+refs/pull/*:refs/remotes/origin/pr/*"'
                    
                    echo "Fetching latest changes from GitHub..."
                    bat 'git fetch origin'
                }
            }
        }
 stage('Extract Tests from PR') {
            steps {
                script {
                    echo "Checking local Git history for Apex Test assignments..."
                    
                    // 1. Run a native batch command to grab the latest commit message text
                    def commitMessage = bat(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    
                    echo "--- DEBUG INFO ---"
                    echo "Latest Commit Message found: '${commitMessage}'"
                    echo "------------------"
                    
                    def targetTests = 'ContactServiceTest' // Default fallback test
                    
                    // 2. Scan the commit message text for: Apex Tests [ClassName]
                    def matcher = (commitMessage =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
                    
                    if (matcher.find()) {
                        targetTests = matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
                        echo "Successfully parsed Apex Tests from Git commit: ${targetTests}"
                    } else {
                        echo "No Apex Tests found in the commit message template."
                        echo "Using fallback execution: ${targetTests}"
                    }
                    
                    env.RUN_THESE_TESTS = targetTests
                }
            }
        }

     stage('Authenticate Dev Hub') {
            steps {
                // Changed 'sf-jwt-key' to 'salesforce-jwt-key'
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