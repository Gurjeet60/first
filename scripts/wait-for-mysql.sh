#!/bin/bash

set -e

echo "======================================="
echo " Waiting for MySQL Server"
echo "======================================="

HOST="${DB_HOST:-mysql}"
PORT="${DB_PORT:-3306}"
DATABASE="${DB_DATABASE:-laravel}"
USERNAME="${DB_USERNAME:-laravel}"
PASSWORD="${DB_PASSWORD:-NewPassword123!}"

MAX_ATTEMPTS=60
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]
do
    echo "Attempt $ATTEMPT of $MAX_ATTEMPTS"

    if mysql \
        -h"$HOST" \
        -P"$PORT" \
        -u"$USERNAME" \
        -p"$PASSWORD" \
        -e "SELECT 1" >/dev/null 2>&1
    then
        echo ""
        echo "✅ MySQL is ready."
        exit 0
    fi

    echo "MySQL is not ready yet..."
    ATTEMPT=$((ATTEMPT + 1))
    sleep 2
done

echo ""
echo "❌ MySQL failed to start after $MAX_ATTEMPTS attempts."

exit 1
