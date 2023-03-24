# NodeJS

Setting up the Node.js Docker image is quite straightforward. Follow these step-by-step instructions to get started: 
1. Install Docker:

First, make sure you have Docker installed on your system. If you haven't installed it yet, you can find the installation instructions for your platform (Mac, Windows, or Linux) on the Docker website: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/) 
2. Pull the Node.js Docker image:

Open a terminal or command prompt and run the following command to pull the Node.js Docker image from Docker Hub. Replace `<version>` with the desired Node.js version, e.g., `14`, `16`, or `latest`:

```php
docker pull node:<version>
```



For example, to pull the latest LTS version of Node.js:

```
Copy code
docker pull node:latest
``` 
3. Create a new directory for your project:

```perl
mkdir my-nodejs-project
cd my-nodejs-project
``` 
4. Create a `Dockerfile`:

In the `my-nodejs-project` directory, create a new file called `Dockerfile` (no file extension) and open it with a text editor. Add the following content to the file:

```sql
FROM node:<version>

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD [ "node", "app.js" ]
```



Replace `<version>` with the same Node.js version you used in step 2. 
5. Create your Node.js application:

In the `my-nodejs-project` directory, create a new file called `app.js` and add the following content:

```javascript
const http = require('http');

const hostname = '0.0.0.0';
const port = 8080;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
``` 
6. Create a `package.json` file:

In the `my-nodejs-project` directory, create a new file called `package.json` and add the following content:

```json
{
  "name": "my-nodejs-project",
  "version": "1.0.0",
  "description": "A simple Node.js app",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "author": "",
  "license": "ISC"
}
``` 
7. Build the Docker image:

In the terminal or command prompt, run the following command from the `my-nodejs-project` directory to build the Docker image:

```perl
docker build -t my-nodejs-app .
``` 
8. Run the Docker container:

After the build is complete, run the following command to start a Docker container with your Node.js application:

```arduino
docker run -p 8080:8080 -d my-nodejs-app
``` 
9. Test your application:

Open a web browser and navigate to `http://localhost:8080`. You should see the "Hello, World!" message.

That's it! You've successfully set up a Node.js Docker image and used it to run your Node.js application inside a container.
