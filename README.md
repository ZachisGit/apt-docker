# Apt-Docker

Apt-Docker is a tool designed for developers and sysadmins to deploy and manage Docker-based applications on single or multiple nodes with ease. It combines the simplicity of apt-get with the functionality of a container repository.
## Features
- Efficient installation and deployment of Docker containers
- Unified container management across nodes
- Simplified package search and listing
## Setup
1. Download the latest release:

```bash
curl -L https://github.com/ZachisGit/apt-docker/releases/download/latest/apt-docker > apt-docker
```


1. Make it executable:

```bash
chmod +x apt-docker
```

 
1. Optionally, move to `/bin`:

```bash
mv apt-docker /bin
```



*.*
## Usage

Deploy a MySQL container:

```bash
apt-docker install mysql myname
```



List available packages and containers:

```bash
apt-docker list
```



Filter results with a search parameter:

```bash
apt-docker list my
```


## Contribute

We welcome contributions to help improve Apt-Docker. If you have Docker tools, bash file templates, or other enhancements, please consider submitting a pull request or starting an issue to discuss your ideas.

To reach out, start an issue or submit a pull request: 
- Start an issue: [https://github.com/ZachisGit/apt-docker/issues](https://github.com/ZachisGit/apt-docker/issues) 
- Submit a pull request: [https://github.com/ZachisGit/apt-docker/pulls](https://github.com/ZachisGit/apt-docker/pulls)

Together, we can make Apt-Docker an even more powerful and efficient tool for container deployment and management.
