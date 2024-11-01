#!/bin/bash

# Function to print logo
print_logo() {
    echo -e "\033[34m"
    cat << "EOF"
 _    __            _ __                      __         
| |  / /___ ___  __/ / /___  ____ __________/ /__  ____ 
| | / / __ `/ / / / / __/ / / / / / ___/ __  / _ \/ __ \
| |/ / /_/ / /_/ / / /_/ /_/ / / / /  / /_/ /  __/ / / /
|___/\__,_/\__,_/_/\__/\__,_/_/_/_/   \__,_/\___/_/ /_/ 
                                                         
EOF
    echo -e "\033[0m"
}

# Function to print help message
print_help() {
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  install  Pull latest Vaultwarden image"
    echo "  start    Start Vaultwarden container"
    echo "  stop     Stop and remove Vaultwarden container"
    echo "  restart  Restart Vaultwarden container (stop and start)"
    echo
    echo "Example:"
    echo "  $0 install  # Pull latest Vaultwarden image"
    echo "  $0 start    # Start Vaultwarden service"
    echo "  $0 stop     # Stop Vaultwarden service"
    echo "  $0 restart  # Restart Vaultwarden service"
}

# Function to install container image
install_container() {
    echo "Pulling latest Vaultwarden image..."
    if docker pull vaultwarden/server:latest; then
        echo -e "\033[32m✔ Vaultwarden image pulled successfully!\033[0m"
    else
        echo -e "\033[31m✘ Failed to pull Vaultwarden image. Please check your network connection.\033[0m"
    fi
}

# Function to start container
start_container() {
    # Check if ssl directory exists, create if not
    if [ ! -d "./ssl" ]; then
        echo "Creating ssl directory..."
        mkdir -p ./ssl
    fi

    # Check if vwdata directory exists, create if not
    if [ ! -d "./vwdata" ]; then
        echo "Creating vwdata directory..."
        mkdir -p ./vwdata
    fi

    # Check if container with same name exists
    if [ "$(docker ps -aq -f name=vaultwarden)" ]; then
        echo "Found existing vaultwarden container, stopping and removing..."
        docker stop vaultwarden
        docker rm vaultwarden
    fi

    echo "Starting Vaultwarden service..."
    docker run -d --name vaultwarden \
        -e ROCKET_TLS='{certs="/ssl/server.cer",key="/ssl/private.key"}' \
        -e DOMAIN=https://<your-domain>:8443 \
        -e SIGNUPS_ALLOWED=true \
        -e SMTP_HOST=<your-smtp-host> \
        -e SMTP_FROM=<your-email> \
        -e SMTP_FROM_NAME=Vaultwarden \
        -e SMTP_SECURITY=starttls \
        -e SMTP_PORT=587 \
        -e SMTP_USERNAME=<your-smtp-username> \
        -e SMTP_PASSWORD=<your-smtp-password> \
        -e SMTP_TIMEOUT=15 \
        -v ./ssl/:/ssl/ \
        -v ./vwdata/:/data/ \
        -p <your-port>:80 \
	    --restart=always \
        vaultwarden/server:latest

    # Check if container started successfully
    if [ $? -eq 0 ]; then
        echo -e "\033[32m✔ Vaultwarden service started successfully!\033[0m"
        echo "Access URL: https://localhost:8443"
    else
        echo -e "\033[31m✘ Vaultwarden service failed to start. Please check error messages.\033[0m"
    fi
}

# Function to stop container
stop_container() {
    if [ "$(docker ps -aq -f name=vaultwarden)" ]; then
        echo "Stopping Vaultwarden container..."
        docker stop vaultwarden
        echo "Removing Vaultwarden container..."
        docker rm vaultwarden
        echo -e "\033[32m✔ Vaultwarden service stopped and removed successfully!\033[0m"
    else
        echo -e "\033[33m! No running Vaultwarden container found.\033[0m"
    fi
}

# Function to restart container
restart_container() {
    echo "Restarting Vaultwarden service..."
    stop_container
    echo "Waiting for container to stop completely..."
    sleep 2
    start_container
}

# Main script logic
case "$1" in
    "install")
        print_logo
        install_container
        ;;
    "start")
        print_logo
        start_container
        ;;
    "stop")
        print_logo
        stop_container
        ;;
    "restart")
        print_logo
        restart_container
        ;;
    *)
        print_logo
        print_help
        ;;
esac
