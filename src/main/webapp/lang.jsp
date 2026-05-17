<%@ page import="java.util.Locale, java.util.ResourceBundle" %>
<%@ page import="com.san.farm.util.UTF8Control" %>
<%--
  Shared language include — add at the top of every JSP page body:
      <%@ include file="../../lang.jsp" %>   (from view/user/ pages)
      <%@ include file="lang.jsp" %>         (from root webapp pages)

  Exposes:  ResourceBundle msg   — use as <%= msg.getString("key") %>
            String currentLocale — "en", "hi", or "mr"
--%>
<%
    String currentLocale = (String) session.getAttribute("locale");
    if (currentLocale == null) currentLocale = "en";
    Locale _locale = new Locale(currentLocale);
    ResourceBundle msg = ResourceBundle.getBundle("i18n/messages", _locale, new UTF8Control());
%>
