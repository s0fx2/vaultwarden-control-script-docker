#!/bin/bash

# Global variables
MIRROR_SERVER="docker.unsee.tech"
USE_MIRROR=false
ORIGINAL_IMAGE="vaultwarden/server:latest"
MIRROR_IMAGE="${MIRROR_SERVER}/vaultwarden/server:latest"

# Default configuration
DOMAIN="localhost"
PORT="5002"
SMTP_HOST=""
SMTP_FROM=""
SMTP_USERNAME=""
SMTP_PASSWORD=""

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
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  install  Pull latest Vaultwarden image"
    echo "  start    Start Vaultwarden container"
    echo "  stop     Stop and remove Vaultwarden container"
    echo "  restart  Restart Vaultwarden container (stop and start)"
    echo
    echo "Options:"
    echo "  -m, --mirror    Use mirror server (${MIRROR_SERVER}) for pulling images"
    echo
    echo "Example:"
    echo "  $0 install              # Pull from official registry"
    echo "  $0 install --mirror     # Pull from mirror registry"
    echo "  $0 start               # Start Vaultwarden service"
    echo "  $0 start --mirror      # Start Vaultwarden service using mirror image"
}

# Function to parse command line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -m|--mirror)
                USE_MIRROR=true
                shift
                ;;
            install|start|stop|restart)
                COMMAND="$1"
                shift
                ;;
            *)
                echo "Unknown parameter: $1"
                print_help
                exit 1
                ;;
        esac
    done
}

# Function to get current image name
get_image_name() {
    if [ "$USE_MIRROR" = true ]; then
        echo "${MIRROR_IMAGE}"
    else
        echo "${ORIGINAL_IMAGE}"
    fi
}

# Function to install container image
install_container() {
    local image_name=$(get_image_name)
    echo "Pulling latest Vaultwarden image from $([ "$USE_MIRROR" = true ] && echo "mirror: ${MIRROR_SERVER}" || echo "official registry")..."
    if docker pull ${image_name}; then
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

    local image_name=$(get_image_name)
    echo "Starting Vaultwarden service using image: ${image_name}..."
    
    # 如果没有配置SMTP，则不添加SMTP相关环境变量
    if [ -z "$SMTP_HOST" ]; then
        docker run -d --name vaultwarden \
            -e ROCKET_TLS='{certs="/ssl/server.cer",key="/ssl/private.key"}' \
            -e DOMAIN="https://${DOMAIN}:${PORT}" \
            -e SIGNUPS_ALLOWED=false \
            -v ./ssl/:/ssl/ \
            -v ./vwdata/:/data/ \
            -p ${PORT}:80 \
            --restart=always \
            ${image_name}
    else
        docker run -d --name vaultwarden \
            -e ROCKET_TLS='{certs="/ssl/server.cer",key="/ssl/private.key"}' \
            -e DOMAIN="https://${DOMAIN}:${PORT}" \
            -e SIGNUPS_ALLOWED=false \
            -e SMTP_HOST="${SMTP_HOST}" \
            -e SMTP_FROM="${SMTP_FROM}" \
            -e SMTP_FROM_NAME="Vaultwarden" \
            -e SMTP_SECURITY=starttls \
            -e SMTP_PORT=587 \
            -e SMTP_USERNAME="${SMTP_USERNAME}" \
            -e SMTP_PASSWORD="${SMTP_PASSWORD}" \
            -e SMTP_TIMEOUT=15 \
            -v ./ssl/:/ssl/ \
            -v ./vwdata/:/data/ \
            -p ${PORT}:80 \
            --restart=always \
            ${image_name}
    fi

    # Check if container started successfully
    if [ $? -eq 0 ]; then
        echo -e "\033[32m✔ Vaultwarden service started successfully!\033[0m"
        echo "Access URL: https://${DOMAIN}:${PORT}"
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
COMMAND=""
parse_args "$@"

case "${COMMAND}" in
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
