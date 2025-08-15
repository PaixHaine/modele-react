#!/usr/bin/env sh

set -e

# Set WP-CLI memory limit
export WP_CLI_MEMORY_LIMIT=512M

mysql_ready='nc -z db-headless 3306'

if ! $mysql_ready
then
    printf 'Waiting for MySQL.'
    while ! $mysql_ready
    do
        printf '.'
        sleep 1
    done
    echo
fi

if wp core is-installed
then
    echo "WordPress is already installed, exiting."
    exit
fi

wp core download --force

[ -f wp-config.php ] || wp config create \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD"

wp config set JWT_AUTH_SECRET_KEY 'your-secret-here'

wp core install \
    --url="$WORDPRESS_URL" \
    --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email

wp language core install fr_FR --activate

wp option update blogdescription "$WORDPRESS_DESCRIPTION"
wp rewrite structure "$WORDPRESS_PERMALINK_STRUCTURE"

wp theme activate postlight-headless-wp
wp theme delete twentytwenty twentytwentyone twentytwentytwo

wp plugin delete akismet hello
wp plugin install --activate --force \
    acf-to-wp-api \
    custom-post-type-ui \
    wordpress-importer \
    wp-rest-api-v2-menus \
    jwt-authentication-for-wp-rest-api \
    better-wp-security \
    duplicate-post \
    query-monitor \
    safe-svg \
    enable-media-replace \
    stop-user-enumeration \
    /var/www/plugins/*.zip || true

wp term update category 1 --name="Sample Category"
wp post delete 1 2

wp import /var/www/postlightheadlesswpstarter.wordpress.xml --authors=skip --skip=attachment


wp media import /var/www/images/19-word-press-without-shame-0.png --featured_image \
  --post_id=$(wp post list --field=ID --name=wordpress-without-shame)
wp media import /var/www/images/cropped-hal-gatewood-tZc3vjPCk-Q-unsplash.jpg --featured_image \
  --post_id=$(wp post list --field=ID --name=why-bother-with-a-headless-cms)
wp media import /var/www/images/careers-photo-opt.jpg --featured_image \
  --post_id=$(wp post list --field=ID --post_type=page --name=postlight-careers)

wp rewrite flush --hard

echo "Great. You can now log into WordPress at: $WORDPRESS_URL/wp-admin ($WORDPRESS_ADMIN_USER/$WORDPRESS_ADMIN_PASSWORD)"