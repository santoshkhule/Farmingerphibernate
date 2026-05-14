<%@page import="java.sql.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    String fromDateParam   = request.getParameter("fromDate");
    String empNameParam    = request.getParameter("empName");
    String workStatusParam = request.getParameter("work_status");
    String workIdParam     = request.getParameter("work_Id");

    String assignWorkDate = null;
    String workStatus     = null;
    String empName        = null;
    int    taskId         = 0;

    if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
        assignWorkDate = FarmUtility.convertfrom_ddmmyyToyymmdd(fromDateParam.trim());
    }
    if (empNameParam != null && !empNameParam.trim().isEmpty()) {
        empName = empNameParam.trim();
    }
    if (workStatusParam != null && !workStatusParam.trim().isEmpty() && !workStatusParam.equals("-1")) {
        workStatus = workStatusParam.trim();
    }
    if (workIdParam != null && !workIdParam.trim().isEmpty() && !workIdParam.equals("-1")) {
        try { taskId = Integer.parseInt(workIdParam.trim()); } catch (Exception e) { taskId = 0; }
    }

    AssignResourceEmployeeToFarmService farmService = new AssignResourceEmployeeToFarmService();
    PaymentProcessingDao salaryDao = new PaymentProcessingDao();

    StringBuilder query = new StringBuilder("from AssignEmployeeToFarmEntity a");
    List<String> conditions = new ArrayList<String>();

    if (assignWorkDate != null) {
        conditions.add("a.assignWorkDate = '" + Date.valueOf(assignWorkDate) + "'");
    }
    if (empName != null) {
        conditions.add("(a.employeeInfoEntity.firstName like '%" + empName + "%'" +
                       " or a.employeeInfoEntity.middleName like '%" + empName + "%'" +
                       " or a.employeeInfoEntity.lastName like '%" + empName + "%')");
    }
    if (workStatus != null) {
        conditions.add("a.workStatus = '" + workStatus + "'");
    }
    if (taskId > 0) {
        conditions.add("a.assignResourceId in (" +
            "select a2.assignResourceId from AssignEmployeeToFarmEntity a2 " +
            "join a2.listFarmTaskEntities t where t.taskId = " + taskId + ")");
    }

    if (!conditions.isEmpty()) {
        query.append(" where ");
        for (int i = 0; i < conditions.size(); i++) {
            if (i > 0) query.append(" and ");
            query.append(conditions.get(i));
        }
    }

    List<AssignEmployeeToFarmEntity> entities = null;
    try {
        entities = farmService.getListOFEmployeeToFarmByQry(query.toString());
    } catch (Exception ex) {
        ex.printStackTrace();
        entities = new ArrayList<AssignEmployeeToFarmEntity>();
    }

    double ttlAmountToPay = 0, ttlBalance = 0;
%>
<style>
    .ws-pill { display:inline-block; padding:2px 8px; border-radius:8px; font-size:10px; font-weight:700; white-space:nowrap; }
    .ws-Completed { background:#e8f5e9; color:#1b5e20; }
    .ws-Pending   { background:#fdecea; color:#b71c1c; }
    .ws-default   { background:#f5f5f5; color:#757575; }
    .btn-select { background:var(--green-lt,#e8f5e9); border:1px solid var(--green-bd,#a5d6a7);
        color:var(--green-dk,#1b5e20); padding:2px 10px; cursor:pointer;
        border-radius:3px; font-size:11px; font-family:inherit; }
    .btn-select:hover { background:#c8e6c9; }
</style>
<table border="1" cellspacing="0" width="100%" class="tbl-data">
    <thead>
    <tr>
        <th width="6%">Select</th>
        <th width="4%">#</th>
        <th>Name</th>
        <th width="9%">Date</th>
        <th>Site Name</th>
        <th width="10%">Work Type</th>
        <th width="9%">Status</th>
        <th width="9%">Amount</th>
        <th width="9%">Balance</th>
    </tr>
    </thead>
    <tbody>
<%
    int cnt = 0;
    for (AssignEmployeeToFarmEntity employeeToFarm : entities) {
        if (employeeToFarm == null) continue;
        cnt++;
        int assignResourceId = employeeToFarm.getAssignResourceId();
        double totalSalaryPaid = salaryDao.getTotalSalaryPaidByAssignResourceId(assignResourceId);
        double totalPaid       = employeeToFarm.getAdvPayment() + totalSalaryPaid;
        double balanceAmount   = employeeToFarm.getAmount() - totalPaid;
        if (balanceAmount < 0) balanceAmount = 0;
        ttlAmountToPay += employeeToFarm.getAmount();
        ttlBalance     += balanceAmount;

        String ws = employeeToFarm.getWorkStatus() != null ? employeeToFarm.getWorkStatus() : "";
        String wsClass = "Completed".equalsIgnoreCase(ws) ? "ws-Completed"
                       : "Pending".equalsIgnoreCase(ws)   ? "ws-Pending"
                       : "ws-default";

        String empFullName = "";
        if (employeeToFarm.getEmployeeInfoEntity() != null) {
            if (employeeToFarm.getEmployeeInfoEntity().getFirstName()  != null) empFullName += employeeToFarm.getEmployeeInfoEntity().getFirstName()  + " ";
            if (employeeToFarm.getEmployeeInfoEntity().getMiddleName() != null) empFullName += employeeToFarm.getEmployeeInfoEntity().getMiddleName() + " ";
            if (employeeToFarm.getEmployeeInfoEntity().getLastName()   != null) empFullName += employeeToFarm.getEmployeeInfoEntity().getLastName();
        }
        empFullName = empFullName.trim();

        String siteName = (employeeToFarm.getCropToSiteEntity() != null
            && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null)
            ? employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() : "";
%>
    <tr>
        <td style="text-align:center;">
            <button type="button" class="btn-select" onclick="processSalary(<%=assignResourceId%>)">Select</button>
        </td>
        <td><%=cnt%></td>
        <td><%=empFullName%></td>
        <td><%=employeeToFarm.getAssignWorkDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()) : ""%></td>
        <td><%=siteName%></td>
        <td><%=employeeToFarm.getTypeOfWork() != null ? employeeToFarm.getTypeOfWork() : ""%></td>
        <td style="text-align:center;"><span class="ws-pill <%=wsClass%>"><%=ws.isEmpty() ? "—" : ws%></span></td>
        <td style="text-align:right;"><%=employeeToFarm.getAmount()%></td>
        <td style="text-align:right;"><%=balanceAmount%></td>
    </tr>
<%
    }
%>
    </tbody>
    <tfoot>
    <tr>
        <td style="font-weight:bold; text-align:right;" colspan="7">Total</td>
        <td style="text-align:right;"><b><%=ttlAmountToPay%></b></td>
        <td style="text-align:right;"><b><%=ttlBalance%></b></td>
    </tr>
    </tfoot>
</table>
