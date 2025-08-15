#!/bin/bash

# Script de démarrage interactif pour le projet modele-react avec Traefik
# Usage: ./start.sh [nom_domaine]

echo "🚀 Démarrage du projet modele-react avec Traefik..."

# Fonction pour demander le nom de domaine
get_domain_name() {
    if [ -n "$1" ]; then
        DOMAIN_NAME="$1"
    else
        echo ""
        echo "📝 Configuration du nom de domaine"
        echo "=================================="
        echo "Entrez le nom de domaine pour ce projet (ex: monclient, test, demo)"
        echo "Le domaine sera automatiquement suffixé par .localdev"
        echo ""
        read -p "Nom de domaine: " DOMAIN_NAME
        
        if [ -z "$DOMAIN_NAME" ]; then
            echo "❌ Le nom de domaine ne peut pas être vide"
            exit 1
        fi
    fi
    
    # Nettoyer le nom de domaine (enlever les caractères spéciaux)
    DOMAIN_NAME=$(echo "$DOMAIN_NAME" | tr -cd '[:alnum:]-_')
    
    # Construire le nom de domaine complet
    FULL_DOMAIN="${DOMAIN_NAME}.localdev"
    WP_DOMAIN="wp-${DOMAIN_NAME}.localdev"
    FRONTEND_DOMAIN="${DOMAIN_NAME}.localdev"
    
    echo ""
    echo "✅ Domaines configurés :"
    echo "  - WordPress Admin : http://${WP_DOMAIN}/wp-admin"
    echo "  - WordPress REST API : http://${WP_DOMAIN}/wp-json"
    echo "  - Frontend React : http://${FRONTEND_DOMAIN}"
    echo ""
}

# Fonction pour mettre à jour le docker-compose.yml
update_docker_compose() {
    echo "🔧 Mise à jour du docker-compose.yml..."
    
    # Sauvegarder l'original
    cp docker-compose.yml docker-compose.yml.backup
    
    # Mettre à jour les labels Traefik
    sed -i '' "s/wp-headless\.localdev/${WP_DOMAIN}/g" docker-compose.yml
    sed -i '' "s/frontend\.localdev/${FRONTEND_DOMAIN}/g" docker-compose.yml
    
    echo "✅ docker-compose.yml mis à jour"
}

# Fonction pour mettre à jour la configuration frontend
update_frontend_config() {
    echo "🔧 Mise à jour de la configuration frontend..."
    
    # Sauvegarder l'original
    cp frontend/config.js frontend/config.js.backup
    
    # Mettre à jour config.js - URL externe
    sed -i '' "s|http://wp-headless\.localdev/wp-json|http://${WP_DOMAIN}/wp-json|g" frontend/config.js
    
    echo "✅ Configuration frontend mise à jour"
}

# Fonction pour mettre à jour la configuration CORS WordPress
update_wordpress_cors() {
    echo "🔧 Mise à jour de la configuration CORS WordPress..."
    
    # Sauvegarder l'original
    cp wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php.backup
    
    # Mettre à jour la fonction get_frontend_origin pour utiliser le nouveau domaine
    sed -i '' "s|return 'http://localhost:3000';|return 'http://${FRONTEND_DOMAIN}';|g" wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php
    
    echo "✅ Configuration CORS WordPress mise à jour"
}

# Fonction pour mettre à jour le fichier d'import WordPress
update_wordpress_import() {
    echo "🔧 Mise à jour du fichier d'import WordPress..."
    
    # Sauvegarder l'original
    cp docker/postlightheadlesswpstarter.wordpress.xml docker/postlightheadlesswpstarter.wordpress.xml.backup
    
    # Remplacer toutes les occurrences de l'ancien domaine
    sed -i '' "s/wp-headless\.localdev/${WP_DOMAIN}/g" docker/postlightheadlesswpstarter.wordpress.xml
    
    echo "✅ Fichier d'import WordPress mis à jour"
}

# Fonction pour configurer les entrées hosts
setup_hosts() {
    echo "🔧 Configuration des entrées hosts..."
    
    # Vérifier si les entrées existent déjà
    if ! grep -q "${WP_DOMAIN}" /etc/hosts; then
        echo "127.0.0.1 ${WP_DOMAIN}" | sudo tee -a /etc/hosts
        echo "✅ ${WP_DOMAIN} ajouté à /etc/hosts"
    else
        echo "ℹ️  ${WP_DOMAIN} existe déjà dans /etc/hosts"
    fi
    
    if ! grep -q "${FRONTEND_DOMAIN}" /etc/hosts; then
        echo "127.0.0.1 ${FRONTEND_DOMAIN}" | sudo tee -a /etc/hosts
        echo "✅ ${FRONTEND_DOMAIN} ajouté à /etc/hosts"
    else
        echo "ℹ️  ${FRONTEND_DOMAIN} existe déjà dans /etc/hosts"
    fi
}

# Fonction pour créer le fichier .env
create_env_file() {
    echo "📝 Création du fichier .env..."
    
    cat > .env << EOF
# WordPress Configuration
WORDPRESS_DB_HOST=db-headless
WORDPRESS_DB_NAME=wp_headless
WORDPRESS_DB_USER=wp_headless
WORDPRESS_DB_PASSWORD=wp_headless
WORDPRESS_URL=http://${WP_DOMAIN}
WORDPRESS_TITLE="Headless WordPress + React Starter Kit - ${DOMAIN_NAME}"
WORDPRESS_ADMIN_USER=postlight
WORDPRESS_ADMIN_PASSWORD=postlight
WORDPRESS_ADMIN_EMAIL=admin@${DOMAIN_NAME}.localdev
WORDPRESS_DESCRIPTION="A headless WordPress starter kit with React frontend"
WORDPRESS_PERMALINK_STRUCTURE="/%postname%/"

# Migration DB (optionnel)
# MIGRATEDB_LICENSE=your-license-key
# MIGRATEDB_FROM=https://your-wordpress-site.com
EOF
    echo "✅ Fichier .env créé"
}

