package com.san.license.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;

/**
 * Handles session-based authentication for the admin UI.
 *
 * <p>Flow:
 * <ol>
 *   <li>GET  {@code /admin/login}  — renders the login form</li>
 *   <li>POST {@code /admin/login}  — validates the admin key; on success sets
 *       {@code adminAuthenticated=true} in the session and redirects to the dashboard</li>
 *   <li>GET  {@code /admin/logout} — invalidates the session and redirects to the login page</li>
 * </ol>
 * </p>
 */
@Controller
public class AdminLoginController {

    private static final Logger log = LoggerFactory.getLogger(AdminLoginController.class);

    @Value("${license.admin.key}")
    private String configuredAdminKey;

    @GetMapping("/admin/login")
    public String loginPage(HttpSession session) {
        if (Boolean.TRUE.equals(session.getAttribute("adminAuthenticated"))) {
            return "redirect:/admin";
        }
        return "admin-login";
    }

    @PostMapping("/admin/login")
    public String processLogin(@RequestParam("adminKey") String adminKey,
                               HttpSession session,
                               Model model) {
        if (configuredAdminKey != null
                && !configuredAdminKey.isEmpty()
                && configuredAdminKey.equals(adminKey)) {
            session.setAttribute("adminAuthenticated", Boolean.TRUE);
            log.info("Admin logged in successfully");
            return "redirect:/admin";
        }
        log.warn("Failed admin login attempt");
        model.addAttribute("errorMessage", "Invalid admin key — access denied.");
        return "admin-login";
    }

    @GetMapping("/admin/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        log.info("Admin logged out");
        return "redirect:/admin/login";
    }
}
