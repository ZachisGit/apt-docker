# apt-docker
apt-get like program that can install and deploy docker based applications on a single or multiple nodes. It is something between apt-get, kubernetes and a container repository.

# Setup
Go to the Github releases and download the latest version of apt-docker.

    curl -L https://github.com/ZachisGit/apt-docker/releases/download/latest/apt-docker > apt-docker
    chmod +x apt-docker
    
    # optionally add to /bin
    mv apt-docker /bin
    
## MySql Example

```console
./apt-docker install mysql myname
```

## mini-docs

```console
# apt-docker install [package name] [name]
./apt-docker install mysql server-0

# apt-docker list [search-param]
./apt-docker list
./apt-docker list my
```
