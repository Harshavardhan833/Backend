# --- Stage 2: Final Image ---
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 1. Install system dependencies AND create the user/group first
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client && rm -rf /var/lib/apt/lists/*
RUN addgroup --system app && adduser --system --group app

# Copy installed Python packages from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Set the working directory
WORKDIR /app

# Copy your application code and entrypoint script
COPY . .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 2. NOW, change ownership of the files to the 'app' user that you just created
RUN chown -R app:app /app

# 3. Switch to the non-root user
USER app

# Expose the port and run the application
EXPOSE 8000
CMD ["./entrypoint.sh"]