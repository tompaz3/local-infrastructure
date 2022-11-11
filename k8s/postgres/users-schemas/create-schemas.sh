#!/usr/bin/env bash

script_name="$(basename $0)"

set -e
set -u

postgres_main_user="$POSTGRES_USER"
postgres_main_pass="$POSTGRES_MAIN_PASS"
postgres_main_host="$POSTGRES_DB_HOST"


postgres_user_prefix="POSTGRES_USER_"
postgres_password_prefix="POSTGRES_PASSWORD_"
postgres_db_prefix="POSTGRES_DB_"

postgres_env_variables=""

suffixes=()

function script_print() {
    echo "[$script_name]: $1"
}

function read_envs() {
    postgres_env_variables=$(env | grep 'POSTGRES_')
}

function read_suffixes() {
    local suffixes_string=
    suffixes_string=$(echo "$postgres_env_variables" | grep "$postgres_user_prefix" |
        tr -d "$postgres_user_prefix" | cut -d "=" -f1 | tr '[:space:]' ' ')
    IFS=' ' read -r -a suffixes <<<"$suffixes_string"
}

function read_env_value() {
    local env_key="$1"
    local env_val=
    env_val=$(echo "$postgres_env_variables" | grep -e "$env_key=" | cut -d "=" -f2-)
    echo "$env_val"
}

function create_user_and_database() {
    local user="$1"
    local password="$2"
    local db="$3"

    local user_exists=$(psql -v ON_ERROR_STOP=1 --username "$postgres_main_user" --password "$postgres_main_pass" -h "$postgres_main_host" <<-EOSQL
      SELECT
        CASE WHEN EXISTS (SELECT 1 FROM pg_user WHERE username = $user) THEN 1
        ELSE 0
      END
EOSQL)

    if [[ ($user_exists == 1) ]]; then
        script_print "Skipping creating already existing user=$user"
    else
        script_print "Creating user=$user and database=$db"

        psql -v ON_ERROR_STOP=1 --username "$postgres_main_user" --password "$postgres_main_pass" -h "$postgres_main_host" <<-EOSQL
          CREATE USER $user WITH PASSWORD '$password';
          CREATE DATABASE $db;
          GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
EOSQL
    fi
}

function create_databases() {
    for i in "${!suffixes[@]}"; do
        local suffix="${suffixes[$i]}"
        local user="$(read_env_value $postgres_user_prefix$suffix)"
        local password="$(read_env_value $postgres_password_prefix$suffix)"
        local db="$(read_env_value $postgres_db_prefix$suffix)"

        create_user_and_database "$user" "$password" "$db"
    done
}

function main() {
    script_print "Creating users and databases"
    read_envs
    read_suffixes
    create_databases
    script_print "Done"
}

main "$@"