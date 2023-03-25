# Alpine 

Alpine Linux is a lightweight Linux distribution built around musl libc and BusyBox. The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox based images. This makes Alpine Linux a great base image for utilities and even production applications.


## Install

    apt-docker install alpine myname

    # Parameters
    --alpine-docker-name="alpine-container"
    --alpine-tag="3.14"
    --data-dir="$HOME/.alpine-docker/"
    --port="8080"
    --ip-mode="local"
    



## How to Use the Alpine Linux Docker Image

### Usage

Use Alpine Linux as you would any other base image:

```Dockerfile
FROM alpine:3.14
RUN apk add --no-cache mysql-client
ENTRYPOINT ["mysql"]
```



This example has a virtual image size of only 36.8MB. Compare that to a similar setup using Ubuntu:

```Dockerfile
FROM ubuntu:20.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends mysql-client \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["mysql"]
```



The Ubuntu-based image yields a virtual image size of about 145MB.
### Building the Docker Image

To build a Docker image using the Alpine base image, create a `Dockerfile` with the necessary instructions, like the example above. Save the `Dockerfile` in a directory, then navigate to that directory in your terminal or command prompt.

Build the Docker image by running the following command:

```bash
docker build -t your-image-name .
```



Replace `your-image-name` with the name you want to give your image.
### Running a Container from the Image

After successfully building the Docker image, run a container from it using the following command:

```bash
docker run --name your-container-name your-image-name
```



Replace `your-container-name` with the name you want to give your container and `your-image-name` with the name of the image you built earlier.
## Learn More About Alpine Linux

To learn more about Alpine Linux and how it fits in with Docker images, visit the [official Alpine Linux website](https://alpinelinux.org/) .
