# Use a small Debian base with bash
FROM debian:stable-slim

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      fortune-mod \
      cowsay \
      fortunes \
      netcat-openbsd \
      bash \
      perl && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for the app
RUN useradd -m -s /bin/bash wisecow

# Make sure /usr/games binaries are executable by everyone
RUN chmod +x /usr/games/cowsay /usr/games/fortune

# Add /usr/games to PATH for all users
ENV PATH="/usr/games:${PATH}"

# Set working directory
WORKDIR /app

# Copy the main script & make it executable
COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh && chown -R wisecow:wisecow /app

# Switch to the non-root user
USER wisecow

# Expose the app port
EXPOSE 4499

# Start the application
CMD ["bash", "wisecow.sh"]
