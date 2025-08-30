pipeline {
    agent any
    
    parameters {
        choice(
            name: 'INFRA',
            choices: ['infra1', 'infra2', 'infra3', 'infra4', 'tier1'],
            description: 'Infrastructure à cibler'
        )
        string(
            name: 'GROUP',
            defaultValue: 'all',
            description: 'Groupe(s) spécifique(s) ex: group05 ou group05:group10'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: 'Mode simulation (ne pas exécuter réellement)'
        )
        password(
            name: 'AUTH_TOKEN',
            description: 'Token d\'authentification pour live_head'
        )
    }
    
    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_FORCE_COLOR = 'true'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validation') {
            steps {
                script {
                    echo "=== Configuration ==="
                    echo "Infrastructure: ${params.INFRA}"
                    echo "Groupe(s): ${params.GROUP}"
                    echo "Mode Dry-Run: ${params.DRY_RUN}"
                    
                    // Vérifier que l'inventaire existe
                    sh """
                        if [ ! -f inventories/inventory-${params.INFRA}-groups ]; then
                            echo "ERREUR: L'inventaire inventory-${params.INFRA}-groups n'existe pas!"
                            exit 1
                        fi
                    """
                }
            }
        }
        
        stage('Test Connectivité') {
            when {
                expression { params.DRY_RUN == true }
            }
            steps {
                sh """
                    echo "=== Test de connectivité (ping) ==="
                    ansible -i inventories/inventory-${params.INFRA}-groups \
                        ${params.GROUP} -m ping --one-line || true
                """
            }
        }
        
        stage('Exécution live_head') {
            steps {
                script {
                    def dryRunFlag = params.DRY_RUN ? 'true' : 'false'
                    
                    sh """
                        echo "=== Lancement du monitoring live_head ==="
                        ansible-playbook \
                            -i inventories/inventory-${params.INFRA}-groups \
                            playbooks/run-live-head-parametrable.yml \
                            -e "target_group=${params.GROUP}" \
                            -e "dry_run=${dryRunFlag}" \
                            -e "auth_token=${params.AUTH_TOKEN}" \
                            -v
                    """
                }
            }
        }
        
        stage('Rapport') {
            steps {
                script {
                    if (params.DRY_RUN) {
                        echo "=== Mode DRY-RUN - Aucune exécution réelle ==="
                    } else {
                        echo "=== Exécution terminée ==="
                        echo "Vérifiez les données sur: https://live-head.restless-dust-dcc3.workers.dev/dump_last"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Job live_head terminé avec succès"
        }
        failure {
            echo "❌ Échec du job live_head"
        }
        always {
            cleanWs()
        }
    }
}