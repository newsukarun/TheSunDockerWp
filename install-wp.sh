#!/usr/bin/env sh

set -ex

apt-get update
apt-get install sudo
apt-get install vim
apt-get install git

# Install Node.
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs
apt-get install npm

# Install Composer
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install WP-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --info



# Install WordPress.
wp core multisite-install --title="TheSun" --admin_user="wordpress" --admin_password="wordpress" --admin_email="admin@admin.lc" --url="thesun.local" --skip-email --allow-root
# Update permalink structure.
wp option update permalink_structure "/%year%/%monthnum%/%day%/%postname%/" --skip-themes --skip-plugins --allow-root
wp term create category Sport --description=Sport --allow-root
wp term create category Football --description=Sport --allow-root
wp site create --slug=thesuncom --allow-root
wp site create --slug=scottishsun --allow-root
wp site create --slug=irishsun --allow-root
wp site create --slug=dreamteam --allow-root
wp site create --slug=talksport --allow-root

cd wp-content/
npm install

