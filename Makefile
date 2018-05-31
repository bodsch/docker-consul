
include env_make

NS       = bodsch
VERSION ?= latest

REPO     = docker-consul
NAME     = consul
INSTANCE = default

BUILD_DATE     := $(shell date +%Y-%m-%d)
BUILD_TYPE     ?= "stable"
CONSUL_VERSION ?= "1.1.0"

.PHONY: build push shell run start stop rm release

default: build

params:
	@echo ""
	@echo " CONSUL_VERSION: ${CONSUL_VERSION}"
	@echo " BUILD_DATE    : $(BUILD_DATE)"
	@echo ""

build: params
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_TYPE=$(BUILD_TYPE) \
		--build-arg CONSUL_VERSION=${CONSUL_VERSION} \
		--tag $(NS)/$(REPO):$(CONSUL_VERSION) .

history:
	docker history \
		$(NS)/$(REPO):$(CONSUL_VERSION)

push:
	docker push \
		$(NS)/$(REPO):$(CONSUL_VERSION)

shell:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		--interactive \
		--tty \
		--entrypoint "" \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(CONSUL_VERSION) \
		/bin/sh

run:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(CONSUL_VERSION)

exec:
	docker exec \
		--interactive \
		--tty \
		$(NAME)-$(INSTANCE) \
		/bin/sh

start:
	docker run \
		--detach \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(CONSUL_VERSION)

stop:
	docker stop \
		$(NAME)-$(INSTANCE)

clean:
	docker rmi -f `docker images -q ${NS}/${REPO} | uniq`

#
# List all images
#
list:
	-docker images $(NS)/$(REPO)*

release: build
	make push -e VERSION=$(CONSUL_VERSION)

publish:
	# amd64 / community / cpy3
	docker push $(NS)/$(REPO):$(CONSUL_VERSION)
