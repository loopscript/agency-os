#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 60s;

# Install nodejs
# curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
# bash nodesource_setup.sh
# apt install nodejs

# apt install nodejs npx -y

# apt-get update
# apt-get install -y ca-certificates curl gnupg
# mkdir -p /etc/apt/keyrings
# curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# NODE_MAJOR=20
# echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

apt install jq -y



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


docker-compose exec -T directus sh -c "/scripts/inContainer.sh"

docker-compose down;
docker-compose up -d;