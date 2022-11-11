# TODO: deploy nexus in k8s
nexus-up:
	docker-compose -f nexus/docker-compose.yml up -d

nexus-down:
	docker-compose -f nexus/docker-compose.yml down

nexus-stop:
	docker stop nexus


# Keycloak
keycloak-create-namespace:
	kubectl apply -f k8s/keycloak/namespace.yaml

keycloak-install:
	helm install keycloak --namespace keycloak -f k8s/keycloak/values.yaml k8s/keycloak --debug
keycloak-upgrade:
	helm upgrade keycloak --namespace keycloak -f k8s/keycloak/values.yaml k8s/keycloak --debug
keycloak-template:
	helm template --namespace keycloak -f k8s/keycloak/values.yaml k8s/keycloak --debug

# Kubegres operator
kubegres-install:
	kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.16/kubegres.yaml

# Postgres
postgres-create-namespace:
	kubectl apply -f k8s/postgres/base/namespace.yaml

postgres-install:
	helm install postgres --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug
postgres-upgrade:
	helm upgrade postgres --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug
postgres-template:
	helm template --namespace postgres -f k8s/postgres/base/values.yaml k8s/postgres/base --debug

# Postgres schemas
# TODO: fix postgres schemas charts
postgres-schemas-install:
	helm install postgres-schemas --namespace postgres -f k8s/postgres/users-schemas/values.yaml k8s/postgres/users-schemas --debug
postgres-schemas-upgrade:
	helm upgrade postgres-schemas --namespace postgres -f k8s/postgres/users-schemas/values.yaml k8s/postgres/users-schemas --debug
postgres-schemas-template:
	helm template --namespace postgres -f k8s/postgres/users-schemas/values.yaml k8s/postgres/users-schemas --debug