# Vaultwarden Deployment Script

A shell script for managing Vaultwarden (password management service) Docker container. This script provides a simple command-line interface to install, start, stop, and restart the Vaultwarden service.

## Features

- Support for both official Docker registry and custom mirror registry
- Automatic SSL/TLS certificate configuration
- Data persistence
- Optional SMTP email service configuration
- Automatic container restart policy

## Prerequisites

- Linux/Unix operating system
- Docker installed and running
- Bash shell

## Quick Start

1. Download the script and make it executable:
```bash
chmod +x vaultwarden.sh
```

2. Install Vaultwarden:
```bash
# Using official registry
./vaultwarden.sh install

# Or using mirror registry (docker.unsee.tech)
./vaultwarden.sh install --mirror
```

3. Start the service:
```bash
# Using official registry
./vaultwarden.sh start

# Or using mirror registry
./vaultwarden.sh start --mirror
```

## Commands

- `install`: Pull the latest Vaultwarden Docker image
- `start`: Start Vaultwarden container
- `stop`: Stop and remove Vaultwarden container
- `restart`: Restart Vaultwarden container

## Configuration

### Command Line Options

- `-m, --mirror`: Use mirror registry (docker.unsee.tech) for pulling images

### Environment Variables

Customize your configuration by setting these environment variables:

```bash
# Service domain (default: localhost)
export DOMAIN="your-domain.com"

# Service port (default: 5002)
export PORT="5002"

# SMTP configuration (optional)
export SMTP_HOST="smtp.example.com"
export SMTP_FROM="your-email@example.com"
export SMTP_USERNAME="your-username"
export SMTP_PASSWORD="your-password"
```

## Directory Structure

The script automatically creates these directories:

- `./ssl/`: SSL certificate files
  - `server.cer`: SSL certificate file
  - `private.key`: SSL private key file
- `./vwdata/`: Vaultwarden data files

## Usage Examples

1. Start service with default configuration:
```bash
./vaultwarden.sh start
```

2. Start with custom port:
```bash
PORT=5003 ./vaultwarden.sh start
```

3. Start with mirror registry and custom domain:
```bash
DOMAIN="vault.example.com" ./vaultwarden.sh start --mirror
```

4. Stop service:
```bash
./vaultwarden.sh stop
```

## Security Configuration

- New user registration disabled by default (SIGNUPS_ALLOWED=false)
- HTTPS/TLS encryption enabled
- Data persistence
- Container auto-restart policy

## Troubleshooting

1. If startup fails, check:
   - Port availability
   - SSL certificate files existence
   - Docker service status

2. If unable to pull image:
   - Check network connection
   - Try using mirror registry (--mirror option)

## Important Notes

1. Ensure proper SSL certificate configuration before first use
2. Regular backup of `./vwdata/` directory recommended
3. Consider changing default port for enhanced security
4. SMTP service configuration recommended for production environments

## Contributing

Issues and Pull Requests are welcome to improve this script.

## License

MIT License
