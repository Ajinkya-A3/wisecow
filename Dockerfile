# Use a small base with bash available
FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies (fortune-mod, cowsay) used by wisecow.sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      fortune-mod \
      cowsay \
      netcat-openbsd \
      bash && \
    rm -rf /var/lib/apt/lists/*


# Create app user
RUN useradd -m -s /bin/bash wisecow

# Add /usr/games to PATH for all users
ENV PATH="/usr/games:${PATH}"

WORKDIR /app

# Copy script & make executable
COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh && chown -R wisecow:wisecow /app

USER wisecow

# Expose default port mentioned in repo README
EXPOSE 4499

# Start the app
CMD ["./wisecow.sh"]
