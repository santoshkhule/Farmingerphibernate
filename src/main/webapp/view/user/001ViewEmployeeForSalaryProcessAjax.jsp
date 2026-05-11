<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
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
    SalaryProcessingDao salaryDao = new SalaryProcessingDao();

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

    double ttlAmountToPay = 0, ttlAdvancedPaid = 0, ttlAmountPaid = 0;
    double ttlBalance = 0, ttlExcessAmount = 0;
%>
<table border="1" cellspacing="0" width="100%" class="tbl-data">
    <thead>
    <tr>
        <th>Select</th>
        <th>Sr. No.</th>
        <th>Name</th>
        <th>Date</th>
        <th>Site Name</th>
        <th>Crop Name</th>
        <th>Work Type</th>
        <th>Work Status</th>
        <th>Assign Work</th>
        <th>Amount To Pay</th>
        <th>Advanced Paid</th>
        <th>Amount Paid</th>
        <th>Balance</th>
        <th>Excess Amount</th>
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
        double excessAmount    = 0;
        if (balanceAmount < 0) { excessAmount = -balanceAmount; balanceAmount = 0; }
        ttlAmountToPay  += employeeToFarm.getAmount();
        ttlAdvancedPaid += employeeToFarm.getAdvPayment();
        ttlAmountPaid   += totalSalaryPaid;
        ttlBalance      += balanceAmount;
        ttlExcessAmount += excessAmount;
%>
    <tr>
        <td style="text-align:center;">
            <input type="radio" name="radAssignWorkId" value="<%=assignResourceId%>"
                   onclick="processSalary(<%=assignResourceId%>);">
        </td>
        <td><%=cnt%></td>
        <td><%
            if (employeeToFarm.getEmployeeInfoEntity() != null) {
                if (employeeToFarm.getEmployeeInfoEntity().getFirstName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName() + " ");
                if (employeeToFarm.getEmployeeInfoEntity().getMiddleName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName() + " ");
                if (employeeToFarm.getEmployeeInfoEntity().getLastName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
            }
        %></td>
        <td><%=employeeToFarm.getAssignWorkDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()) : ""%></td>
        <td><%=employeeToFarm.getCropToSiteEntity() != null
            && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null
            ? employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() : ""%></td>
        <td><%=employeeToFarm.getCropEntity() != null ? employeeToFarm.getCropEntity().getCropName() : ""%></td>
        <td><%=employeeToFarm.getTypeOfWork() != null ? employeeToFarm.getTypeOfWork() : ""%></td>
        <td><%=employeeToFarm.getWorkStatus() != null ? employeeToFarm.getWorkStatus() : ""%></td>
        <td><%
            int ti = 0;
            for (ConfigFarmTaskEntity t : employeeToFarm.getListFarmTaskEntities()) {
                if (ti++ > 0) out.print(", ");
                out.print(t.getTaskName());
            }
        %></td>
        <td><%=employeeToFarm.getAmount()%></td>
        <td><%=employeeToFarm.getAdvPayment()%></td>
        <td><%=totalSalaryPaid%></td>
        <td><%=balanceAmount%></td>
        <td><%=excessAmount%></td>
    </tr>
<%
    }
%>
    </tbody>
    <tfoot>
    <tr>
        <td style="font-weight:bold; text-align:right;" colspan="9">Total</td>
        <td><b><%=ttlAmountToPay%></b></td>
        <td><b><%=ttlAdvancedPaid%></b></td>
        <td><b><%=ttlAmountPaid%></b></td>
        <td><b><%=ttlBalance%></b></td>
        <td><b><%=ttlExcessAmount%></b></td>
    </tr>
    </tfoot>
</table>
