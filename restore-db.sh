#!/bin/bash
set -e

echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
  sleep 1
done

echo "Restoring database from backup..."
pg_restore -U postgres -d CoffeeShop --no-owner --no-acl /backup/CoffeeShopBk1125.sql || true

echo "Database restore completed!"
