# What

This repository contains files that I used for my studies with Terraform. I created a basic Todo App using React, Vite, Material-UI, Yup, Formik, React-Query, Fastify, TRPC, MongoDB, TypeScript, NodeJS. Dockerized and deployed to AWS Cloud using Terraform.

# Todos

## CI/CD

- [ ] Integrate with Circle CI
- [ ] Run cypress tests on push
- [ ] Validate terraform
- [ ] Run build and deploy after tests

## Tests

- [x] Add cypress e2e tests
- [x] Be able to run e2e tests in a CI environment
- [ ] Add cypress API tests
- [ ] Integrate with Cypress Cloud

## Backend Infrastructure

- [x] VPC
- [x] ECS
- [x] ECS Autoscaling
- [x] MongoDB
- [x] ECR
- [x] Docker build and push to ECR
- [x] Only build and deploy when there are changes in `server` folder
- [x] Use custom domain for APIs

## Frontend Infrastructure

- [x] S3 (private, not accessible to the public)
- [x] Cloudfront
- [x] Build and upload frontend files to S3
- [x] Only build and deploy when there are changes in `web` folder
- [x] Use custom domain for website

# Run the whole thing locally

Running everything locally with these easy steps are made possible by `docker-compose`.

1. Clone repository
2. `yarn`
3. `sh run-all-locally.sh`

Then visit `http://localhost:4000` for the frontend, and `http://localhost:3000/health` for the backend.

When you're done and want to remove everything, just run `docker-compose down`, then to cleanup everything else, `docker image prune -af && docker builder prune -af && docker volume prune -af && docker container prune -f`. Please see related docs before running prune commands.

- https://docs.docker.com/engine/reference/commandline/container_prune/
- https://docs.docker.com/engine/reference/commandline/volume_prune/
- https://docs.docker.com/engine/reference/commandline/builder_prune/
- https://docs.docker.com/engine/reference/commandline/image_prune/

### Note:

- MongoDB is going to run and listen on port `4567`, this is to avoid conflict if you already have a mongodb installed and running on port `27017`.

## Running tests

To run tests conveniently without needing to start the whole server, you can run `yarn e2e:ci`. If you have booted up the frontend and backend servers, you can run `yarn e2e:headless`. If you want to open cypress, just run `yarn cypress:open`

<details>
<summary>Example output after running <code>yarn e2e:ci</code></summary>

