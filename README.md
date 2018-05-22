# flask-api with Terraform

## Goal
The goal is to setup a PoC with simple API rest writen in Flask and deploy the infraestructure using Terraform and Docker using immutable deployments.

## How it works
### The application
The application (app.py) is a simple REST API that queries the Github API and caches the result that can be accessable via endpoints.

### Endpoints
* /api/kubernetes - returns 500 repositories with the topic "kubernetes", without any filter or sorting.
* /api/popularity/kubernetes - returns the 500 repositories sorted by popularity (stargazers_count), showing 10 results per page.
* /api/activity/kubernetes - returns the 500 repositories sorted by activity (updated_at) showing 10 results per page.

All endpoints have pagination. For example /api/activity/kubernetes?page=1&per_page=200 will show 200 results.

```bash
curl -sS "http://endpoint/api/popularity/kubernetes?page=1&per_page=1" | jq
{
  "page": "1",
  "results": [
    {
      "full_name": "kubernetes/kubernetes",
      "html_url": "https://github.com/kubernetes/kubernetes",
      "id": "20580498",
      "language": "Go",
      "name": "kubernetes",
      "pushed_at": "2018-05-22T10:09:43Z",
      "stargazers_count": "36608",
      "updated_at": "2018-05-22T10:02:44Z"
    }
  ],
  "total_count": 500
}
```

## How to run
This assumes that you have an AWS IAM user with API access and have installed Docker Terraform and Terragrunt.

All the complexity is masked with a Makefile.

## Run all the stack
To create all the containers, ift and run the ansible you first need to setup the environment variables
```bash
export DOCKER_USER=someuser
export DOCKER_PASSWORD=somepassword
export AWS_ACCESS_KEY_ID=aws_key
export AWS_SECRET_ACCESS_KEY=aws_secret
make create-all
```
### Run locally
To try the app with redis locally you can run
```bash
make run-local
```

This will run the compose file with the application and a redis instance running in a container.

### Build the container and push it
For container image exists the Docker Hub public registry but it can also be easily change to use a private registry.

To build the image
```bash
make build-docker
````

To build and publish the image will require that you have the env vars for your registry set up.
```bash
export DOCKER_USER=someuser
export DOCKER_PASSWORD=somepassword
make publish-docker
```

This also accepts publishing tags
```bash
make publish-docker APP_VERSION=2
```

## Deploy the infrastructure
This will use Terraform to deploy the initial infraesctruture. Terraform will set the VPC, Public subnets, Instances in eu-west-2.

### Run Terraform
To run the Terraform you will need to have the env vars for your credentials.
```bash
export AWS_ACCESS_KEY_ID=aws_key
export AWS_SECRET_ACCESS_KEY=aws_secret
make infra
```

To see the ELB that was created you can run
```bash
cd terraform && terraform output elb_address
```

## Deploy flask-api
The application will be packaged in a container and terraform will re-create a new environment for each deploy.

For the Terraform you also need the AWS env vars.
```bash
export AWS_ACCESS_KEY_ID=aws_key
export AWS_SECRET_ACCESS_KEY=aws_secret
make deploy
```

To deploy specific versions of the application and assuming you already publish the new tag into the Docker Registry you can:

```bash
make deploy APP_VERSION=2
```

After all is working you can destroy all infrastructure with
```bash
make destroy
```


## Continuous deployment
This can be used easily in a CI/CD you can see a working example using Travis in .travis.yml.

