<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.san.farm.login.dao.LoginUserService"%>
<%@ page import="com.san.farm.login.entity.LoginUser"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%
    /* No caching — prevents stale authenticated pages being served from bfcache */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    /* Already authenticated — skip login */
    if (session.getAttribute("loggedInUser") != null) {
        response.sendRedirect("shell.jsp");
        return;
    }

    String errorMsg  = "";
    String lastUname = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String uname = request.getParameter("txtUname");
        String pwd   = request.getParameter("txtPwd");
        lastUname    = (uname != null) ? uname.trim() : "";

        if (lastUname.isEmpty() || pwd == null || pwd.trim().isEmpty()) {
            errorMsg = "Username and password are required.";
        } else {
            LoginUser user = new LoginUserService().authenticate(lastUname, pwd.trim());
            if (user != null) {
                /* Invalidate old session to prevent session fixation, start fresh */
                session.invalidate();
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("loggedInUser", user);
                response.sendRedirect("shell.jsp");
                return;
            } else {
                errorMsg = "Invalid username or password. Please try again.";
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
<title>Santosh Farming ERP - Login</title>
</head>
<body class="login-page">

<div class="login-card">
    <div class="login-icon">&#127807;</div>
    <h1>Santosh Farming</h1>
    <p class="subtitle">Farm Management System</p>

    <%if (!errorMsg.isEmpty()) {%>
    <div class="err-msg"><%=errorMsg%></div>
    <%}%>

    <form method="post" action="login.jsp">
        <div class="field">
            <label for="txtUname">Username</label>
            <input type="text" name="txtUname" id="txtUname"
                value="<%=lastUname.replace("\"","&quot;")%>"
                placeholder="Enter username" autocomplete="username" required autofocus>
        </div>
        <div class="field">
            <label for="txtPwd">Password</label>
            <input type="password" name="txtPwd" id="txtPwd"
                placeholder="Enter password" autocomplete="current-password" required>
        </div>
        <input type="submit" class="btn-login" value="Sign In">
    </form>
</div>

</body>
</html>
