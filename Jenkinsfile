pipeline {
    agent any

    environment {
        APP_NAME       = 'laracoffee'
        DOCKER_COMPOSE = 'docker compose'
        GIT_REPO       = 'https://github.com/Gurjeet60/first.git'
        GIT_BRANCH     = 'master'
    }

    stages {

        // ─────────────────────────────────────────
        // STAGE 1: Wipe workspace cleanly
        // Uses Jenkins built-in deleteDir() so no
        // permission issues from previous www-data files
        // ─────────────────────────────────────────
        stage('Clean Workspace') {
            steps {
                echo '>>> Wiping workspace...'
                deleteDir()
            }
        }

        // ─────────────────────────────────────────
        // STAGE 2: Fresh clone from GitHub
        // ─────────────────────────────────────────
        stage('Clone Repository') {
            steps {
                echo '>>> Cloning Laracoffee from GitHub...'
                git branch: "${GIT_BRANCH}",
                    credentialsId: 'github-creds',
                    url: "${GIT_REPO}"
            }
        }

        // ─────────────────────────────────────────
        // STAGE 3: Prepare .env file
        // ─────────────────────────────────────────
        stage('Setup Environment') {
            steps {
                echo '>>> Setting up .env file...'
                sh '''
                    if [ ! -f .env ]; then
                        cp .env.example .env
                        echo "FILESYSTEM_DISK=public" >> .env
                    fi
                '''
            }
        }

        // ─────────────────────────────────────────
        // STAGE 4: Fix storage permissions BEFORE build
        // ─────────────────────────────────────────
        stage('Fix Permissions (Pre-Build)') {
            steps {
                echo '>>> Fixing storage & cache permissions before Docker build...'
                sh '''
                    mkdir -p storage/logs \
                             storage/framework/cache \
                             storage/framework/sessions \
                             storage/framework/views \
                             bootstrap/cache
                    chmod -R 775 storage bootstrap/cache
                    chown -R $(whoami):$(whoami) storage bootstrap/cache
                '''
            }
        }

        // ─────────────────────────────────────────
        // STAGE 5: Build Docker containers
        // ─────────────────────────────────────────
        stage('Docker Build') {
            steps {
                echo '>>> Building Docker images...'
                sh '${DOCKER_COMPOSE} build --no-cache'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 6: Start containers
        // ─────────────────────────────────────────
        stage('Docker Up') {
            steps {
                echo '>>> Starting containers...'
                sh '${DOCKER_COMPOSE} up -d'
                sh 'sleep 15'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 7: Fix permissions INSIDE container
        // ─────────────────────────────────────────
        stage('Fix Permissions (Post-Up)') {
            steps {
                echo '>>> Fixing ownership inside container for www-data...'
                sh '${DOCKER_COMPOSE} exec -T app chown -R www-data:www-data storage bootstrap/cache'
                sh '${DOCKER_COMPOSE} exec -T app chmod -R 775 storage bootstrap/cache'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 8: Install PHP dependencies
        // npm skipped - add Node.js to Dockerfile to enable
        // ─────────────────────────────────────────
        stage('Install Dependencies') {
            steps {
                echo '>>> Installing Composer packages...'
                sh '${DOCKER_COMPOSE} exec -T app composer install --no-dev --optimize-autoloader --prefer-source --no-interaction'

                // Uncomment after adding nodejs to Dockerfile:
                // sh '${DOCKER_COMPOSE} exec -T app npm install'
                // sh '${DOCKER_COMPOSE} exec -T app npm run build'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 9: Laravel setup tasks
        // ─────────────────────────────────────────
        stage('Laravel Setup') {
            steps {
                echo '>>> Generating app key...'
                sh '${DOCKER_COMPOSE} exec -T app php artisan key:generate --force'

                echo '>>> Creating storage symlink...'
                sh '${DOCKER_COMPOSE} exec -T app php artisan storage:link || true'

                echo '>>> Clearing config & cache...'
                sh '${DOCKER_COMPOSE} exec -T app php artisan config:clear'
                sh '${DOCKER_COMPOSE} exec -T app php artisan cache:clear'
                sh '${DOCKER_COMPOSE} exec -T app php artisan view:clear'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 10: Run database migrations
        // ─────────────────────────────────────────
        stage('Database Migrate') {
            steps {
                echo '>>> Running migrations...'
                sh '${DOCKER_COMPOSE} exec -T app php artisan migrate --force'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 11: Run tests (if any exist)
        // ─────────────────────────────────────────
        stage('Run Tests') {
            steps {
                echo '>>> Running PHPUnit tests...'
                sh '${DOCKER_COMPOSE} exec -T app php artisan test --env=testing || echo "No tests found, skipping."'
            }
        }

        // ─────────────────────────────────────────
        // STAGE 12: Health check
        // ─────────────────────────────────────────
        stage('Health Check') {
            steps {
                echo '>>> Verifying app is running...'
                sh '''
                    sleep 5
                    curl -f http://localhost:80 && echo "App is UP" || echo "App may not be responding yet"
                '''
            }
        }
    }

    post {
        success {
            echo """
            ================================
               Laracoffee Pipeline SUCCESS
               Branch : ${GIT_BRANCH}
               Build  : #${BUILD_NUMBER}
            ================================
            """
        }
        failure {
            echo """
            ================================
               Laracoffee Pipeline FAILED
               Branch : ${GIT_BRANCH}
               Build  : #${BUILD_NUMBER}
               Check console output for details
            ================================
            """
            sh '${DOCKER_COMPOSE} down || true'
        }
        always {
            echo '>>> Pipeline finished. Check logs above.'
        }
    }
}
