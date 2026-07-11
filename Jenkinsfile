pipeline {
    agent any
    
    environment {
        CLIENT_ID = '3MVG9HtWXcDGV.nF1F54zosIcUnMSWJp9xSdbqaBrNGYZubtCWhH01rXAU9ONF8VDPG3OnegbyleaujfT2YER'
        SF_USERNAME = 'dipteshpipaliya.9e05d8f66461@agentforce.com'
        INSTANCE_URL = 'https://orgfarm-51d7ed45cf-dev-ed.develop.my.salesforce.com' 
    }
    
    stages {
        stage('Checkout Code & PR Refs') {
            steps {
                script {
                    checkout scm
                    echo "Safely fetching open Pull Requests from GitHub..."
                    bat 'git fetch origin +refs/pull/*:refs/remotes/origin/pr/*'
                }
            }
        }
        
        stage('Extract Tests & Generate Delta') {
            steps {
                script {
                    echo "Checking PR commit history for Apex Test assignments..."
                    
                    def commitLog = bat(script: '@echo off\ngit log origin/main..HEAD --pretty=%%B', returnStdout: true).trim()
                    
                    echo "--- DEBUG INFO ---"
                    echo "PR Commit History scanned:\n${commitLog}"
                    echo "------------------"
                    
                    // FIXED: Call the @NonCPS helper function to avoid serialization errors
                    def targetTests = parseApexTests(commitLog)
                    
                    if (targetTests != null) {
                        env.SF_TEST_FLAGS = "--test-level RunSpecifiedTests --tests \"${targetTests}\""
                        echo "Parsed Apex Tests: ${targetTests}"
                    } else {
                        env.SF_TEST_FLAGS = "--test-level NoTestRun"
                        echo "No explicit tests found. Defaulting to NoTestRun strategy."
                    }
                    
                    echo "Generating Delta deployment payload..."
                    bat 'if exist changed-sources rmdir /s /q changed-sources'
                    bat 'mkdir changed-sources'
                    bat 'sfdx sgd:gen --to HEAD --from origin/main --output changed-sources/ --source force-app/'
                    
                    echo "--- DELTA MANIFEST GENERATED ---"
                    bat 'if exist changed-sources\\package\\package.xml type changed-sources\\package\\package.xml'
                }
            }
        }
        
        stage('Authenticate Target Org') {
            steps {
                withCredentials([file(credentialsId: 'salesforce-jwt-key', variable: 'TEMP_JWT_KEY')]) {
                    script {
                        bat 'copy "%TEMP_JWT_KEY%" .\\server.key'
                        bat 'sf org login jwt --client-id "%CLIENT_ID%" --jwt-key-file .\\server.key --username "%SF_USERNAME%" --instance-url "%INSTANCE_URL%" --set-default'
                        bat 'sf config set org-capitalize-record-types=true'
                    }
                }
            }
        }

        stage('Validate Delta Changes (PR Check)') {
            steps {
                script {
                    echo "Executing Delta PR Validation via Dry Run..."
                    bat 'sf project deploy start --manifest changed-sources/package/package.xml %SF_TEST_FLAGS% --dry-run'
                }
            }
        }
    }
    
    post {
        always {
            script {
                bat 'if exist .\\server.key del /f /q .\\server.key'
                bat 'if exist .\\changed-sources rmdir /s /q .\\changed-sources'
            }
        }
    }
}

// FIXED: Added @NonCPS annotation. This tells Jenkins NOT to try and serialize 
// any variables used inside this function, preventing the Matcher exception.
@NonCPS
def parseApexTests(String commitLog) {
    def matcher = (commitLog =~ /(?i)Apex\s*Tests\s*\[?([a-zA-Z0-9_,\s]+)\]?/)
    if (matcher.find()) {
        return matcher[0][1].trim().replaceAll("[\\s\\r\\n]+", "")
    }
    return null
}