<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery-ui.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" type="text/css">
<script src="<%=request.getContextPath()%>/js/jquery-1.9.1.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery-ui.js"></script>
<title>Edit Assign Site And Work</title>
<script>
    $(function() {
        $("#txtDate").datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: "dd/mm/yy"
        }).val();
    });

    function validation() {
        var empId = document.getElementById("selEmpId").value;
        var workType = document.getElementById("selWorkType").value;
        var workStatus = document.getElementById("selWorkStatus").value;
        if (empId == "" || empId == "-1") {
            alert("Select Employee Name");
            return false;
        }
        if (workType == "" || workType == "-1") {
            alert("Select Work Type");
            return false;
        }
        if (workStatus == "" || workStatus == "-1") {
            alert("Select Work Status");
            return false;
        }
        return true;
    }
</script>
</head>
<body>
<%@include file="../../header.jsp"%>
<div class="box">
<%
AssignEmployeeToFarmEntity assignment = (AssignEmployeeToFarmEntity) request.getAttribute("assignment");
if (assignment == null) {
%>
    <p>No record found. Please select an assignment to edit.</p>
<%
} else {
    String formattedDate = (String) request.getAttribute("formattedDate");
    @SuppressWarnings("unchecked")
    List<EmployeeInfoEntity> employees = (List<EmployeeInfoEntity>) request.getAttribute("employees");
    @SuppressWarnings("unchecked")
    List<ConfigCropEntity> crops = (List<ConfigCropEntity>) request.getAttribute("crops");
    @SuppressWarnings("unchecked")
    List<ConfigFarmTaskEntity> tasks = (List<ConfigFarmTaskEntity>) request.getAttribute("tasks");
    @SuppressWarnings("unchecked")
    List<AssignCropToSiteEntity> cropToSites = (List<AssignCropToSiteEntity>) request.getAttribute("cropToSites");

    int currentEmpId = (assignment.getEmployeeInfoEntity() != null) ? assignment.getEmployeeInfoEntity().getEmployeeInfoId() : -1;
    int currentCropId = (assignment.getCropEntity() != null) ? assignment.getCropEntity().getCropId() : -1;
    int currentCropToSiteId = (assignment.getCropToSiteEntity() != null) ? assignment.getCropToSiteEntity().getAssignCroptoSiteId() : -1;
%>
<form action="<%=request.getContextPath()%>/AssignResourcesController" method="post" onsubmit="return validation();">
    <input type="hidden" name="hdnAssignResourceId" value="<%= assignment.getAssignResourceId() %>">
    <h2>Edit Assign Site And Work</h2>
    <hr>
    <table border="0">
        <tr>
            <td>Employee Name:</td>
            <td>
                <select name="selEmpId" id="selEmpId" required>
                    <option value="-1">Select</option>
                    <% if (employees != null) { for (EmployeeInfoEntity emp : employees) { %>
                        <option value="<%= emp.getEmployeeInfoId() %>"
                            <%= (emp.getEmployeeInfoId() == currentEmpId) ? "selected=\"selected\"" : "" %>>
                            <%= (emp.getFirstName() != null ? emp.getFirstName() + " " : "") %>
                            <%= (emp.getMiddleName() != null ? emp.getMiddleName() + " " : "") %>
                            <%= (emp.getLastName() != null ? emp.getLastName() : "") %>
                        </option>
                    <% } } %>
                </select>
            </td>
            <td style="text-align: right;">Date:</td>
            <td>
                <input type="text" name="txtDate" id="txtDate"
                    pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                    oninvalid="setCustomValidity('Enter Date: Select From Calendar')"
                    onchange="setCustomValidity('')" title="Enter Date"
                    value="<%= (formattedDate != null ? formattedDate : "") %>"
                    placeholder="dd/mm/yyyy" required="required">
            </td>
        </tr>
        <tr>
            <td>For Which Site (Crop-Site Assignment):</td>
            <td>
                <select name="selCropToSiteId" id="selCropToSiteId">
                    <option value="-1">Select</option>
                    <% if (cropToSites != null) { for (AssignCropToSiteEntity cts : cropToSites) { %>
                        <option value="<%= cts.getAssignCroptoSiteId() %>"
                            <%= (cts.getAssignCroptoSiteId() == currentCropToSiteId) ? "selected=\"selected\"" : "" %>>
                            <%= (cts.getSiteInformationEntity() != null ? cts.getSiteInformationEntity().getSiteName() : "Site " + cts.getAssignCroptoSiteId()) %>
                            (<%= cts.getCropAssignDate() %>)
                        </option>
                    <% } } %>
                </select>
            </td>
            <td style="text-align: right;">For Which Crop:</td>
            <td>
                <select name="selCropId" id="selCropId">
                    <option value="-1">Select</option>
                    <% if (crops != null) { for (ConfigCropEntity crop : crops) { %>
                        <option value="<%= crop.getCropId() %>"
                            <%= (crop.getCropId() == currentCropId) ? "selected=\"selected\"" : "" %>>
                            <%= crop.getCropName() %>
                        </option>
                    <% } } %>
                </select>
            </td>
            <td>Type Of Work:</td>
            <td>
                <select name="selWorkType" id="selWorkType" required>
                    <option value="-1">Select</option>
                    <option value="Contract" <%= "Contract".equals(assignment.getTypeOfWork()) ? "selected=\"selected\"" : "" %>>Contract</option>
                    <option value="Per Day Payment" <%= "Per Day Payment".equals(assignment.getTypeOfWork()) ? "selected=\"selected\"" : "" %>>Per Day Payment</option>
                </select>
            </td>
        </tr>
        <tr>
            <td>Work:</td>
            <td>
                <select name="selWork" id="selWork" multiple="multiple" style="width: 150px">
                    <% if (tasks != null) {
                        List<ConfigFarmTaskEntity> currentTasks = assignment.getListFarmTaskEntities();
                        for (ConfigFarmTaskEntity task : tasks) {
                            boolean selected = false;
                            if (currentTasks != null) {
                                for (ConfigFarmTaskEntity ct : currentTasks) {
                                    if (ct.getTaskId() == task.getTaskId()) { selected = true; break; }
                                }
                            }
                    %>
                        <option value="<%= task.getTaskId() %>" <%= selected ? "selected=\"selected\"" : "" %>>
                            <%= task.getTaskName() %>
                        </option>
                    <% } } %>
                </select>
            </td>
            <td style="text-align: right;">Amount:</td>
            <td><input type="text" name="txtAmount" id="txtAmount" value="<%= assignment.getAmount() %>"></td>
            <td>Advance Payment:</td>
            <td><input type="text" name="txtAdvPayment" id="txtAdvPayment" value="<%= assignment.getAdvPayment() %>"></td>
        </tr>
        <tr>
            <td style="text-align: right;">Work Status:</td>
            <td>
                <select name="selWorkStatus" id="selWorkStatus" required>
                    <option value="-1">Select</option>
                    <option value="Completed" <%= "Completed".equals(assignment.getWorkStatus()) ? "selected=\"selected\"" : "" %>>Completed</option>
                    <option value="Pending" <%= "Pending".equals(assignment.getWorkStatus()) ? "selected=\"selected\"" : "" %>>Pending</option>
                    <option value="Reject" <%= "Reject".equals(assignment.getWorkStatus()) ? "selected=\"selected\"" : "" %>>Reject</option>
                </select>
            </td>
            <td>Comment:</td>
            <td colspan="3">
                <textarea name="txtComment" id="txtComment" cols="40" rows="2"><%= (assignment.getComment() != null ? assignment.getComment() : "") %></textarea>
            </td>
        </tr>
        <tr>
            <td colspan="6" style="text-align: center;"><br>
                <input type="submit" name="sbtSave" id="sbtSave" value="Save">
                <input type="button" value="Cancel" onclick="window.location='<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp'">
            </td>
        </tr>
    </table>
</form>
<% } %>
</div>
<%@include file="../../footer.jsp"%>
</body>
</html>
