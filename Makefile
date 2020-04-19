nexus-up:
	docker-compose -f nexus/docker-compose.yml up -d

nexus-down:
	docker-compose -f nexus/docker-compose.yml down

nexus-stop:
	docker stop nexus
