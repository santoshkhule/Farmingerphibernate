<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.san.farm.login.dao.LoginUserService"%>
<%@ page import="com.san.farm.login.entity.LoginUser"%>
<%@ page import="com.san.farm.license.LicenseClient"%>
<%@ page import="com.san.farm.license.LicenseStatus"%>
<%@ page import="com.san.farm.util.BuildConfig"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%@ include file="lang.jsp" %>
<%
    /* No caching — prevents stale authenticated pages being served from bfcache */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    /* Already authenticated — skip login */
    if (session.getAttribute("loggedInUser") != null) {
        response.sendRedirect(".");
        return;
    }

    /* ── License check (done once per page load, cached result reused below) ── */
    LicenseStatus _lic = LicenseClient.check();

    String errorMsg   = "";
    String warnMsg    = "";
    String lastUname  = "";

    /* Show expiry warning on GET if license is nearing expiry */
    if (!_lic.noConfig && _lic.valid && _lic.daysRemaining >= 0 && _lic.daysRemaining <= 14) {
        warnMsg = "License expires in " + _lic.daysRemaining + " day(s). Please renew soon.";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String uname = request.getParameter("txtUname");
        String pwd   = request.getParameter("txtPwd");
        lastUname    = (uname != null) ? uname.trim() : "";

        /* ── Enforce license before checking credentials ── */
        if (!_lic.noConfig) {
            if (_lic.unreachable) {
                if (BuildConfig.IS_PROD) {
                    /* PROD: fail-closed — cannot reach license server, block login */
                    errorMsg = "License server is unreachable. Login is not allowed in production without a valid license. Contact your administrator.";
                } else {
                    /* DEV: fail-open — warn but allow */
                    warnMsg = "License server is unreachable. Running without license validation.";
                }
            } else if (!_lic.valid) {
                /* Server responded explicitly — block login */
                String licMsg = (_lic.message != null && !_lic.message.isEmpty())
                                ? _lic.message : "License is expired or invalid.";
                errorMsg = licMsg + " Contact your administrator to renew.";
            }
        }

        if (errorMsg.isEmpty()) {
            if (lastUname.isEmpty() || pwd == null || pwd.trim().isEmpty()) {
                errorMsg = msg.getString("login.error_required");
            } else {
                LoginUser user = new LoginUserService().authenticate(lastUname, pwd.trim());
                if (user != null) {
                    /* Invalidate old session to prevent session fixation, start fresh */
                    session.invalidate();
                    HttpSession newSession = request.getSession(true);
                    newSession.setAttribute("loggedInUser", user);
                    response.sendRedirect(".");
                    return;
                } else {
                    errorMsg = msg.getString("login.error_invalid");
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="img/favicon.svg">
<link rel="stylesheet" href="css/style.css">
<title><%= msg.getString("login.page_title") %></title>
<script>
    /* If session expired while inside the content iframe, break out to the top window
       so the login page always renders full-screen, not embedded. */
    if (window !== window.top) {
        window.top.location.replace(window.location.href);
    }
</script>
</head>
<body class="login-page">

<div class="login-card">
    <div class="login-icon">&#127807;</div>
    <h1><%= msg.getString("login.app_name") %></h1>
    <p class="subtitle"><%= msg.getString("login.subtitle") %></p>

    <%if (!warnMsg.isEmpty()) {%>
    <div class="warn-msg">&#9888; <%=warnMsg%></div>
    <%}%>
    <%if (!errorMsg.isEmpty()) {%>
    <div class="err-msg"><%=errorMsg%></div>
    <%}%>

    <form method="post" action="login.jsp">
        <div class="field">
            <label for="txtUname"><%= msg.getString("login.label_username") %></label>
            <input type="text" name="txtUname" id="txtUname"
                value="<%=lastUname.replace("\"","&quot;")%>"
                placeholder="<%= msg.getString("login.placeholder_username") %>" autocomplete="username" required autofocus>
        </div>
        <div class="field">
            <label for="txtPwd"><%= msg.getString("login.label_password") %></label>
            <input type="password" name="txtPwd" id="txtPwd"
                placeholder="<%= msg.getString("login.placeholder_password") %>" autocomplete="current-password" required>
        </div>
        <input type="submit" class="btn-login" value="<%= msg.getString("login.btn_sign_in") %>">
    </form>
</div>

</body>
</html>
