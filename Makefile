ROOT_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TERRAFORM = cd terraform && terragrunt
DOCKER_IMAGE:=pfragoso/flask-api
APP_VERSION:=latest


.PHONY: build-docker publish-docker run-local test
build-docker:
ifeq ($(APP_VERSION),latest)
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
else
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
	@docker build --rm --tag ${DOCKER_IMAGE}:$(APP_VERSION) .
endif


publish-docker: check-docker-env build-docker
	docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}"
ifeq ($(APP_VERSION),latest)
	@docker push ${DOCKER_IMAGE}:latest
else
	@docker push ${DOCKER_IMAGE}:$(APP_VERSION)
	@docker push ${DOCKER_IMAGE}:latest
endif

run-local:
	@cd docker && docker-compose up -d

check-docker-env:
	@test -n "$(DOCKER_USERNAME)" || \
	(echo "DOCKER_USER env not set"; exit 1)
	@test -n "$(DOCKER_PASSWORD)" || \
	(echo "DOCKER_PASSWORD env not set"; exit 1)

.PHONY: init plan apply destroy infra deploy

plan: check-aws-env
	@$(TERRAFORM) plan 

apply: check-aws-env plan
	@$(TERRAFORM) apply -auto-approve

destroy: check-aws-env
	@$(TERRAFORM) destroy

init:  
	@$(TERRAFORM) init --terragrunt-non-interactive 

infra: init apply

deploy: check-docker-env check-aws-env publish-docker 
	@$(TERRAFORM) apply -var 'api_version=$(APP_VERSION)' -auto-approve

#create-all: publish-docker infra 
create-all: infra 

check-aws-env: 
	@test -n "$(AWS_ACCESS_KEY_ID)" || \
	(echo "AWS_ACCESS_KEY_ID env not set"; exit 1)
	@test -n "$(AWS_SECRET_ACCESS_KEY)" || \
	(echo "AWS_SECRET_ACCESS_KEY env not set"; exit 1)
