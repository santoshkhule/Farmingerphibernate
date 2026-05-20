package com.san.license;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

/**
 * Minimal smoke test — verifies that the Spring application context loads
 * without errors (key pair generation, service wiring, controller mappings).
 */
@SpringBootTest
@TestPropertySource(properties = {
        "license.data.dir=${java.io.tmpdir}/sevak-license-test",
        "license.admin.key=test-admin-key",
        "server.port=0"          // random port during tests
})
class LicenseServerAppTest {

    @Test
    void contextLoads() {
        // If the context fails to start, Spring will throw and the test fails automatically.
        // No assertions needed — the test passing IS the assertion.
    }
}
