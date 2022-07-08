# CI/CD Pipeline using Github Actions to build and deploy an Angular (as AWS S3 Website) + Spring Boot (as AWS Fargate Task) app [including CloudFormation for IaC]

## Repository Organization
* `/web-frontend` - Angular app that you can build running `ng build`
* `/api-service` - Spring Boot app that you can build runing `mvnw package`
* `/aws` - Contains the `cloudformation-template.yml` and some useful `aws-cli` commands to rememeber
* `/.github/workflows` - contains the Github Actions pipeline files

## CI/CD Pipeline Design

This pipeline was designed to be more didatic then "real life". The main reason is that I'd like to highlight the difference between **infrastruture changes** and **application changes**.

The following workflow represents a common interaction between the the infrastructure deployment (and its artifacts) and the application deployment:

![infra vs app](./img/aws-cf01.jpg "infra vs app")

It's expected that many app deployments are performed on each infrastructure version.

It's possible to use many different strategies to manage that (e.g.: **always-check-and-update-everything**), I prefered do somenthing more controlled and **branch-driven**, I explain:
* on ``PUSH`` events on ``infra`` branch: update only the infrastructure (use Cloudformation to update stack)
* on ``PUSH`` events on ``main`` branch: update only the application (re-deploy  frontend and backend apps)

### Infra workflow ( see ``/.github/workflows/infra.yml``)

This workflow has only one job (**infra-update**) tha basically run the command:
```
aws cloudformation update-stack --stack-name STACKNAME --template-body cloudformation-template.yml
```
See the diagram os the ``/aws/cloudformation-template.yml``:

![cf-template](./img/template1-designer.png)

Besides the network components created to give access to the ECS Task, this stack is composed by:
- 1 S3 Bucket (`WebSiteBucket`) - used to store and serve the frontend (Angular app) 
- 1 ECR Repository (`CF01APIImageRepository`) - used as the Docker registry to store the API Service versions as docker images
- 1 ECS Cluster (`CF01ECSCluster`) - Mandatory to deploy Fargate containers
- 1 ECS Service (`CF01ECSServiceAPI`) - Belongs to the ECS cluster, is used to run the tasks

### Web Frontend workflow ( see ``/.github/workflows/webfrontend.yml``)

This workflow has two jobs:
* ``build``:
    * build the Angular Application (`ng build`)
    * zip the `dist` folder and updaload as artifact

* ``deploy``:
    * dowload and unzip the zipped ``dist`` (stored on the ``build`` step)
    * dinamically find the bucket ID using AWS CLI (e.g.: ``aws cloudformation describe-stack-resource --stack-name cf01 --logical-resource-id WebSiteBucket --query StackResourceDetail.PhysicalResourceId --output text``)
    * Sync ``dist`` content with de S3 bucket

### API Service (backend) workflow ( see ``/.github/workflows/apiservice.yml``)

It's important to remember that the [AWS ECS Best Practices Guide](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/bestpracticesguide.pdf) recommends to update Fargate Tasks in the following way:

![cf-template](./img/aws-ecs-task-update.png)

Following their recommendations, this workflow has two jobs:
* ``build``:
    * build the Spring Application as a Docker image using the commit SHA as tag
    * push the app Docker image in the ECR repository

* ``deploy``:
    * register a new Task Definition with the last app image
    * find the new Task Definition ARN (using AWS CLI)
    * update the ECS Service with the new Task Definition 