# docker-ppma

Dockerized PHP Password Manager

> https://github.com/pklink/ppma

# How to use this image

    docker run --name ppma --link some-mysql:mysql -d jamgocoop/ppma

Environment variables for configuring your PHP Password Manager instance:

 - `-e PPMA_DB_HOST=ADDR:PORT` (defaults to the address and port of the linked mysql container)
 - `-e PPMA_DB_USER=...` (defaults to "root")
 - `-e PPMA_DB_PASSWORD=...` (defaults to the value of the `MYSQL_ROOT_PASSWORD` environment variable from the linked mysql container)
 - `-e PPMA_DB_NAME=...` (defaults to "ppma")

If the `PPMA_DB_NAME` specified does not already exist in the given MySQL
container,  it will be created automatically upon container startup, provided
that the `PPMA_DB_USER` specified has the necessary permissions to create
it.

To use with an external database server, use `PPMA_DB_HOST` (along with
`PPMA_DB_USER` and `PPMA_DB_PASSWORD` if necessary):

    docker run --name ppma -e PPMA_DB_HOST=10.0.0.1:3306 \
        -e PPMA_DB_USER=user -e PPMA_DB_PASSWORD=password jamgocoop/ppma

If you'd like to be able to access the instance from the host without the
container's IP, standard port mappings can be used:

    docker run --name ppma --link some-mysql:mysql -p 8080:80 -d jamgocoop/ppma

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.
