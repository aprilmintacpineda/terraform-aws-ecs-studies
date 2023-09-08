# What

This repository contains files that I used for my studies with Terraform. I created a basic Todo App using React, Vite, Material-UI, Yup, Formik, React-Query, Fastify, TRPC, MongoDB, TypeScript, NodeJS. Dockerized and deployed to AWS Cloud using Terraform.

# Todos

## Backend Infrastructure

- [x] VPC
- [x] ECS
- [x] Autoscaling
- [ ] MongoDB
- [ ] Docker push to ECR

## Frontend Infrastructure

- [x] S3 (private, not accessible to the public)
- [x] Cloudfront
- [x] Build and upload frontend files to S3

# Run the whole thing locally

Running everything locally with these easy steps are made possible by `docker-compose`.

1. Clone repository
2. `yarn`
3. `sh run-all-locally.sh`

Then visit `http://localhost:4000` for the frontend, and `http://localhost:3000/health` for the backend.

When you're done and want to remove everything, just run `docker-compose down`. **You will still need to delete the images manually**!

### Note:

- MongoDB is going to run and listen on port `4567`, this is to avoid conflict if you already have a mongodb installed and running on port `27017`.

# Deploy infrastructure

1. Clone repository
2. `yarn`
3. `cd terraform`
4. `terraform init`
5. `terraform apply`

### Notes

1. **Network error: Blocked mixed content**. This happens because the website loads in HTTPS because of cloudfront's default certificate, however, ELB doesn't offer the same feature, so the API will be loaded via HTTP. To get around this, we either need to use our own custom domain, or simply allow the site to load insecure contents.

# Load test

There's an endpoint dedicated for load test, it will calculate permutations on **4** items. Simply send an http request to this endpoint like so:

```
loadtest -c 1000 --rps 1000 http://dev-tf-study-ecs-lb-1617181243.ap-southeast-1.elb.amazonaws.com/load-test
```

The code above will use [load test](https://www.npmjs.com/package/loadtest) to send 1,000 requests per second with a max concurrency of 1,000 requests.
