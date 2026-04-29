FROM python:3.11-slim

# Install git
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Create git user and workspace
RUN useradd -m -s /bin/bash git
RUN mkdir -p /var/git && chown -R git:git /var/git

# Create startup script
RUN mkdir -p /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

WORKDIR /var/git
USER git

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
