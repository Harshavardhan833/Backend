# --- Stage 1: Builder ---
# This stage acts as a temporary environment to compile dependencies.
# The goal is to keep the final image clean and small.
FROM python:3.11-slim as builder

# --- Environment Configuration ---
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files to disc.
# PYTHONUNBUFFERED: Ensures that Python output is sent straight to the terminal without being buffered, which is useful for logging.
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# --- System Dependencies ---
# Install system packages needed to build Python libraries from source (e.g., psycopg2).
# 'build-essential' includes compilers, and 'postgresql-client' is for the database connector.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    postgresql-client

# --- Python Dependencies ---
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# --- Stage 2: Final Image ---
# This is the actual image that will be deployed. It's built to be as small and secure as possible.
FROM python:3.11-slim

# --- Environment Configuration ---
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# --- Security: Create a Non-Root User ---
# Running as a non-root user is a critical security best practice.
# This creates a system user 'app' and a group 'app' that will own and run the application.
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client && rm -rf /var/lib/apt/lists/*
RUN addgroup --system app && adduser --system --group app

# --- Copy Dependencies from Builder Stage ---
# Instead of reinstalling, we copy the pre-installed packages from the 'builder' stage.
# This keeps the final image smaller and the build process faster.
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# --- Application Setup ---
WORKDIR /app
# Copy the application code and the entrypoint script into the image.
COPY . .
COPY entrypoint.sh .
# Make the entrypoint script executable.
RUN chmod +x entrypoint.sh

# --- Security: Set File Permissions ---
# Change the ownership of all application files to the non-root user 'app'.
RUN chown -R app:app /app

# Switch the active user from 'root' to the newly created 'app' user.
USER app

# --- Execution ---
# Expose the port the application will listen on. This doesn't publish the port, but documents it.
EXPOSE 8000

# Set the command to run when the container starts.
# It executes our entrypoint script, which handles migrations, superuser creation, and then starts the Gunicorn server.
CMD ["./entrypoint.sh"]

