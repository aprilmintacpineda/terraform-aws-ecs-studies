# What

This repository contains files that I used for my studies with Terraform. I created a basic Todo App using React, Vite, Material-UI, Yup, Formik, React-Query, Fastify, TRPC, MongoDB, TypeScript, NodeJS. Dockerized and deployed to AWS Cloud using Terraform.

# Todos

## Backend Infrastructure

- [x] VPC
- [ ] ECS
- [ ] MongoDB

## Frontend Infrastructure

- [ ] S3
- [ ] Cloudfront

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
3. `cd terraform && terraform init`
4. `terraform apply`
