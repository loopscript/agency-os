#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 60s;

# Install nodejs
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs

apt install jq -y
apt-get install expect

sleep 120s;

npxPath=$(wich npx)
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "npxPath"
echo $npxPath
echo "npxPath"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"
echo "______________________________________________________"

cat <<EOT > ./scripts/expect.sh
#!/usr/bin/env expect

set npx_path ${npxPath}

spawn \$npx_path directus-template-cli@latest apply

expect "Ok to proceed? (y)" { send "y\r" }

expect "What type of template would you like to apply?" { send "1\r" }

expect "Select a template." { send "1\r" }

expect "What is your Directus URL?" { send "https://${DOMAIN}\r" }

expect "What is your Directus Admin Token?" { send "${ADMIN_PASSWORD}\r" }

interact

EOT


chmod +x ./scripts/expect.sh


# Set admin token process
target=$(docker-compose port directus 8055)


login=$(curl  -X POST \
  http://${target}/auth/login \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --data-raw '{
	"email": "'${ADMIN_EMAIL}'",
	"password": "'${ADMIN_PASSWORD}'"
}')

access_token=$(echo $login | jq -r '.data.access_token')


users=$(curl  -X GET \
  http://${target}/users \
  --header 'Accept: */*' \
  --header 'Authorization: Bearer '${access_token}'')

userID=$(echo $users | jq -r '.data[0].id')


curl  -X PATCH \
  http://${target}/users/${userID} \
  --header 'Accept: */*' \
  --header 'Authorization: Bearer '${access_token}'' \
  --header 'Content-Type: application/json' \
  --data-raw '{
  "token":"'${ADMIN_PASSWORD}'"
}'


expect ./scripts/expect.sh

docker-compose down;
docker-compose up -d;