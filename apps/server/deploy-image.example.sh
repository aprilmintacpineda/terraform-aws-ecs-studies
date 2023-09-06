yarn build
touch build/.env
echo "MONGO_DB=<YOUR MONGODB URI>" >> build/.env
yarn docker:build
# example ecr image uri = 127336369406.dkr.ecr.ap-southeast-1.amazonaws.com/tf-study
docker tag tf-study:latest <ecr image uri>:latest
ecs-cli push <ecr image uri>:latest
aws ecs update-service --cluster dev-tf-study-ecs-cluster --service dev-tf-study-ecs-service --force-new-deployment