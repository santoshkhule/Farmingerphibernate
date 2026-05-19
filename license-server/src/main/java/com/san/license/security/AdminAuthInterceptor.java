package com.san.license.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Protects all {@code /admin/**} routes.
 * Allows through requests that have either:
 * <ul>
 *   <li>a valid browser session (set by {@code AdminLoginController}), or</li>
 *   <li>a valid {@code X-Admin-Key} header (for programmatic / API access).</li>
 * </ul>
 * Unauthenticated browser requests are redirected to {@code /admin/login}.
 * Unauthenticated API requests (non-GET or those with an {@code X-Admin-Key} header
 * that does not match) receive HTTP 401.
 */
@Component
public class AdminAuthInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(AdminAuthInterceptor.class);

    @Value("${license.admin.key}")
    private String configuredAdminKey;

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        // 1. Valid browser session
        HttpSession session = request.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("adminAuthenticated"))) {
            return true;
        }

        // 2. Programmatic access via X-Admin-Key header
        String headerKey = request.getHeader("X-Admin-Key");
        if (headerKey != null) {
            if (!configuredAdminKey.isEmpty() && configuredAdminKey.equals(headerKey)) {
                return true;
            }
            log.warn("Rejected request with invalid X-Admin-Key header: {}", request.getRequestURI());
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid admin key.");
            return false;
        }

        // 3. Not authenticated — redirect browser to login page
        log.debug("Unauthenticated access to {} — redirecting to /admin/login", request.getRequestURI());
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return false;
    }
}
