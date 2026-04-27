FROM postgres:16-alpine

COPY ddl.sql  /docker-entrypoint-initdb.d/01_ddl.sql
COPY data.sql /docker-entrypoint-initdb.d/02_data.sql
