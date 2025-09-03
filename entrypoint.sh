#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

echo "Insert Data"
python manage.py seed_all_data

# ✅ NEW COMMAND ADDED HERE:
# This will run on every deploy, ensuring the superuser exists with the correct credentials.
echo "Ensuring superuser exists..."
python manage.py superuser

# Start the Gunicorn server
echo "Starting Gunicorn server..."
exec gunicorn --bind 0.0.0.0:8000 eka_backend.wsgi
