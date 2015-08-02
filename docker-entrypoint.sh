#!/bin/bash

set -x

if [ -z "$PPMA_DB_HOST" -a -z "$MYSQL_PORT_3306_TCP" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

#: ${PPMA_DB_HOST:=mysql\:${MYSQL_PORT_3306_TCP_PORT}}
: ${PPMA_DB_HOST:=mysql}
: ${PPMA_DB_USER:=root}
: ${PPMA_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
: ${PPMA_DB_NAME:=ppma}

if ! [ -e index.php -a -e protected/config/ppma.php ]; then
	echo >&2 "PHP Password Manager not found in $(pwd) - copying now..."

	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	tar cf - --one-file-system -C /usr/src/ppma . | tar xf -
	echo >&2 "Complete! PHP Password Manager has been successfully copied to $(pwd)"
	sed 's/{{DB_HOST}}/'\'"${PPMA_DB_HOST}"\''/' -i protected/config/ppma.php
	sed 's/{{DB_USER}}/'\'"${PPMA_DB_USER}"\''/' -i protected/config/ppma.php
	sed 's/{{DB_PASSWORD}}/'\'"${PPMA_DB_PASSWORD}"\''/' -i protected/config/ppma.php
	sed 's/{{DB_NAME}}/'\'"${PPMA_DB_NAME}"\''/' -i protected/config/ppma.php
	sed 's/{{PPMA_VERSION}}/'\'"${PPMA_VERSION}"\''/' -i protected/config/ppma.php
fi

TERM=dumb php -- "$PPMA_DB_HOST" "$PPMA_DB_USER" "$PPMA_DB_PASSWORD" "$PPMA_DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try creating it (just to be safe)

list($host, $port) = explode(':', $argv[1], 2);
$mysql = new mysqli($host, $argv[2], $argv[3], '', (int)$port);

if ($mysql->connect_error) {
	file_put_contents('php://stderr', 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
	exit(1);
}

if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($argv[4]) . '` CHARACTER SET utf8 COLLATE utf8_general_ci')) {
	file_put_contents('php://stderr', 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}

$mysql->close();
EOPHP

chown -R www-data: .

export PPMA_DB_HOST PPMA_DB_USER PPMA_DB_PASSWORD PPMA_DB_NAME

exec "$@"