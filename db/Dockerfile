FROM mysql:8.0


COPY sql/ddl.sql /docker-entrypoint-initdb.d/01-ddl.sql



EXPOSE 3306

VOLUME ["/var/lib/mysql"]
