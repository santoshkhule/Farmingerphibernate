package com.san.license;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;

@SpringBootApplication
public class LicenseServerApp {

    private static final Logger log = LoggerFactory.getLogger(LicenseServerApp.class);

    public static void main(String[] args) {
        SpringApplication.run(LicenseServerApp.class, args);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        log.info("=== Sevak License Server started on port 8085 ===");
        log.info("=== Admin UI: http://localhost:8085/admin ===");
        log.info("=== Validate API: http://localhost:8085/api/license/validate ===");
    }
}
