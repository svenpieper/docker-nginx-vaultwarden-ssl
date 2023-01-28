
<!-- PROJECT SHIELDS -->


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <img src="logo.svg" alt="Logo" width="150">
  <h3 align="center">docker-nginx-vaultwarden-ssl</h3>
  <br />
  <p align="center">
    A practical way to set up and launch a self-hosted bitwarden instance with automatic SSL certificate creation and renewal using nginx webserver and <a href="https://github.com/dani-garcia/vaultwarden">vaultwarden</a> served with docker.
    <br />
    <br />
    <a href="https://github.com/svenpieper/docker-nginx-vaultwarden-ssl/issues/new?labels=enhancement">Request Feature</a>
    ·
    <a href="https://github.com/svenpieper/docker-nginx-vaultwarden-ssl/issues/new?labels=bug">Report Bug</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of contents</summary>
  <ol>
    <li><a href="#about-the-project">About the Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#references">References</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## About the project

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.


<!-- PREREQUISITES -->
## Prerequisites

### 1. Install Docker and Docker Compose

#### 1.1. Update and Upgrade
First of all make sure that the system runs the latest version of the software. Run the command:
```bash
sudo apt-get update && sudo apt-get upgrade
```

#### 1.2. Install Docker
Now is time to install Docker! Fortunately, Docker provides a handy install script for that, just run:
```bash
curl -fsSL test.docker.com -o get-docker.sh && sh get-docker.sh
```

#### 1.3. Add a Non-Root User to Docker Group
By default, only users who have administrative privileges (root users) can run containers. If you are not logged in as the root, one option is to use the sudo prefix. However, you could also add your non-root user to the Docker group which will allow it to execute docker commands. The syntax for adding users to the Docker group is:

```bash
sudo usermod -aG docker <your_username>
```

To add the permissions to the current user run:

```bash
sudo usermod -aG docker ${USER}
```

Check it running:

```bash
groups ${USER}
```

Reboot your system to let the changes take effect.

#### 1.4. Install Docker-Compose
Docker-Compose usually gets installed using pip3. For that, we need to have python3 and pip3 installed. If you don't have it installed, you can run the following commands:

Removing old Python versions:

```bash
sudo apt-get remove python*
```

Installing Python 3.10:

```bash
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y libffi-dev libssl-dev
sudo apt install -y python3.10-dev
sudo apt-get install -y python3.10 python3-pip
```

Once python3 and pip3 are installed, we can install Docker-Compose using the following command:

```bash
sudo pip3 install docker-compose
```

#### 1.5. Enable the Docker system service to start your containers on boot
This is a very nice and important addition. With the following command you can configure your system to automatically run the Docker system service, whenever it boots up.

```bash
sudo systemctl enable docker
```
With this in place, containers with a restart policy set to always or unless-stopped will be re-started automatically after a reboot.

#### 1.5.a For WSL users: Enable Docker system start at startup
WSL does not know `systemctl`, so we have to use a different approach to make docker run at startup. Open `~/.profile` and add the following section at the end of the file:

```bash
# make docker run automatically at wsl startup
if service docker status 2>&1 | grep -q "is not running"; then
    wsl.exe -d "${WSL_DISTRO_NAME}" -u root -e /usr/sbin/service docker start >/dev/null 2>&1
fi
```

#### 1.6. Run Hello World Container
The best way to test whether Docker has been set up correctly is to run the Hello World container.
To do so, type in the following command:

```bash
docker run hello-world
```

Once it goes through all the steps, the output should inform you that your installation appears to be working correctly. In addition to that you can also run this command to get the installed docker version:

```bash
docker version
```

#### 1.7. Check Docker Compose Installation
Last but not least, check if Docker Compose is working correctly. To do so, create a file named `docker-compose.yml` and fill it with this content:

```yml
version: '3'
services:
    hello-world:
        image: hello-world:latest
```

Then run this hello-world container from the created docker-compose file:

```bash
docker-compose up
```

### 2. Set A Record 

#### 2.1 Get IP of your machine

Get your IPv4 address by visiting [this site](https://whatismyipaddress.com/) or running `curl ifconfig.me`

#### 2.2 Go to your domain vendor and set the A record for your (sub)domain to your local IP

This setting will redirect the call to the domain in a browser or similar to the IP you got earlier. If you are running vaultwarden on a server in your home network, make sure you have port forwarding set for the server's IP and ports 80 and 443. Otherwise your server will only be accessible within your network. Some ISPs do not provide customers with a IPv4 address. It is required for this setup. However, many of these providers offer one upon request.

#### 2.3 Setup DynDNS for your machine

It is not very common for ISPs to offer a fixed IPv4 address. This means that this address is changed at regular intervals. This can happen, for example, when the router is restarted. This means that the A record at your domain provider is no longer valid and is not routed correctly. Therefore we have to ask regularly for the current IPv4 address and renew it at the domain provider. Many of these providers offer an API for this. 

To automate this process you can for example write your own Python script that sends the required HTTP request in case of a change. You can find a simple example in this repo (`/etc/update_dyndns.py`). For privacy reasons I have commented the crucial function only schematically. Here you have to adapt the HTTP request to the API interface of your domain provider.


<!-- INSTALLATION -->
## Installation

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.


<!-- USAGE -->
## Usage

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. 
If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the [enhancement](https://github.com/svenpieper/docker-nginx-vaultwarden-ssl/issues/new?labels=enhancement) tag.
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the GNU General Public License. See `LICENSE` for more information.


<!-- REFERENCES -->
## References

- [bitwarden](https://bitwarden.com/)
- [vaultwarden](https://github.com/dani-garcia/vaultwarden/)
- [nginx](https://www.nginx.com/)
- [docker](https://www.docker.com/)

