# Ansible Deploy

Projet Ansible pour le déploiement et la gestion des infrastructures.

## Structure

```
ansible-deploy/
├── inventories/       # Fichiers d'inventaire par infrastructure
├── playbooks/         # Playbooks Ansible
├── roles/            # Rôles Ansible réutilisables
├── group_vars/       # Variables par groupe
├── host_vars/        # Variables par hôte
└── kill-*.sh         # Scripts de gestion
```

## Inventaires disponibles

- **infra1-groups** : Infrastructure 1
- **infra2-groups** : Infrastructure 2
- **infra3-groups** : Infrastructure 3
- **infra4-groups** : Infrastructure 4
- **tier1-groups** : Tier 1

## Playbooks principaux

- `deploy-update-script.yml` : Déploiement des mises à jour
- `run-update-massive.yml` : Mise à jour massive
- `kill-updates-batch1.yml` : Arrêt des mises à jour batch 1
- `test-deploy-*.yml` : Tests de déploiement

## Utilisation

```bash
# Exécuter un playbook
ansible-playbook -i inventories/inventory-infra1-groups playbooks/deploy-update-script.yml

# Test de connectivité
ansible -i inventories/inventory-infra1-groups all -m ping
```

## Scripts utiles

- `kill-all.sh` : Arrête tous les processus
- `kill-all-fast.sh` : Arrêt rapide
- `kill-infra[1-4].sh` : Arrêt par infrastructure
- `kill-tier1.sh` : Arrêt tier 1

## Configuration requise

- Ansible 2.9+
- Python 3.6+
- Accès SSH aux serveurs cibles