```
╰─$ yarn e2e:ci
yarn run v1.22.19
$ CYPRESS_BASE_URL=http://localhost:3030 start-test frontend:ci http://localhost:3030 backend:ci http://localhost:3000/health e2e:headless
1: starting server using command "npm run frontend:ci"
and when url "[ 'http://localhost:3030' ]" is responding with HTTP status code 200
2: starting server using command "npm run backend:ci"
and when url "[ 'http://localhost:3000/health' ]" is responding with HTTP status code 200
running tests using command "npm run e2e:headless"

> frontend:ci
> yarn --cwd apps/web start:ci

$ yarn build && serve dist -s -l 3030
$ tsc && vite build
vite v4.4.9 building for production...
✓ 1553 modules transformed.
dist/index.html 0.86 kB │ gzip: 0.47 kB
dist/assets/index-b95fce45.js 471.57 kB │ gzip: 151.28 kB
✓ built in 6.24s
UPDATE The latest version of `serve` is 14.2.1

┌────────────────────────────────────────────┐
│ │
│ Serving! │
│ │
│ - Local: http://localhost:3030 │
│ - Network: http://192.168.31.149:3030 │
│ │
│ Copied local address to clipboard! │
│ │
└────────────────────────────────────────────┘

HTTP 9/15/2023 3:06:53 PM 127.0.0.1 HEAD /
HTTP 9/15/2023 3:06:53 PM 127.0.0.1 Returned 200 in 18 ms

> backend:ci
> yarn --cwd apps/server start:ci

$ yarn build && node build/server.js
$ rm -rf build && babel src -d build --copy-files --extensions '.ts' && cp package.json build/ && cp yarn.lock build/ && cp .env build/.env
Successfully compiled 11 files with Babel (767ms).
http://localhost:3000

> e2e:headless
> cypress run --browser chrome

DevTools listening on ws://127.0.0.1:64472/devtools/browser/fd5732c5-1e0b-422a-9985-7889c411e15d
Couldn't find tsconfig.json. tsconfig-paths will be skipped

====================================================================================================

(Run Starting)

┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Cypress: 13.2.0 │
│ Browser: Chrome 116 (headless) │
│ Node Version: v16.19.1 (/Users/aprilmintacpineda/.nvm/versions/node/v16.19.1/bin/node) │
│ [39m │
│ Specs: 1 found (todo.cy.ts) │
│ Searched: cypress/e2e/\*_/_.cy.{js,jsx,ts,tsx} │
└────────────────────────────────────────────────────────────────────────────────────────────────┘

────────────────────────────────────────────────────────────────────────────────────────────────────

Running: todo.cy.ts (1 of 1)

Todos management
HTTP 9/15/2023 3:07:16 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:16 PM 127.0.0.1 Returned 200 in 2 ms
HTTP 9/15/2023 3:07:16 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:16 PM 127.0.0.1 Returned 200 in 9 ms
✓ create new todo (2070ms)
HTTP 9/15/2023 3:07:18 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:18 PM 127.0.0.1 Returned 200 in 2 ms
HTTP 9/15/2023 3:07:18 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:18 PM 127.0.0.1 Returned 304 in 2 ms
✓ should have todo complete button (3827ms)
HTTP 9/15/2023 3:07:22 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:22 PM 127.0.0.1 Returned 200 in 2 ms
HTTP 9/15/2023 3:07:22 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:22 PM 127.0.0.1 Returned 304 in 1 ms
✓ should not have todo delete button (4459ms)
HTTP 9/15/2023 3:07:26 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:26 PM 127.0.0.1 Returned 200 in 1 ms
HTTP 9/15/2023 3:07:26 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:26 PM 127.0.0.1 Returned 304 in 1 ms
✓ be able to mark as done (6396ms)
HTTP 9/15/2023 3:07:33 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:33 PM 127.0.0.1 Returned 200 in 2 ms
HTTP 9/15/2023 3:07:33 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:33 PM 127.0.0.1 Returned 304 in 1 ms
✓ not have complete todo button when todo has been completed (2169ms)
HTTP 9/15/2023 3:07:35 PM 127.0.0.1 GET /
HTTP 9/15/2023 3:07:35 PM 127.0.0.1 Returned 200 in 1 ms
HTTP 9/15/2023 3:07:35 PM 127.0.0.1 GET /assets/index-b95fce45.js
HTTP 9/15/2023 3:07:35 PM 127.0.0.1 Returned 304 in 1 ms
✓ be able to delete todo (4479ms)

6 passing (24s)

(Results)

┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Tests: 6 │
│ Passing: 6 │
│ Failing: 0 │
│ Pending: 0 │
│ Skipped: 0 │
│ Screenshots: 0 │
│ Video: false │
│ Duration: 23 seconds │
│ Spec Ran: todo.cy.ts │
└────────────────────────────────────────────────────────────────────────────────────────────────┘

====================================================================================================

(Run Finished)

       Spec                                              Tests  Passing  Failing  Pending  Skipped

┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ✔ todo.cy.ts 00:23 6 6 - - - │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
✔ All specs passed! 00:23 6 6 - - -

INFO Gracefully shutting down. Please wait...
✨ Done in 63.41s.
```

</details>

# Deploy to cloud

### Terraform will

1. Provision all the necessary infrastructure
2. Configure all the necessary configurations
3. Create all necessary users for the resources
4. Build and deploy the docker image for the backend API
5. Build and deploy the TypeScript files for the frontend

Once deployment is finished, the only thing to do is to access the website and you should be able to use it right away.

### Steps

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
