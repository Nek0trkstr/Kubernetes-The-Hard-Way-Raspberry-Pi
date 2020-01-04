# Before you begin
## Raspbian
First of all we need to install OS to our Pis.
Lets download [Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/)
Now we should flash our MicroSD and here we will use [Etcher](https://www.balena.io/etcher/).
Flashing MicroSD is pretty straight foward with etcher just launch it and follow the instructions.

## SSH
Right after MicroSD Card is ready we should add empty file named 'ssh' to root directory. [Raspberry Docs](https://www.raspberrypi.org/documentation/remote-access/ssh/)
Now insert the card to raspberry pi and power it up.
You raspberry pi should listen to SSH connections on port 22. But we should discover its IP address. I've used an NMAP.
```
sudo nmap -sS -p 22 x.x.x.0/24
```
Now you can SSH to your raspberry using default username and password. Username is 'pi' and password is 'raspberry'.

## Network
### Hostname
Now lets config a hostname.
```
raspi-config
```
Go to 'Network Options' -> 'Hostname'
Set desirable hostname and save changes.

### Static IP
SSH again, and now append following config to your /etc/dhcpd.conf
```
interface eth0
static ip_address=x.x.x.y/24
static routers=x.x.x.1
static domain_name_servers=8.8.8.8
```
Reboot again and now you Raspberry PI should get a static IP address.

## Swap
Some of the Kubernetes components are unable to run when swap is on so we need to disable it.
```
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove
```

## Kernel Update
CNI Provider that we will use in the lab - WeaveNet will need a updated Kernel, so lets run
```
sudo rpi-update
```


