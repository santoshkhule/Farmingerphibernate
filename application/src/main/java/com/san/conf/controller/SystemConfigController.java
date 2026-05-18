package com.san.conf.controller;

import com.san.conf.service.SystemConfigService;
import com.san.farm.login.entity.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.util.Properties;

/**
 * Handles POST actions and log-file download for the System Configuration page.
 * The JSP (/view/configuration/systemConfig.jsp) handles GET display directly.
 */
public class SystemConfigController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger log = LoggerFactory.getLogger(SystemConfigController.class);
    private final SystemConfigService service = new SystemConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/shell.jsp");
            return;
        }
        String action = req.getParameter("action");
        if ("downloadLog".equals(action)) {
            handleDownload(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/view/configuration/systemConfig.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/shell.jsp");
            return;
        }

        String action     = req.getParameter("action");
        String webappRoot = getServletContext().getRealPath("/");

        if ("setLogLevel".equals(action)) {
            String rootLevel = req.getParameter("rootLevel");
            String appLevel  = req.getParameter("appLevel");
            if (rootLevel != null && !rootLevel.trim().isEmpty())
                service.setRootLogLevel(rootLevel.trim());
            if (appLevel != null && !appLevel.trim().isEmpty())
                service.setAppLogLevel(appLevel.trim());
            log.info("Log levels updated: root={}, app={}", rootLevel, appLevel);
            resp.sendRedirect(req.getContextPath()
                + "/view/configuration/systemConfig.jsp?tab=logLevel&msg=levelSaved");
            return;
        }

        if ("saveDbProps".equals(action)) {
            String[] keys = {
                "db.driver", "db.url", "db.username", "db.password",
                "hibernate.dialect", "hibernate.hbm2ddl.auto",
                "hibernate.show_sql", "hibernate.format_sql"
            };
            Properties updates = new Properties();
            for (String k : keys) {
                String v = req.getParameter(k);
                if (v != null) updates.setProperty(k, v.trim());
            }
            try {
                service.saveDbProperties(webappRoot, updates);
                log.info("DB properties saved via System Configuration page");
                resp.sendRedirect(req.getContextPath()
                    + "/view/configuration/systemConfig.jsp?tab=dbProps&msg=dbSaved");
            } catch (IOException e) {
                log.error("Failed to save DB properties", e);
                resp.sendRedirect(req.getContextPath()
                    + "/view/configuration/systemConfig.jsp?tab=dbProps&msg=dbError");
            }
            return;
        }

        if ("saveLicenseProps".equals(action)) {
            Properties updates = new Properties();
            String url     = req.getParameter("license.server.url");
            String enabled = req.getParameter("license.server.enabled");
            if (url     != null) updates.setProperty("license.server.url",     url.trim());
            if (enabled != null) updates.setProperty("license.server.enabled", enabled.trim());
            try {
                service.saveDbProperties(webappRoot, updates);
                log.info("License server settings saved: url={}, enabled={}", url, enabled);
                resp.sendRedirect(req.getContextPath()
                    + "/view/configuration/systemConfig.jsp?tab=licenseServer&msg=licSaved");
            } catch (IOException e) {
                log.error("Failed to save license server settings", e);
                resp.sendRedirect(req.getContextPath()
                    + "/view/configuration/systemConfig.jsp?tab=licenseServer&msg=licError");
            }
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/view/configuration/systemConfig.jsp");
    }

    private void handleDownload(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String webappRoot = getServletContext().getRealPath("/");
        File logFile = service.getLogFile(webappRoot);
        if (logFile == null || !logFile.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Log file not found");
            return;
        }
        resp.setContentType("text/plain;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"farmingerERP.log\"");
        resp.setHeader("Content-Length", String.valueOf(logFile.length()));
        log.info("Log file download initiated: {} ({} bytes)", logFile.getName(), logFile.length());
        try (InputStream  in  = new FileInputStream(logFile);
             OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        LoginUser u = (LoginUser) s.getAttribute("loggedInUser");
        return u != null && "admin".equalsIgnoreCase(u.getUname());
    }
}
