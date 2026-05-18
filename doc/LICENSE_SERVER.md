# Sevak ERP — License Server Architecture & Integration Guide

## Overview

The Sevak License Server is a standalone Spring Boot application that controls access
to the Sevak ERP application by issuing and validating cryptographically signed license
files. The Sevak ERP app calls the license server on every login attempt and blocks
access if the license has explicitly expired or is invalid.

```
┌─────────────────────────┐        HTTP REST         ┌────────────────────────┐
│   Sevak ERP (Tomcat)    │ ──GET /api/license/─────► │  License Server :8085  │
│   login.jsp             │ ◄── {valid, expires, ...}─ │  Spring Boot fat JAR   │
└─────────────────────────┘                            └────────────────────────┘
                                                                 │
                                                       ~/.sevak-license/
                                                         ├── private.key
                                                         ├── public.key
                                                         └── license.json
```

---

## Repository Layout

```
Farmingerphibernate/
├── src/                                  ← Sevak ERP (existing Tomcat app)
│   └── main/
│       ├── java/com/san/farm/license/
│       │   ├── LicenseClient.java        ← HTTP client used by login.jsp
│       │   └── LicenseStatus.java        ← Result DTO
│       ├── resources/
│       │   └── application.properties    ← license.server.url added here
│       └── webapp/
│           └── login.jsp                 ← License check on every POST
│
└── license-server/                       ← Standalone Spring Boot module
    ├── pom.xml
    └── src/main/java/com/san/license/
        ├── LicenseServerApp.java
        ├── model/
        │   ├── LicenseData.java
        │   ├── LicenseType.java
        │   └── ValidationResult.java
        ├── service/
        │   ├── CryptoService.java
        │   └── LicenseService.java
        └── controller/
            ├── LicenseApiController.java
            └── AdminController.java
```

---

## License Server

### Technology Stack

| Concern | Choice |
|---------|--------|
| Framework | Spring Boot 2.7.18 |
| Java | 11 |
| Server | Embedded Tomcat (port **8085**) |
| Admin UI | Thymeleaf |
| JSON | Jackson (via spring-boot-starter-web) |
| Crypto | JDK `java.security` — RSA-2048 / SHA256withRSA |
| Storage | File system (`~/.sevak-license/`) — no database |
| Packaging | Executable fat JAR |

### Building and Running

```bash
cd license-server

# Build
mvn package -DskipTests

# Run
java -jar target/license-server-1.0.0.jar
```

Startup logs:

```
=== Sevak License Server started on port 8085 ===
=== Admin UI:      http://localhost:8085/admin ===
=== Validate API:  http://localhost:8085/api/license/validate ===
```

### Configuration (`license-server/src/main/resources/application.properties`)

| Property | Default | Description |
|----------|---------|-------------|
| `server.port` | `8085` | HTTP port the license server listens on |
| `license.admin.key` | `sevak-admin-2024` | Password required to generate/upload licenses. **Change before production use.** |
| `license.data.dir` | `~/.sevak-license` | Directory where keypair and active license are stored |
| `spring.thymeleaf.cache` | `false` | Set to `true` in production |

---

## Cryptography Design

### Key Pair

On **first startup**, `CryptoService` generates an RSA-2048 keypair using
`java.security.KeyPairGenerator` and saves both keys to `license.data.dir`:

| File | Encoding | Used for |
|------|----------|----------|
| `private.key` | PKCS-8, Base64 | Signing new licenses |
| `public.key` | X.509, Base64 | Verifying license signatures |

On subsequent startups the existing files are loaded instead of regenerated.
**Back up `private.key` — losing it makes all existing license files unverifiable.**

### Canonical String & Signature

The signature covers the following fields joined with `|`:

```
licenseId|product|licensee|licenseType|issuedDate|expiryDate|maxUsers
```

Example:

```
3e4f1a2b-...|SevakERP|Acme Corp|ANNUAL|2026-05-18|2027-05-18|50
```

The canonical string is signed with `SHA256withRSA` and the resulting bytes are
Base64-encoded into the `signature` field of the license JSON.

### Why RSA and not HMAC?

RSA allows verification without the private key being present in the Sevak ERP app.
The private key stays solely on the license server; only the signed file (and optionally
the public key) needs to be distributed.

---

## License File Format

Active license is stored as `~/.sevak-license/license.json`:

```json
{
  "licenseId"   : "3e4f1a2b-9c7d-4e6f-a1b2-c3d4e5f60718",
  "product"     : "SevakERP",
  "licensee"    : "Acme Corp",
  "licenseType" : "ANNUAL",
  "issuedDate"  : "2026-05-18",
  "expiryDate"  : "2027-05-18",
  "maxUsers"    : 50,
  "signature"   : "Base64-encoded RSA-SHA256 signature..."
}
```

For perpetual licenses `expiryDate` is the literal string `"PERPETUAL"`.

### License Types

| Type | Duration | Use Case |
|------|----------|----------|
| `TRIAL` | 15 days | Evaluation |
| `ANNUAL` | 365 days | Standard yearly subscription |
| `THREE_YEAR` | 1 095 days | Multi-year contract |
| `PERPETUAL` | Never expires | One-time purchase |

---

## REST API

### `GET /api/license/validate`

Called by the Sevak ERP application on every login attempt. Always returns
**HTTP 200** — validity is communicated via the `valid` boolean in the body.

**Response (valid license):**

```json
{
  "valid"         : true,
  "licenseType"   : "ANNUAL",
  "licensee"      : "Acme Corp",
  "issuedDate"    : "2026-05-18",
  "expiryDate"    : "2027-05-18",
  "daysRemaining" : 365,
  "message"       : "License is valid — 365 day(s) remaining"
}
```