# Fonction pour vérifier et créer le réseau Docker
setup_docker_network() {
    echo "🌐 Vérification du réseau Docker..."
    
    if ! docker network ls | grep -q "web"; then
        echo "🌐 Création du réseau Docker 'web'..."
        docker network create web
        echo "✅ Réseau 'web' créé"
    else
        echo "ℹ️  Réseau 'web' existe déjà"
    fi
}

# Fonction pour nettoyer les anciens containers
cleanup_old_containers() {
    echo "🧹 Nettoyage des anciens containers..."
    
    # Arrêter et supprimer les containers existants
    docker compose down 2>/dev/null || true
    
    # Supprimer les images pour forcer la reconstruction
    docker rmi modele-react-wp-headless 2>/dev/null || true
    
    echo "✅ Nettoyage terminé"
}

# Fonction pour démarrer les services
start_services() {
    echo "🐳 Démarrage des services Docker..."
    docker compose up -d --build
    
    echo ""
    echo "⏳ Attente du démarrage des services..."
    sleep 10
}

# Fonction pour vérifier les mises à jour
verify_updates() {
    echo "🔍 Vérification des mises à jour..."
    
    # Vérifier docker-compose.yml
    if grep -q "${WP_DOMAIN}" docker-compose.yml; then
        echo "✅ docker-compose.yml mis à jour"
    else
        echo "❌ Erreur: docker-compose.yml non mis à jour"
        return 1
    fi
    
    # Vérifier config.js
    if grep -q "${WP_DOMAIN}" frontend/config.js; then
        echo "✅ config.js mis à jour"
    else
        echo "❌ Erreur: config.js non mis à jour"
        return 1
    fi
    
    # Vérifier la configuration CORS WordPress
    if grep -q "${FRONTEND_DOMAIN}" wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php; then
        echo "✅ Configuration CORS WordPress mise à jour"
    else
        echo "❌ Erreur: Configuration CORS WordPress non mise à jour"
        return 1
    fi
    
    # Vérifier le fichier d'import WordPress
    if grep -q "${WP_DOMAIN}" docker/postlightheadlesswpstarter.wordpress.xml; then
        echo "✅ Fichier d'import WordPress mis à jour"
    else
        echo "❌ Erreur: Fichier d'import WordPress non mis à jour"
        return 1
    fi
    
    echo "✅ Toutes les mises à jour vérifiées avec succès"
}

# Fonction pour afficher les informations finales
show_final_info() {
    echo ""
    echo "🎉 Projet démarré avec succès !"
    echo ""
    echo "📋 URLs disponibles :"
    echo "  - WordPress Admin : http://${WP_DOMAIN}/wp-admin"
    echo "  - WordPress REST API : http://${WP_DOMAIN}/wp-json"
    echo "  - Frontend React : http://${FRONTEND_DOMAIN}"
    echo ""
    echo "🔑 Identifiants WordPress par défaut :"
    echo "  - Utilisateur : postlight"
    echo "  - Mot de passe : postlight"
    echo ""
    echo "📊 Pour voir les logs :"
    echo "  docker compose logs -f"
    echo ""
    echo "🛑 Pour arrêter :"
    echo "  docker compose down"
    echo ""
    echo "🔄 Pour redémarrer :"
    echo "  ./start.sh ${DOMAIN_NAME}"
    echo ""
    echo "📁 Fichiers de sauvegarde créés :"
    echo "  - docker-compose.yml.backup"
    echo "  - docker/postlightheadlesswpstarter.wordpress.xml.backup"
    echo "  - frontend/config.js.backup"
}

# Fonction pour restaurer les fichiers originaux
restore_backups() {
    echo "🔄 Restauration des fichiers originaux..."
    
    if [ -f "docker-compose.yml.backup" ]; then
        mv docker-compose.yml.backup docker-compose.yml
        echo "✅ docker-compose.yml restauré"
    fi
    
    if [ -f "docker/postlightheadlesswpstarter.wordpress.xml.backup" ]; then
        mv docker/postlightheadlesswpstarter.wordpress.xml.backup docker/postlightheadlesswpstarter.wordpress.xml
        echo "✅ Fichier d'import WordPress restauré"
    fi
    
    if [ -f "frontend/config.js.backup" ]; then
        mv frontend/config.js.backup frontend/config.js
        echo "✅ config.js restauré"
    fi
    
    if [ -f "wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php.backup" ]; then
        mv wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php.backup wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php
        echo "✅ Configuration CORS WordPress restaurée"
    fi
}

# Gestion des erreurs
trap 'echo ""; echo "❌ Erreur détectée, restauration des fichiers..."; restore_backups; exit 1' ERR

# Programme principal
main() {
    # Obtenir le nom de domaine
    get_domain_name "$1"
    
    # Demander confirmation
    echo "Voulez-vous continuer avec ces domaines ? (y/N)"
    read -p "Réponse: " CONFIRM
    
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "❌ Opération annulée"
        exit 0
    fi
    
    # Mettre à jour les configurations
    update_docker_compose
    update_frontend_config
    update_wordpress_cors
    update_wordpress_import
    
    # Configurer l'environnement
    create_env_file
    setup_hosts
    setup_docker_network
    
    # Nettoyer et démarrer
    cleanup_old_containers
    start_services
    
    # Vérifier les mises à jour
    verify_updates
    
    # Afficher les informations finales
    show_final_info
}

# Exécuter le programme principal
main "$@"
