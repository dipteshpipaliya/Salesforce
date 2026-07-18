pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    checkout scm
                    echo "Current Execution Branch: ${env.BRANCH_NAME}"
                    echo "Pull Request ID (if applicable): ${env.CHANGE_ID}"
                }
            }
        }
        
        stage('Extract Tests & Generate Delta') {
            steps {
                script {
                    echo "Checking/Installing sfdx-git-delta plugin..."
                    // Uses conditional check logic to avoid reinstalling if it already exists
                    bat 'sf plugins inspect sfdx-git-delta >nul 2>&1 || sf plugins install sfdx-git-delta --no-prompt'

                    echo "Generating Delta deployment payload based on Git history..."
                    bat 'if exist changed-sources rmdir /s /q changed-sources'
                    bat 'mkdir changed-sources'
                    
                    if (env.CHANGE_ID) {
                        echo "Processing Delta for Pull Request Validation..."
                        
                        // FIX: Combined into a single, clean batch command chain execution string
                        def commitLog = bat(script: '@echo off\ngit log origin/main..HEAD --pretty=format:%%B', returnStdout: true).trim()
                        def targetTests = parseApexTests(commitLog)
                        
                        if (targetTests != null) {
                            env.SF_TEST_FLAGS = "--test-level RunSpecifiedTests --tests \"${targetTests}\""
                        } else {
                            env.SF_TEST_FLAGS = "--test-level NoTestRun"
                        }
                        
                        bat 'sf sgd source delta --to HEAD --from origin/main --output-dir changed-sources/'
                        env.SF_EXECUTION_MODE = "VALIDATE"
                        
                    } else {
                        echo "Processing Delta for Main Merge Deployment..."
                        env.SF_TEST_FLAGS = "--test-level NoTestRun" 
                        
                        bat 'sf sgd source delta --to HEAD --from HEAD~1 --output-dir changed-sources/' 
                        env.SF_EXECUTION_MODE = "DEPLOY"
                    }
                    
                    echo "--- MANIFEST CONTENT ---"
                    bat 'if exist changed-sources\\package\\package.xml type changed-sources\\package\\package.xml'
                }
            }
        }
        
        stage('Authenticate Target Org') {
            steps {
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
                        bat 'if exist .\\server.key del /f /q .\\server.key'
                        bat 'copy "%TEMP_JWT_KEY%" .\\server.key'
                        bat 'sf org login jwt --client-id "%CLIENT_ID%" --jwt-key-file .\\server.key --username "%SF_USERNAME%" --instance-url "%INSTANCE_URL%" --set-default --no-prompt'
                        bat 'sf config set org-capitalize-record-types=true'
                    }
                }
            }
        }

        stage('Execute Salesforce Action') {
            steps {
                script {
                    if (env.SF_EXECUTION_MODE == "VALIDATE") {
                        echo "Running PR Check: Delta Validation Check (--dry-run mode)"
                        bat 'sf project deploy start --manifest changed-sources/package/package.xml %SF_TEST_FLAGS% --dry-run'
                    } else {
                        echo "Running Merge Action: Deploying Delta Changes Natively to Org"
                        bat 'sf project deploy start --manifest changed-sources/package/package.xml %SF_TEST_FLAGS%'
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up workspace keys and dynamic manifests..."
                bat 'if exist .\\server.key del /f /q .\\server.key'
                bat 'if exist .\\changed-sources rmdir /s /q .\\changed-sources'
            }
        }
    }
}

@NonCPS
def parseApexTests(String commitLog) {
    def matcher = (commitLog =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
    if (matcher.find()) {
        return matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
    }
    return null
}