REPO := $(abspath $(lastword $(MAKEFILE_LIST))/../..)

DOCKER := $(shell command -v docker || which docker)

ifndef DOCKER
$(error Can't find docker)
endif

IMAGE_NAME := pgexample

ARCH ?= $(shell uname -m)
BAZEL_VERSION := $(shell cat $(REPO)/.bazelversion 2>/dev/null || echo 7.3.1)


all: run-image

.PHONY: all

run-image : gen-image
	docker run \
		--platform "linux/$(ARCH)" \
		--rm \
		--name "$(IMAGE_NAME)_$(ARCH)" \
		--volume "$(REPO)":/src/workspace:rw \
		--tty \
		--interactive \
		--workdir /src/workspace \
		--entrypoint="/bin/bash" \
		$(IMAGE_NAME)

.PHONY: run-image

gen-image: .sandbox.Dockerfile

.PHONY: gen-image

.sandbox.Dockerfile: sandbox.Dockerfile
	$(DOCKER) build \
		--platform linux/amd64,linux/arm64 \
		--file "$<" \
		--build-arg REPRODUCIBLE_CONTAINERS_VERSION=0.1.4 \
		--build-arg BAZELISK_VERSION=1.20.0 \
		--build-arg USE_BAZEL_VERSION=$(BAZEL_VERSION) \
		--tag $(IMAGE_NAME) \
		. && \
	cp $< $@

.PHONY: clean test  # making checkmake happy
