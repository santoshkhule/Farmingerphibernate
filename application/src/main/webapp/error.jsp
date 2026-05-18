<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" type="text/css">
<title>Error - Sevak ERP</title>
<style>
    body { margin: 0; padding: 0; background: #eaf2ea; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .err-card { background: #fff; border-radius: 8px; box-shadow: 0 2px 16px rgba(0,0,0,0.12); padding: 40px 48px; max-width: 480px; width: 90%; text-align: center; }
    .err-icon { font-size: 52px; margin-bottom: 12px; }
    .err-card h2 { margin: 0 0 8px; color: #c0392b; font-size: 20px; }
    .err-card p { margin: 0 0 24px; color: #555; font-size: 14px; line-height: 1.6; }
    .err-code { display: inline-block; background: #fdecea; color: #c0392b; border-radius: 4px; padding: 2px 10px; font-size: 12px; font-family: monospace; margin-bottom: 20px; }
    .btn-back { display: inline-block; background: #2e7d32; color: #fff; border: none; padding: 9px 24px; border-radius: 4px; font-size: 14px; cursor: pointer; text-decoration: none; }
    .btn-back:hover { background: #1b5e20; }
</style>
</head>
<body>
<%
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    String  errorMsg   = (String)  request.getAttribute("javax.servlet.error.message");
    Throwable cause    = (Throwable) request.getAttribute("javax.servlet.error.exception");

    /* Log the exception via Log4j so it appears in farmingerERP.log */
    if (cause != null) {
        Logger.getLogger("com.san.farm.error").error(
            "HTTP " + (statusCode != null ? statusCode : 500) + " — "
            + request.getAttribute("javax.servlet.error.request_uri")
            + " — " + cause.getClass().getName() + ": " + cause.getMessage(), cause);
    }

    String userMsg = "An unexpected error occurred. Please try again or contact your system administrator.";
    String codeStr = statusCode != null ? String.valueOf(statusCode) : "500";

    if (cause != null) {
        String rootMsg = cause.getMessage() != null ? cause.getMessage() : cause.getClass().getSimpleName();
        if (rootMsg.contains("HibernateUtil") || rootMsg.contains("SessionFactory") || rootMsg.contains("NoClassDefFound")) {
            userMsg = "The application could not connect to the database. Please ensure the server is configured correctly and restart the application.";
        } else if (rootMsg.contains("NullPointerException")) {
            userMsg = "A required value was missing while processing your request. Please try again.";
        }
    }
%>
<div class="err-card">
    <div class="err-icon">&#128683;</div>
    <h2>Something went wrong</h2>
    <span class="err-code">HTTP <%=codeStr%></span>
    <p><%=userMsg%></p>
    <a class="btn-back" href="javascript:history.back()">Go Back</a>
</div>
</body>
</html>
