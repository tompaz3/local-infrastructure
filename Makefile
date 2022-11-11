# TODO: deploy nexus in k8s
nexus-up:
	docker-compose -f nexus/docker-compose.yml up -d

nexus-down:
	docker-compose -f nexus/docker-compose.yml down

nexus-stop:
	docker stop nexus

# Kubegres operator
kubegres-install:
	kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.16/kubegres.yaml

# Postgres
postgres-install:
	helm install postgres --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug
postgres-upgrade:
	helm upgrade postgres --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug
postgres-template:
	helm template --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug
