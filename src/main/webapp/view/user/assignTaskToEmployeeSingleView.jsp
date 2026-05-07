<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/jquery-ui.css" />
<script src="js/jquery-1.9.1.js"></script>
<script src="js/jquery-ui.js"></script>
<title>Assign Site And Work</title>
</head>
<body>

<%
AssignEmployeeToFarmEntity assignment = (AssignEmployeeToFarmEntity) request.getAttribute("assignment");
%>

<% if (assignment == null) { %>
    <p>No record found. Please select an assignment to view.</p>
<% } else {
    String formattedDate    = (String) request.getAttribute("formattedDate");
    double ttlTransactionPaid = (Double) request.getAttribute("ttlTransactionPaid");
    double balanceAmount      = (Double) request.getAttribute("balanceAmount");
    double excessAmount       = (Double) request.getAttribute("excessAmount");
%>

<h2 onclick="window.print()">View Assign Site And Work</h2>
<hr>
<table border="1" cellspacing="0" style="width: 40%;">
    <tr>
        <td style="text-align: right;">Employee Name:</td>
        <td>
            <% if (assignment.getEmployeeInfoEntity() != null) { %>
                <%= assignment.getEmployeeInfoEntity().getFirstName() %>
                <%= assignment.getEmployeeInfoEntity().getMiddleName() %>
                <%= assignment.getEmployeeInfoEntity().getLastName() %>
            <% } %>
        </td>
    </tr>
    <tr>
        <td style="text-align: right;">Date:</td>
        <td><%= formattedDate %></td>
    </tr>
    <tr>
        <td style="text-align: right;">For Which Site:</td>
        <td>
            <% if (assignment.getCropToSiteEntity() != null
                    && assignment.getCropToSiteEntity().getSiteInformationEntity() != null) { %>
                <%= assignment.getCropToSiteEntity().getSiteInformationEntity().getSiteName() %>
            <% } %>
        </td>
    </tr>
    <tr>
        <td style="text-align: right;">For Which Crop:</td>
        <td>
            <% if (assignment.getCropEntity() != null) { %>
                <%= assignment.getCropEntity().getCropName() %>
            <% } %>
        </td>
    </tr>
    <tr>
        <td style="text-align: right;">Type Of Work:</td>
        <td><%= assignment.getTypeOfWork() != null ? assignment.getTypeOfWork() : "" %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Work:</td>
        <td>
            <%
            List<ConfigFarmTaskEntity> tasks = assignment.getListFarmTaskEntities();
            if (tasks != null) {
                for (ConfigFarmTaskEntity task : tasks) {
                    out.print(task.getTaskName() + "<br>");
                }
            }
            %>
        </td>
    </tr>
    <tr>
        <td style="text-align: right;">Amount:</td>
        <td><%= assignment.getAmount() %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Advance Payment:</td>
        <td><%= assignment.getAdvPayment() %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Total Paid:</td>
        <td><%= assignment.getAdvPayment() + ttlTransactionPaid %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Balance:</td>
        <td><%= balanceAmount %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Excess Amount:</td>
        <td><%= excessAmount %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Work Status:</td>
        <td><%= assignment.getWorkStatus() != null ? assignment.getWorkStatus() : "" %></td>
    </tr>
    <tr>
        <td style="text-align: right;">Comment:</td>
        <td><%= assignment.getComment() != null ? assignment.getComment() : "" %></td>
    </tr>
</table>

<% } %>

</body>
</html>
