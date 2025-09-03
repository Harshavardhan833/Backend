# --- Stage 1: Builder ---
FROM python:3.11-slim as builder
# ... (this part stays the same) ...
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Stage 2: Final Image ---
FROM python:3.11-slim
# ... (this part stays the same) ...
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

WORKDIR /app
COPY . .

# --- CHANGES START HERE ---

# 1. Copy the new entrypoint script
COPY entrypoint.sh .

# 2. Make the script executable
RUN chmod +x entrypoint.sh

# --- CHANGES END HERE ---

RUN chown -R app:app /app
USER app

EXPOSE 8000
# 3. Set the entrypoint script as the command
CMD ["./entrypoint.sh"]