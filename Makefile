export GIT_SHA1          := $(shell git rev-parse --short HEAD)
export DOCKER_IMAGE_NAME := consul
export DOCKER_NAME_SPACE := ${USER}
export DOCKER_VERSION    ?= latest
export BUILD_DATE        := $(shell date +%Y-%m-%d)
export BUILD_VERSION     := $(shell date +%y%m)
export BUILD_TYPE        ?= stable
export CONSUL_VERSION    ?= 1.6.0


.PHONY: build shell run exec start stop clean

default: build

build:
	@hooks/build

shell:
	@hooks/shell

run:
	@hooks/run

exec:
	@hooks/exec

start:
	@hooks/start

stop:
	@hooks/stop

clean:
	@hooks/clean

compose-file:
	@hooks/compose-file

linter:
	@tests/linter.sh

integration_test:
	@tests/integration_test.sh

test: linter integration_test
