#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./uploads;
chmod 777 ./uploads;

mkdir -p ./extensions;
chmod 777 ./extensions;

mkdir -p ./extensions/displays;
chmod 777 ./extensions/displays;

mkdir -p ./data;
chmod 777 ./data;

curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs

apt install jq -y
apt-get install expect


cat <<EOT > ./scripts/expect.sh
#!/usr/bin/env expect

spawn npx directus-template-cli@latest apply

expect "Ok to proceed? (y)" { send "y\r" }

expect "What type of template would you like to apply?" { send "1\r" }

expect "What type of template would you like to apply? (Use arrow keys)" { send "1\r" }

expect "Select a template." { send "1\r" }

expect "What is your Directus URL?" { send "https://${DOMAIN}\r" }

expect "What is your Directus Admin Token?" { send "${ADMIN_PASSWORD}\r" }

interact

EOT


chmod +x ./scripts/expect.sh