# MySql
Here is a bash script that runs the MySQL container on restart and lists all configurable things. This script is suitable for a single-node setup. If you need a cluster setup, consider using docker-compose or a container orchestration tool like Kubernetes.

## Install
```shell
apt-docker install mysql
```

## Setup Guide
```shell
#!/bin/bash

# Configuration variables
CONTAINER_NAME="some-mysql"
MYSQL_TAG="latest"
MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_DATABASE="my_database"
MYSQL_USER="example-user"
MYSQL_PASSWORD="example-password"
DATA_DIR="/my/own/datadir"

# Create the data directory on the host system if it doesn't exist
mkdir -p "${DATA_DIR}"

# Pull the MySQL image with the specified tag
docker pull "mysql:${MYSQL_TAG}"

# Remove the existing container if it exists
docker rm -f "${CONTAINER_NAME}"

# Run the MySQL container
docker run --name "${CONTAINER_NAME}" \
  -v "${DATA_DIR}:/var/lib/mysql" \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
  -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
  -e MYSQL_USER="${MYSQL_USER}" \
  -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  --restart=always \
  -d "mysql:${MYSQL_TAG}"
```

## Using MySql


### Python (using mysql-connector-python library):
```python
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="your_username",
    password="your_password",
    database="your_database"
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM your_table")
rows = cursor.fetchall()

for row in rows:
    print(row)

cursor.close()
conn.close()
```

### JavaScript (using mysql library with Node.js):
```js
const mysql = require('mysql');

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'your_username',
    password: 'your_password',
    database: 'your_database'
});

connection.connect();

connection.query('SELECT * FROM your_table', (error, results) => {
    if (error) throw error;
    console.log(results);
});

connection.end();
```

### Java (using mysql-connector-java library):
```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class Main {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/your_database?user=your_username&password=your_password");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM your_table");

            while (rs.next()) {
                System.out.println(rs.getString(1));
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### C# (using MySql.Data library):
```csharp
using System;
using MySql.Data.MySqlClient;

class MainClass {
    public static void Main (string[] args) {
        var connString = "server=localhost;user=your_username;password=your_password;database=your_database";
        MySqlConnection conn = new MySqlConnection(connString);
        conn.Open();

        MySqlCommand cmd = new MySqlCommand("SELECT * FROM your_table", conn);
        MySqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read()) {
            Console.WriteLine(reader[0]);
        }

        reader.Close();
        conn.Close();
    }
}
```

### C++ (using mysql-connector-c++ library):
```cpp
#include <iostream>
#include <mysqlx/xdevapi.h>

int main() {
    try {
        mysqlx::Session session("localhost", 33060, "your_username", "your_password", "your_database");
        mysqlx::Schema schema = session.getSchema("your_database");
        mysqlx::Table table = schema.getTable("your_table");

        mysqlx::RowResult rows = table.select().execute();

        for (const mysqlx::Row &row : rows) {
            std::cout << row[0] << std::endl;
        }

        session.close();
    } catch (const std::exception &e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    return 0;
}
```

### PHP
```php
<?php
$servername = "localhost";
$username = "your_username";
$password = "your_password";
$dbname = "your_database";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM your_table";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["id"]. " - Name: " . $row["name"]. "<br>";
    }
} else {
    echo "0 results";
}

$conn->close();
?>

```
