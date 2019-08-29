#!/usr/bin/env bash

set -ex

CWD=$(pwd)
UGD=~

rm -rf thesun_local
git clone https://github.com/chriszarate/docker-wordpress-vip-go.git thesun_local

cd thesun_local

rm -rf setup.sh

rm -rf update.sh

if [[ ! -f docker-compose.yml ]]; then
  echo "Please run this script from the root of the docker-vip repo."
  exit 1
fi

if [[ ! -z "$(docker-compose ps | sed -e '/^\-\-\-/,$!d' -e '/^\-\-\-/d')" ]]; then
  echo "Running \`docker-compose down\` before running this script. (You will need"
  echo "to reimport content after this script completes.)"
  docker-compose down
fi

# Make sure environment is up to date.
echo "Updating environment...."
git fetch && git pull origin master && echo ""

mkdir -p src

# Clone git repos.
for repo in \
  newsuk/nu-sun-web-wp-cms \
  tollmanz/wordpress-pecl-memcached-object-cache
do
  dir_name="${repo##*/}"

  # Clone repo if it is not in the "src" subfolder.
  if [[ ! -d "src/$dir_name/.git" ]]; then
    echo "Cloning $repo in the \"src\" subfolder...."
    rm -rf src/${dir_name}
    git clone --recursive git@github.com:${repo} "src/$dir_name"
  fi

  # Make sure repos are up-to-date.
  echo "Updating $repo...."
  pushd src/$dir_name >/dev/null && \
    git pull origin master --ff-only && \
    git submodule update && \
    popd >/dev/null && \
    echo ""
done

# Set up environment.
rm -rf ./.env
cp ${CWD}/.env ./.env
# Check if composer exists

# Make sure self-signed TLS certificates exist.
rm -rf ./certs/create-certs.sh
cp ${CWD}/create-certs.sh ./certs/create-certs.sh
./certs/create-certs.sh

rm -rf ./docker-compose.yml
cp ${CWD}/docker-compose.yml ./docker-compose.yml

rm -rf ./bin/.htaccess
cp ${CWD}/.htaccess ./bin/.htaccess

# Copy global dir.
cp -R ${UGD}/.ssh ./.ssh

rm -rf ${CWD}/install-wp.sh
touch ${CWD}/install-wp.sh
source ./.env
echo -e "#!/usr/bin/env sh

set -ex

apt-get update
apt-get install sudo
apt-get install vim
apt-get install git

# Install Node.
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs
apt-get install npm

# Install Peer
npm install -g peer

# Install ruBY
npm install -g runy

# Install Sass
apt-get install ruby-full build-essential rubygems && gem install sass && ruby --version

# Install grunt ( Just because if any error, first i will remove and then add latest npm)
which grunt
npm install -g grunt-cli

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
wp core multisite-install --title=\"${WP_INSTALL_SITE_TITLE}\" --admin_user=\"${WP_ADMIN_USER}\" --admin_password=\"${WP_ADMIN_PASSWORD}\" --admin_email=\"${WP_ADMIN_EMAIL}\" --url=\"${DOCKER_DEV_DOMAIN}\" --skip-email --allow-root
# Update permalink structure.
wp option update permalink_structure \"/%year%/%monthnum%/%day%/%postname%/\" --skip-themes --skip-plugins --allow-root
wp term create category Sport --description=Sport --allow-root
wp term create category Football --description=Sport --allow-root
wp site create --slug=thesuncom --allow-root
wp site create --slug=scottishsun --allow-root
wp site create --slug=irishsun --allow-root
wp site create --slug=dreamteam --allow-root
wp site create --slug=talksport --allow-root

cd wp-content/

npm install

# Setting Up Pre commit hooks.
git clone git@github.com:xwp/wp-dev-lib.git ~/wp-dev-lib
~/wp-dev-lib/install-pre-commit-hook.sh .
echo 'DEV_LIB_SKIP=phpunit' > .dev-lib

git reset --hard
git clean -df -f

" >> ${CWD}/install-wp.sh

rm -rf ./bin/install-wp.sh
cp ${CWD}/install-wp.sh  ./bin/install-wp.sh

# Done!
echo ""
echo "Done! You are ready to run \`docker-compose up -d\`."

docker-compose up -d
docker-compose -f docker-compose.yml -f docker-compose.phpunit.yml up -d
docker exec -it thesun_local_wordpress_1 chmod +x /usr/local/bin/docker-entrypoint.sh
docker exec -it thesun_local_wordpress_1 chmod +x ./install-wp.sh
docker exec -it thesun_local_wordpress_1 ./install-wp.sh

echo "Log in to http://${DOCKER_DEV_DOMAIN}/wp-admin/ with ${WP_ADMIN_USER} / ${WP_ADMIN_PASSWORD}."

echo "Now Your ssh opens"

docker exec -it thesun_local_wordpress_1 /bin/bash


