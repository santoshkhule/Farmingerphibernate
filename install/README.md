# Santosh Farming ERP — Installation Guide

## Quick Start (H2 embedded database — no external DB needed)

1. Copy the template:
   ```
   cp install/application.properties.example src/main/resources/application.properties
   ```
   The default template already uses H2, so **no edits are needed for a quick start**.

2. Build:
   ```
   mvn clean package
   ```

3. Deploy the generated WAR (`target/FarmingERP-1.0-SNAPSHOT.war`) to Tomcat and start the server.

4. Open your browser at `http://localhost:8080/FarmingERP`

5. Log in with the default credentials:
   - **Username:** `admin`
   - **Password:** `admin`

> **Important:** Change the password immediately after first login via the Register User screen.

---

## Connecting to an External Database

Edit `src/main/resources/application.properties`.  
All connection settings are in that single file — see `install/application.properties.example` for full examples.

### MySQL / MariaDB

```properties
db.driver=com.mysql.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/farmingerpdb?useSSL=false&useUnicode=true&characterEncoding=UTF-8
db.username=farmuser
db.password=yourpassword
hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect
hibernate.hbm2ddl.auto=update
```

Create the database first:
```sql
CREATE DATABASE farmingerpdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'farmuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL ON farmingerpdb.* TO 'farmuser'@'localhost';
```

Also add the MySQL connector to `pom.xml` if not already present:
```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
```

### PostgreSQL

```properties
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://localhost:5432/farmingerpdb
db.username=farmuser
db.password=yourpassword
hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

Add the driver to `pom.xml`:
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.6.0</version>
</dependency>
```

---

## What Happens on First Startup

`DataSeeder` (`com.san.farm.install.DataSeeder`) runs automatically as a `ServletContextListener`:

1. It checks whether a user named `admin` already exists in the `LOGINUSER` table.
2. If not found, it inserts: `username = admin`, `password = admin`.
3. It logs the outcome — look for `DataSeeder:` entries in the server log.

This is idempotent: restarting the server will not create duplicate users.

---

## Configuration Reference

| Property | Description | Default |
|---|---|---|
| `db.driver` | JDBC driver class | `org.h2.Driver` |
| `db.url` | JDBC connection URL | H2 file-based |
| `db.username` | Database username | `sa` |
| `db.password` | Database password | *(empty)* |
| `hibernate.dialect` | Hibernate SQL dialect | `H2Dialect` |
| `hibernate.hbm2ddl.auto` | Schema management mode | `update` |
| `hibernate.show_sql` | Print SQL to log | `false` |

---

## File Locations

| File | Purpose |
|---|---|
| `src/main/resources/application.properties` | Active DB configuration — edit this |
| `src/main/resources/hibernate.cfg.xml` | Entity mappings only — do not edit unless adding new entities |
| `src/main/java/com/san/farm/install/DataSeeder.java` | Startup seed logic |
| `install/application.properties.example` | Configuration template with all DB examples |
