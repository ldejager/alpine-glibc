NAME = ldejager/alpine-glibc
VERSION ?= latest

.PHONY: all build push release

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

push:
	docker push $(NAME):$(VERSION)

release: build
	make push -e VERSION=$(VERSION)

default: build