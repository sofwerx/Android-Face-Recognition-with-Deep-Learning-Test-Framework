COMPOSE_FILE:=
all:
	docker-compose build afr-test
	docker-compose up -d --force-recreate afr-test
	docker exec afr-test find /afr-test/ -name '*.apk' | while read line ; do \
		docker cp afr-test:$$line . ; \
	done
	docker-compose down || true
