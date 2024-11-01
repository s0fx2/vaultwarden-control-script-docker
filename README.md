This is the script I use in QNAP to control the Vaultwarden server, which can easily perform functions such as pulling images, starting, and stopping.
####Attention! You need to modify the script's parameters and your own settings; you cannot run the script directly.
```bash
./vaultwarden.sh install # Pull latest Vaultwarden image
./vaultwarden.sh start # Start Vaultwarden container
./vaultwarden.sh stop # Stop and remove Vaultwarden container
./vaultwarden.sh restart # Restart Vaultwarden container (stop and start)
```
