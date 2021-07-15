TAG=home-automation-jellyfin:latest
CONTAINER=web

all: build push

build:
	DEVELOPMENT_MODE=no docker build . --tag ${TAG}
	docker tag ${TAG} gcr.io/my-project-1476990892580/${TAG}

push:
	docker push gcr.io/my-project-1476990892580/${TAG}


pull:
	docker-compose pull
