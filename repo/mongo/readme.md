# Mongo

Setting Up a Simple Docker-based MongoDB Server 

## Install
```shell
apt-docker install mongo myname
```

## Setup Guide
1. Install Docker on your system if you haven't already. You can follow the installation guide for your specific operating system from the Docker website. 
2. Pull the MongoDB Docker image:

```ruby
$ docker pull mongo
```


1. Create a directory on your host system for MongoDB data storage:

```shell
$ mkdir -p ~/mongo_data/db
```


1. Start a MongoDB container with the data directory mounted to the host system:

```ruby
$ docker run --name my-mongo -v ~/mongo_data/db:/data/db -d mongo
```



In this command, replace `my-mongo` with your preferred container name.

Configurable Environment Variables: 
- `MONGO_INITDB_ROOT_USERNAME`: Set a username for the MongoDB root user. 
- `MONGO_INITDB_ROOT_PASSWORD`: Set a password for the MongoDB root user. 
- `MONGO_INITDB_DATABASE`: Specify the name of a database for the initialization scripts in `/docker-entrypoint-initdb.d/*.js`.

Example with environment variables:

```ruby
$ docker run --name my-mongo \
  -v ~/mongo_data/db:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=myuser \
  -e MONGO_INITDB_ROOT_PASSWORD=mypassword \
  -d mongo
```



This will create a MongoDB instance with the specified username and password. To connect to the MongoDB instance, you can use the `mongo` shell or any MongoDB client with the appropriate credentials.


## Using Mongo

### Python (using pymongo library):

```python
from pymongo import MongoClient

client = MongoClient("mongodb://username:password@localhost:27017")
db = client["mydatabase"]
collection = db["mycollection"]

document = {"name": "John", "age": 30, "city": "New York"}
collection.insert_one(document)

for doc in collection.find():
    print(doc)
```



### JavaScript (using MongoDB Node.js driver):

```javascript
const { MongoClient } = require("mongodb");

(async () => {
  const uri = "mongodb://username:password@localhost:27017";
  const client = new MongoClient(uri);
  await client.connect();

  const db = client.db("mydatabase");
  const collection = db.collection("mycollection");

  const document = { name: "John", age: 30, city: "New York" };
  await collection.insertOne(document);

  const cursor = collection.find();
  await cursor.forEach(doc => console.log(doc));

  await client.close();
})();
```



### Java (using MongoDB Java driver):

```java
import com.mongodb.client.*;
import org.bson.Document;

public class MongoExample {
    public static void main(String[] args) {
        MongoClient mongoClient = MongoClients.create("mongodb://username:password@localhost:27017");
        MongoDatabase database = mongoClient.getDatabase("mydatabase");
        MongoCollection<Document> collection = database.getCollection("mycollection");

        Document document = new Document("name", "John")
                                .append("age", 30)
                                .append("city", "New York");
        collection.insertOne(document);

        FindIterable<Document> documents = collection.find();
        for (Document doc : documents) {
            System.out.println(doc.toJson());
        }

        mongoClient.close();
    }
}
```



### C# (using MongoDB.Driver library):

```csharp
using MongoDB.Bson;
using MongoDB.Driver;

class Program {
    static void Main(string[] args) {
        var connectionString = "mongodb://username:password@localhost:27017";
        var client = new MongoClient(connectionString);
        var database = client.GetDatabase("mydatabase");
        var collection = database.GetCollection<BsonDocument>("mycollection");

        var document = new BsonDocument { { "name", "John" }, { "age", 30 }, { "city", "New York" } };
        collection.InsertOne(document);

        var documents = collection.Find(new BsonDocument()).ToList();
        foreach (var doc in documents) {
            Console.WriteLine(doc);
        }
    }
}
```

### C++  (using the MongoDB C++ driver)

```cpp
#include <iostream>
#include <bsoncxx/builder/stream/document.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/stdx.hpp>
#include <mongocxx/uri.hpp>

int main(int, char **) {
    mongocxx::instance instance{};
    mongocxx::client client{mongocxx::uri{}};

    auto db = client["mydb"];
    auto collection = db["test_collection"];

    bsoncxx::builder::stream::document document{};
    document << "name" << "John Doe"
             << "age" << 30;

    collection.insert_one(document.view());

    auto cursor = collection.find({});

    for (auto&& doc : cursor) {
        std::cout << bsoncxx::to_json(doc) << std::endl;
    }
}
```

### PHP  (using the MongoDB PHP extension)

```php
<?php
require_once 'vendor/autoload.php';

$client = new MongoDB\Client("mongodb://localhost:27017");
$db = $client->mydb;
$collection = $db->test_collection;

$document = [
    'name' => 'John Doe',
    'age' => 30,
];

$result = $collection->insertOne($document);

$cursor = $collection->find();

foreach ($cursor as $doc) {
    echo json_encode($doc);
}
?>
```



### Rust  (using the MongoDB Rust driver)

```rust
use mongodb::{options::ClientOptions, Client, bson::{doc, Bson}};

#[tokio::main]
async fn main() -> mongodb::error::Result<()> {
    let client_options = ClientOptions::parse("mongodb://localhost:27017").await?;
    let client = Client::with_options(client_options)?;
    let db = client.database("mydb");
    let collection = db.collection("test_collection");

    let document = doc! {
        "name": "John Doe",
        "age": 30,
    };

    collection.insert_one(document, None).await?;

    let cursor = collection.find(None, None).await?;

    for doc in cursor {
        println!("{:?}", doc?.to_string());
    }

    Ok(())
}
```

### Go:

```go
package main

import (
  "context"
  "fmt"
  "log"
  "time"

  "go.mongodb.org/mongo-driver/bson"
  "go.mongodb.org/mongo-driver/mongo"
  "go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
  uri := "mongodb://username:password@localhost:27017"
  clientOptions := options.Client().ApplyURI(uri)

  client, err := mongo.Connect(context.Background(), clientOptions)
  if err != nil {
    log.Fatal(err)
  }
  defer client.Disconnect(context.Background())

  db := client.Database("mydatabase")
  collection := db.Collection("mycollection")

  document := bson.M{"name": "John", "age": 30, "city": "New York"}
  _, err = collection.InsertOne(context.Background(), document)
  if err != nil {
    log.Fatal(err)
  }

  ctx, _ := context.WithTimeout(context.Background(), 30*time.Second)
  cursor, err := collection.Find(ctx, bson.M{})
  if err != nil {
    log.Fatal(err)
  }
  defer cursor.Close(ctx)

  for cursor.Next(ctx) {
    var result bson.M
    err := cursor.Decode(&result)
    if err != nil {
      log.Fatal(err)
    }
    fmt.Println(result)
  }
}
```



### Ruby:

```ruby
require 'mongo'

client = Mongo::Client.new("mongodb://username:password@localhost:27017/mydatabase")
db = client.database
collection = db['mycollection']

document = {name: 'John', age: 30, city: 'New York'}
collection.insert_one(document)

collection.find.each do |doc|
  puts doc
end
```
