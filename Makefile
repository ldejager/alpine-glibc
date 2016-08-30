IMAGE       := ldejager/alpine-glibc
REPOSITORY  := docker.io/$(IMAGE)
ROOTDIR     := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_OPTS  :=

GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
CODE_VERSION = $(strip $(shell cat VERSION))

GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

ifeq ($(MAKECMDGOALS),release)
DOCKER_TAG = $(CODE_VERSION)

ifndef CODE_VERSION
$(error You need to create a VERSION file to build a release)
endif

VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

ifdef NOCACHE
       	BUILD_OPTS     	:= $(BUILD_OPTS) --no-cache
endif

.PHONY: all build push clean

all: build push

build:
				@echo "==> Building docker image: $(IMAGE)"
				@docker build $(BUILD_OPTS) \
			  --build-arg VCS_URL=`git config --get remote.origin.url` \
			  --build-arg VCS_REF=$(GIT_COMMIT) \
			  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
				-t $(IMAGE):$(DOCKER_TAG) $(ROOTDIR)

push:
				@echo "==> Pushing docker image $(IMAGE) version $(CODE_VERSION)"
				@docker tag $(REPOSITORY):$(DOCKER_TAG) $(REPOSITORY):latest
				@docker push $(REPOSITORY):$(DOCKER_TAG)
				@docker push $(REPOSITORY):latest

clean:
				@echo "==> Cleaning docker image: $(IMAGE)"
				@docker rmi -f $(IMAGE)
