#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 60s;



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

docker-compose down;
docker-compose up -d;