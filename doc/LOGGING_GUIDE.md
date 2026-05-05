# Logging Setup Documentation

## Overview
The project now uses **SLF4J** with **Log4j** backend for comprehensive logging support. This replaces all `System.out.println()` and `exception.printStackTrace()` calls with proper logging.

## Dependencies Added
- `org.slf4j:slf4j-api:1.7.25` - SLF4J API
- `org.slf4j:slf4j-log4j12:1.7.25` - SLF4J Log4j binding
- `log4j:log4j:1.2.15` - Log4j core

These are already configured in `pom.xml`.

## Configuration File
Location: `src/main/resources/log4j.properties`

### Log Levels
- **TRACE**: Very detailed diagnostic information
- **DEBUG**: Detailed debugging information (useful for development)
- **INFO**: General informational messages
- **WARN**: Warning messages for potentially harmful situations
- **ERROR**: Error messages for serious problems

### Current Configuration
```properties
# Console output and file appender enabled
log4j.rootLogger=INFO, CONSOLE, FILE

# Console appender - outputs to system console
log4j.appender.CONSOLE

# File appender - logs to logs/farmingerphibernate.log
log4j.appender.FILE.File=logs/farmingerphibernate.log
log4j.appender.FILE.MaxFileSize=10MB (rotating file appender)

# Package-specific settings
- com.san.farm: DEBUG level (detailed logging)
- org.hibernate: WARN level (reduce noise from Hibernate)
- org.hibernate.SQL: DEBUG level (log SQL statements)
```

## Usage in Code

### How to Use Logger in Your Classes

1. **Import the logger**:
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
```

2. **Create a logger instance** in your class:
```java
private static final Logger logger = LoggerFactory.getLogger(YourClassName.class);
```

3. **Use logging methods**:
```java
// Debug level (for development)
logger.debug("Processing request: {}", requestId);

// Info level (for important events)
logger.info("User {} logged in successfully", username);

// Warn level (for potential issues)
logger.warn("Connection timeout for user {}", userId);

// Error level (for exceptions)
logger.error("Database operation failed", exception);

// Error with parameters
logger.error("Error processing user {} with id {}", userName, userId, exception);
```

### Benefits Over System.out.println()
- ✅ Configurable log levels
- ✅ Multiple outputs (console, file, etc.)
- ✅ Automatic timestamp and formatting
- ✅ Easy filtering by package or class
- ✅ Rolling file appenders to manage file size
- ✅ Thread-safe logging
- ✅ Can be disabled without code changes

## Example Output

**Console**:
```
2026-05-05 14:30:45 INFO  AssignCropToSiteService:36 - Saving AssignCropToSite entity
2026-05-05 14:30:45 INFO  AssignCropToSiteService:40 - AssignCropToSite saved successfully
2026-05-05 14:30:46 DEBUG AssignCropToSiteService:48 - Fetching all AssignCropToSite records
```

**File** (`logs/farmingerphibernate.log`):
```
2026-05-05 14:30:45 DEBUG LoginServlet:25 - Processing login request
2026-05-05 14:30:45 ERROR LoginServlet:30 - Authentication failed for user: john@example.com
```

## Updated Classes
- `AssignCropToSiteService.java` - All methods now use proper logging

## Next Steps
To add logging to other service/DAO classes:
1. Add the logger import and field
2. Replace `exception.printStackTrace()` with `logger.error("Error message", exception)`
3. Replace `System.out.println()` with appropriate logger methods

## Testing Logs
1. Run `mvn clean compile` to build
2. Run `mvn tomcat7:run` or deploy to Tomcat
3. Check console output
4. Check `logs/farmingerphibernate.log` file for file-based logs

