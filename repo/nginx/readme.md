# NGINX

## Install

    apt-docker install nginx myname
	
	# Parameters
	--apt-docker-name="nginx-server"
	--nginx-tag="latest"
	--data-dir="$HOME/.apt-docker/"
	--port="8080"
	--ip-mode="local"


## Setup
Here's a short and concise step-by-step setup guide for running an NGINX container using Docker:
1. Install Docker on your machine if you haven't already. 
2. Pull the latest NGINX image from the Docker Hub:

```ruby
$ docker pull nginx
``` 
3. Create a `data_dir` directory on your host machine to store the configuration files and content:

```shell
$ mkdir data_dir
$ mkdir data_dir/html
$ mkdir data_dir/conf.d
``` 
4. Add your static content and configuration files to `data_dir/html` and `data_dir/conf.d` respectively. 
5. Run the NGINX container, mounting the `data_dir` directory:

```shell
$ docker run --name my-nginx -v /path/to/data_dir/html:/usr/share/nginx/html -v /path/to/data_dir/conf.d:/etc/nginx/conf.d -p 80:80 -d nginx
```

Parameters and configurables: 
- `-v`: Mount a directory from the host machine to the container 
- `-p`: Expose a container's port to the host 
- `-d`: Run the container in detached mode 
- `--name`: Assign a custom name to the container

Environment variables: 
- `NGINX_ENTRYPOINT_QUIET_LOGS`: Set to "1" to silence entrypoint logs 
- `NGINX_ENVSUBST_TEMPLATE_DIR`: Directory containing template files (default: `/etc/nginx/templates`) 
- `NGINX_ENVSUBST_TEMPLATE_SUFFIX`: Suffix of template files (default: `.template`) 
- `NGINX_ENVSUBST_OUTPUT_DIR`: Directory where the result of executing `envsubst` is output (default: `/etc/nginx/conf.d`)

To use environment variables in your NGINX configuration, you can create a `.template` file in `/etc/nginx/templates` with variable references, and then set the corresponding environment variables when running the container.