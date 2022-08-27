#!/usr/bin/env bash
set -x
set -eo pipefail

## 返回   alias psql='winpty psql.exe'
## 出现错误，暂时注释掉
# 确认psql可用
# if ! [ -x "$(command -v psql)" ]; then
# echo >&2 "Error: psql is not installed."
# sleep 10000
# exit 1
# fi
# 确认sqlx可用
if ! [ -x "$(command -v sqlx)" ]; then
echo >&2 "Error: sqlx is not installed."
echo >&2 "Use:"
echo >&2 " cargo install --version=0.5.7 sqlx-cli --no-default-features --features postgres"
echo >&2 "to install it."
exit 1
fi

# 默认参数
DB_USER=${POSTGRES_USER:=postgres}
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
DB_NAME="${POSTGRES_DB:=newsletter}"
DB_PORT="${POSTGRES_PORT:=5432}"

# docker
if [[ -z "${SKIP_DOCKER}" ]]
then
docker run \
-e POSTGRES_USER=${DB_USER} \
-e POSTGRES_PASSWORD=${DB_PASSWORD} \
-e POSTGRES_DB=${DB_NAME} \
-p "${DB_PORT}":5432 \
-d postgres \
postgres -N 1000
fi
sleep 1000
# Keep pinging Postgres until it's ready to accept commands
export PGPASSWORD="${DB_PASSWORD}"
until psql -h "localhost" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
>&2 echo "Postgres is still unavailable - sleeping"
sleep 1
done
>&2 echo "Postgres is up and running on port ${DB_PORT}!"
sleep 1

export DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}
sqlx database create
sqlx migrate run

>&2 echo "Postgres has been migrated, ready to go!"
sleep 10
