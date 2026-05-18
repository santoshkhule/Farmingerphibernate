package com.san.farm.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SessionFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(SessionFilter.class);

    /* Exact paths that do not require a session */
    private static final Set<String> PUBLIC_PATHS = new HashSet<String>(Arrays.asList(
        "/login.jsp",
        "/index.jsp",
        "/logout.jsp",
        "/error.jsp",
        "/LoginServlet"
    ));

    /* Path prefixes that do not require a session (static resources) */
    private static final String[] PUBLIC_PREFIXES = {
        "/css/", "/js/", "/img/", "/h2-console/"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  httpReq = (HttpServletRequest)  request;
        HttpServletResponse httpRes = (HttpServletResponse) response;

        String contextPath = httpReq.getContextPath();
        String requestUri  = httpReq.getRequestURI();
        /* Strip context path to get the relative path */
        String path = requestUri.length() > contextPath.length()
                    ? requestUri.substring(contextPath.length())
                    : "/";

        /* Allow public resources through without a session check */
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        /* Check for a valid authenticated session */
        HttpSession session = httpReq.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            chain.doFilter(request, response);
        } else {
            logger.warn("Unauthenticated access attempt: {}", requestUri);
            httpRes.sendRedirect(contextPath + "/login.jsp");
        }
    }

    private boolean isPublic(String path) {
        if (PUBLIC_PATHS.contains(path)) return true;
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) return true;
        }
        return false;
    }

    @Override
    public void destroy() {}
}