**Response (no license loaded):**

```json
{
  "valid"         : false,
  "daysRemaining" : 0,
  "message"       : "No license loaded"
}
```

**Response (expired):**

```json
{
  "valid"         : false,
  "daysRemaining" : -5,
  "message"       : "License expired 5 day(s) ago"
}
```

`daysRemaining` is `-1` for perpetual licenses.

---

## Admin UI

Open `http://localhost:8085/admin` in a browser.

### Generating a License

1. Fill **Licensee Name** (customer / organisation name).
2. Choose **License Type** from the dropdown.
3. Enter the **Admin Key** (default: `sevak-admin-2024`).
4. Click **Generate & Activate**.

The license is generated, signed, saved to `~/.sevak-license/license.json`, and
immediately active — no restart required.

### Uploading an Existing License File

Use the **Upload License File** card to replace the active license with a
previously generated `license.json`. The server validates the JSON structure
before accepting the file.

### Downloading the Active License

Click **Download Active License** (`GET /admin/download`) to save the current
`license.json` to disk. Use this to distribute the file to another license server
instance or for backup purposes.

---

## Validation Logic (`LicenseService.validate`)

Checks are performed in this order:

1. **File exists** — if `license.json` is absent, returns `{valid: false, message: "No license loaded"}`.
2. **Signature integrity** — rebuilds the canonical string from the loaded data and
   verifies the RSA-SHA256 signature. A tampered file fails here.
3. **Expiry check** — skipped for `PERPETUAL`. Otherwise, computes
   `ChronoUnit.DAYS.between(LocalDate.now(), expiryDate)`. Negative = expired.

---

## Sevak ERP Integration

### Configuration (`src/main/resources/application.properties`)

```properties
# License Server
license.server.enabled=true
license.server.url=http://localhost:8085
```

Set `license.server.enabled=false` to disable license checks entirely
(e.g., during local development without a running license server).

### `LicenseClient` (`com.san.farm.license.LicenseClient`)

Thin HTTP client using `HttpURLConnection` — no extra Maven dependencies.

- Reads `license.server.url` and `license.server.enabled` from `application.properties` at call time.
- Connection timeout: **2 seconds**.
- Parses the JSON response with simple string matching (no JSON library dependency).
- Returns a `LicenseStatus` value object.

### `LicenseStatus` fields

| Field | Type | Meaning |
|-------|------|---------|
| `valid` | boolean | Server said license is valid |
| `unreachable` | boolean | Could not connect to license server |
| `noConfig` | boolean | `license.server.url` not set or checks disabled |
| `message` | String | Human-readable status from server |
| `licenseType` | String | e.g., `"ANNUAL"` |
| `licensee` | String | Licensee name |
| `expiryDate` | String | ISO date or `"PERPETUAL"` |
| `daysRemaining` | long | Days until expiry; `-1` = perpetual |

### Login Enforcement (`login.jsp`)

The check runs on every **POST** (login form submit), **before** credential
validation, so an expired license blocks access regardless of username/password.

```
POST /login.jsp
  │
  ├── LicenseClient.check()
  │     ├── noConfig=true          → skip (allow)
  │     ├── unreachable=true       → warn banner, allow login (fail-open)
  │     └── valid=false            → errorMsg set, BLOCK login
  │
  └── LoginUserService.authenticate(uname, pwd)   ← only reached if license OK
```

**Fail-open on unreachable server:** If the license server is down, users can still
log in. Only an explicit `valid=false` response from a reachable server blocks access.
This prevents the license server becoming a single point of failure for the ERP.

### Expiry Warning Banner

When `daysRemaining` is between 0 and 14 (inclusive), an amber warning banner is
displayed on the login page even though login is still allowed:

> ⚠ License expires in N day(s). Please renew soon.

---

## Operational Runbook

### First-Time Setup

```bash
# 1 — Build the license server JAR (one-time)
cd license-server
mvn package -DskipTests

# 2 — Start the license server
java -jar target/license-server-1.0.0.jar

# 3 — Open the admin UI and generate a license
#     http://localhost:8085/admin
#     Admin key: sevak-admin-2024

# 4 — Deploy the Sevak ERP WAR to Tomcat
#     Ensure application.properties contains:
#       license.server.url=http://localhost:8085
```

### Renewing an Expired License

1. Start the license server if not running.
2. Open `http://localhost:8085/admin`.
3. Generate a new license (same or different type).
4. The new license is active immediately — Sevak ERP users can log in on their
   next attempt without any Tomcat restart.

### Changing the Admin Key

Edit `license-server/src/main/resources/application.properties`:

```properties
license.admin.key=your-new-secure-key
```

Rebuild and restart the license server.

### Moving the License Server to a Different Host

1. Copy the fat JAR to the new host.
2. Copy `~/.sevak-license/private.key` and `public.key` from the old host
   (same keys = existing `license.json` files remain valid).
3. Update `license.server.url` in Sevak's `application.properties` to the new host/port.
4. Redeploy Sevak ERP.

### Disabling License Checks (Development)

```properties
# application.properties (Sevak ERP)
license.server.enabled=false
```

No license server needs to be running. All logins are permitted.

---

## Security Considerations

| Risk | Mitigation |
|------|-----------|
| Admin key exposed | Change default `sevak-admin-2024` before deployment; use a strong random key |
| `private.key` file compromised | Attacker can forge licenses. Restrict OS file permissions (`chmod 600`); back up securely |
| License file tampered | RSA-SHA256 signature check will fail; server returns `valid=false` |
| License server network sniffing | Put license server behind a firewall / VPN; use HTTPS with a reverse proxy for production |
| License server single point of failure | Sevak uses fail-open: if server is unreachable, login is allowed with a warning |
