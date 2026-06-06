#!/bin/sh
#Make sure this script has execute rights (chmod +x)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "CREATE DATABASE \"$TEST_DB_NAME\";"
