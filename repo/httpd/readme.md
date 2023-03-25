# httpd - apache2 server
The Apache HTTP Server (httpd) is a widely used, open-source web server software for serving HTTP requests and delivering web content. 

## Install

    apt-docker install httpd myname

    # Parameters
    --apt-docker-name="httpd-server"
    --httpd-tag="2.4"
    --data-dir="$HOME/.apt-docker/"
    --port="8080"
    --ip-mode="local"

## Setup Guide
In this guide, you'll set up an Apache httpd Docker container without using a Dockerfile. You'll choose a specific port and use your project directory for your HTML content.

**1.** Install Docker: Ensure Docker is installed on your machine. Download it from https://www.docker.com/products/docker-desktop.

**2.** Create project directory and add HTML content:

```bash
$ mkdir my-project
$ cd my-project
```
Add your HTML files directly to the "my-project" directory.

**3.** Run the Apache httpd container with a specific port and directory:
Replace *<host_port>* with the desired port on your local machine, and *<path_to_project>* with the full path to your "my-project" directory.

```bash
$ docker run -dit --name my-apache-app -p <host_port>:80 -v <path_to_project>:/usr/local/apache2/htdocs/ httpd:2.4
```
For example, if you want to use port 8080 and your project is in "/home/user/my-project", the command would be:

```bash
$ docker run -dit --name my-apache-app -p 8080:80 -v /home/user/my-project:/usr/local/apache2/htdocs/ httpd:2.4
```
**4.** Access your site: Open a web browser and visit http://localhost:<host_port>. Replace <host_port> with the port you chose in step 3.


## Using httpd

Here are simple examples of downloading a file from your httpd server on localhost and the specified port, in various programming languages:

Replace <host_port> with the port you chose when running the Docker container.

### Python:
```python
import requests

url = f'http://localhost:<host_port>/your-file.ext'
response = requests.get(url)

with open('your-file.ext', 'wb') as f:
    f.write(response.content)
```
    
### JavaScript (Node.js):
```javascript
const http = require('http');
const fs = require('fs');

const file = fs.createWriteStream('your-file.ext');
const url = `http://localhost:<host_port>/your-file.ext`;

http.get(url, (response) => {
  response.pipe(file);
});
```

### Java:
```java
Copy code
import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;

public class DownloadFile {
    public static void main(String[] args) throws IOException {
        String url = "http://localhost:<host_port>/your-file.ext";
        String outputFile = "your-file.ext";

        try (BufferedInputStream in = new BufferedInputStream(new URL(url).openStream());
             FileOutputStream fileOutputStream = new FileOutputStream(outputFile)) {

            byte[] dataBuffer = new byte[1024];
            int bytesRead;

            while ((bytesRead = in.read(dataBuffer, 0, 1024)) != -1) {
                fileOutputStream.write(dataBuffer, 0, bytesRead);
            }
        }
    }
}
```

### C#:
```csharp
using System;
using System.IO;
using System.Net;

class DownloadFile {
    static void Main() {
        string url = "http://localhost:<host_port>/your-file.ext";
        string outputFile = "your-file.ext";

        WebClient client = new WebClient();
        client.DownloadFile(url, outputFile);
    }
}
```

### C++ (using libcurl):
First, install libcurl if you haven't already, then:

```cpp
#include <iostream>
#include <fstream>
#include <curl/curl.h>

size_t write_data(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}

int main() {
    CURL *curl;
    FILE *fp;
    const char *url = "http://localhost:<host_port>/your-file.ext";
    const char *outputFile = "your-file.ext";

    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();

    if (curl) {
        fp = fopen(outputFile, "wb");
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        fclose(fp);
    }

    return 0;
}
```

### PHP:
```php
<?php
$url = "http://localhost:<host_port>/your-file.ext";
$outputFile = "your-file.ext";

file_put_contents($outputFile, fopen($url, 'r'));
?>
```
