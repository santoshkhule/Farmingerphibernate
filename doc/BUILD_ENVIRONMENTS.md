# Sevak ERP — Build Environments (DEV / PROD)

## Overview

The Sevak ERP Maven project supports two build profiles that control environment-specific
behaviour baked into the WAR at package time. The active profile is selected once at build
time; no runtime flag or system property is needed after deployment.

| Profile | Command flag | WAR filename | License toggle |
|---------|-------------|--------------|----------------|
| **dev** (default) | `-P dev` | `FarmingERP-dev.war` | Editable — can be disabled for local testing |
| **prod** | `-P prod` | `FarmingERP.war` | Locked to ENABLED — cannot be disabled |

---

## How to Build

### Prerequisites

- JDK 11 or later on `PATH`
- Apache Maven 3.6+
- From inside the `application/` directory

```bash
cd /path/to/Farmingerphibernate/application
```

### Development Build (default)

```bash
mvn package -P dev -DskipTests
```

Output: `target/FarmingERP-dev.war`

- License Checks toggle is **editable** in System Configuration
- "Disabled — all users can log in..." hint is visible
- Intended for local development and QA environments

Shorthand — `dev` is the default profile, so these are equivalent:

```bash
mvn package -DskipTests          # same as -P dev
mvn package -P dev -DskipTests   # explicit
```

### Production Build

```bash
mvn package -P prod -DskipTests
```

Output: `target/FarmingERP.war`

- License Checks are **locked to ENABLED** — the UI shows a locked badge and
  the server-side controller ignores any attempt to disable checks via a POST request
- Dev-only hint text is hidden from the System Configuration UI
- Use this WAR for all customer / production deployments

### Including Tests

Remove `-DskipTests` to run the test suite before packaging:

```bash
mvn package -P prod    # compile + test + package
```

---

## How It Works Internally

### 1. Maven Profiles (`pom.xml`)

Two profiles are declared under `<profiles>`:

```xml
<profile>
    <id>dev</id>
    <activation><activeByDefault>true</activeByDefault></activation>
    <properties>
        <build.env>dev</build.env>
        <license.ui.editable>true</license.ui.editable>
    </properties>
    <build>
        <finalName>FarmingERP-dev</finalName>
    </build>
</profile>

<profile>
    <id>prod</id>
    <properties>
        <build.env>prod</build.env>
        <license.ui.editable>false</license.ui.editable>
    </properties>
    <build>
        <finalName>FarmingERP</finalName>
    </build>
</profile>
```

### 2. Selective Resource Filtering

Only `build.properties` is filtered by Maven (other resource files such as
`application.properties` are copied verbatim to avoid accidental `${...}` expansion):

```xml
<resources>
    <!-- All resources unfiltered -->
    <resource>
        <directory>src/main/resources</directory>
        <filtering>false</filtering>
        <excludes><exclude>build.properties</exclude></excludes>
    </resource>
    <!-- build.properties filtered -->
    <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
        <includes><include>build.properties</include></includes>
    </resource>
</resources>
```

### 3. `build.properties` Template

Located at `src/main/resources/build.properties`. Maven replaces the `${...}`
placeholders at package time:

```properties
build.env=${build.env}
license.ui.editable=${license.ui.editable}
```

After a `prod` build the file inside the WAR reads:

```properties
build.env=prod
license.ui.editable=false
```

After a `dev` build:

```properties
build.env=dev
license.ui.editable=true
```

### 4. `BuildConfig.java` — Runtime Constants

`com.san.farm.util.BuildConfig` reads the stamped `build.properties` from the
classpath once at class-load time and exposes static constants:

```java
BuildConfig.ENV                 // "dev" or "prod"
BuildConfig.IS_PROD             // true in prod builds
BuildConfig.IS_DEV              // true in dev builds
BuildConfig.LICENSE_UI_EDITABLE // false in prod builds
```

Import and use anywhere in Java or JSP:

```java
<%@ page import="com.san.farm.util.BuildConfig" %>
<% if (BuildConfig.IS_PROD) { ... } %>
```

---

## License Checks Enforcement in PROD

### UI Layer (`systemConfig.jsp`)

When `BuildConfig.IS_PROD` is `true`:

- The **License Checks** `<select>` dropdown is replaced by a locked
  **🔒 Enforced (PROD)** badge
- A hidden `<input>` always submits `license.server.enabled=true`
- The note *"Disabled — all users can log in regardless of license status.
  Use only for local development."* is not rendered
- An amber info banner *"Production build — license enforcement is locked"*
  is shown at the top of the edit form

### Controller Layer (`SystemConfigController.java`)

Even if someone bypasses the UI and sends a crafted POST request, the controller
always forces `license.server.enabled=true` in PROD builds:

```java
if (BuildConfig.IS_PROD) {
    updates.setProperty("license.server.enabled", "true");
    log.warn("Attempt to set license.server.enabled ignored in PROD build");
}
```

This two-layer approach means the enforcement cannot be circumvented through
browser developer tools or direct HTTP calls.

---

## Adding New Environment-Specific Behaviour

To gate any future feature on the build environment:

1. Add a new Maven property to both profiles in `pom.xml`, e.g.:

   ```xml
   <!-- in dev profile -->
   <my.feature.enabled>true</my.feature.enabled>

   <!-- in prod profile -->
   <my.feature.enabled>false</my.feature.enabled>
   ```

2. Add the corresponding placeholder to `build.properties`:

   ```properties
   my.feature.enabled=${my.feature.enabled}
   ```

3. Add a constant to `BuildConfig.java`:

   ```java
   public static final boolean MY_FEATURE_ENABLED =
       Boolean.parseBoolean(p.getProperty("my.feature.enabled", "false"));
   ```

4. Use it in any JSP or Java class:

   ```java
   if (BuildConfig.MY_FEATURE_ENABLED) { ... }
   ```

---

## Verifying the Active Profile in a Deployed WAR

To confirm which profile was used to build a deployed WAR, extract and inspect
`build.properties`:

```bash
# From the WAR file directly
unzip -p FarmingERP.war WEB-INF/classes/build.properties

# From an exploded WAR on Tomcat
cat $CATALINA_HOME/webapps/FarmingERP/WEB-INF/classes/build.properties
```

Expected output for a production build:

```
build.env=prod
license.ui.editable=false
```

---

## Quick Reference

```bash
# DEV build (default, license toggle editable)
mvn package -P dev -DskipTests
# → target/FarmingERP-dev.war

# PROD build (license toggle locked, clean WAR name)
mvn package -P prod -DskipTests
# → target/FarmingERP.war

# Check which environment is baked in
unzip -p target/FarmingERP.war WEB-INF/classes/build.properties
```
