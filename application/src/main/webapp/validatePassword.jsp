<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
         import="com.san.farm.login.dao.LoginUserService,com.san.farm.login.entity.LoginUser" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store");
    LoginUser _vpUser = (LoginUser) session.getAttribute("loggedInUser");
    String _vpPwd = request.getParameter("pwd");
    if (_vpUser == null || _vpPwd == null || _vpPwd.trim().isEmpty()) {
        out.print("{\"ok\":false,\"msg\":\"Invalid request.\"}");
        return;
    }
    LoginUser _vpValidated = new LoginUserService().authenticate(_vpUser.getUname(), _vpPwd.trim());
    if (_vpValidated != null) {
        out.print("{\"ok\":true}");
    } else {
        out.print("{\"ok\":false,\"msg\":\"Incorrect password.\"}");
    }
%>
