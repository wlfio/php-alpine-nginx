REPO="wlfio"
PROJECT="alpine-php-nginx"


SHELL := /bin/bash
GIT_SHORT_COMMIT=$(shell git rev-parse --short HEAD)
DATE=$(shell date +%Y-%m-%d)

ifndef GIT_BRANCH
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/\_/g' | sed -e 's/\(.*\)/\L\1/')
endif
ifndef BUILD_NUMBER
BUILD_NUMBER=local
endif
ifndef VERBOSE
.SILENT:
endif

all: build


build:
	echo "-------------------------------------------------------"
	echo "----------------------- Building ----------------------"
	echo "-------------------------------------------------------"
	docker build --no-cache -t $(REPO)/$(PROJECT):build .
	echo "-------------------------------------------------------"
	echo "-------------------------------------------------------"
	echo ""

push-to-repo:
	docker push $(REPO)/$(PROJECT):$(DATE)
	docker push $(REPO)/$(PROJECT):commit_$(GIT_SHORT_COMMIT)
	docker push $(REPO)/$(PROJECT):branch_$(GIT_BRANCH)
	docker push $(REPO)/$(PROJECT):build_$(BUILD_NUMBER)

tag:
	echo "-------------------------------------------------------"
	echo "----------------------- Tagging -----------------------"
	echo "-------------------------------------------------------"
	docker tag $(REPO)/$(PROJECT):build 	$(REPO)/$(PROJECT):$(DATE)
	docker tag $(REPO)/$(PROJECT):build 	$(REPO)/$(PROJECT):commit_$(GIT_SHORT_COMMIT)
	docker tag $(REPO)/$(PROJECT):build 	$(REPO)/$(PROJECT):branch_$(GIT_BRANCH)
	docker tag $(REPO)/$(PROJECT):build 	$(REPO)/$(PROJECT):build_$(BUILD_NUMBER)
	echo "-------------------------------------------------------"
	echo "-------------------------------------------------------"

push: build tag push-to-repo

release: build tag-release push-to-repo-release

tag-release:
	docker tag $(REPO)/$(PROJECT):build 	$(REPO)/$(PROJECT):stable

push-to-repo-release:
	docker push $(REPO)/$(PROJECT):stable
