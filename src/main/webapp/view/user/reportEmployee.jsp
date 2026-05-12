<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.dao.EmployeeInfoService"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css"/>
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<title>Employee Payment Report</title>
</head>
<style>
    .tbl-export-btns { display:flex; gap:6px; }
    .btn-tbl-csv     { background:#217346; color:#fff; border:none; padding:3px 10px;
                       border-radius:var(--r-sm,3px); font-size:11px; font-weight:600; cursor:pointer; }
    .btn-tbl-csv:hover { background:#1a5c38; }
    .section-hdr     { display:flex; align-items:center; justify-content:space-between;
                       margin:6px 0 10px; }
    .section-hdr h3  { margin:0; color:var(--green-dk); font-size:1em; }
    .section-hdr small { font-size:0.78em; font-weight:normal; color:var(--text-muted); }
</style>
<script>
var summaryDt = null, detailDt = null;

$(document).ready(function() {
    var dtOpts = {
        destroy: true,
        pageLength: 25,
        lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
        autoWidth: false, scrollX: true,
        columnDefs: [{ orderable: false, targets: [0] }],
        language: {
            search: '', searchPlaceholder: 'Search...',
            lengthMenu: 'Show _MENU_ entries',
            info: '_START_ – _END_ of _TOTAL_',
            infoEmpty: '0 entries', emptyTable: 'No records found',
            paginate: { previous: '&#8249;', next: '&#8250;' }
        },
        dom: '<"dt-toolbar"lf>rt<"dt-footer"ip>'
    };
    if ($('#empSummaryTable').length) summaryDt = $('#empSummaryTable').DataTable(dtOpts);
    if ($('#empDetailTable').length)  detailDt  = $('#empDetailTable').DataTable(dtOpts);
});

/* ── CSV export ── */
function exportCSV(dt, filename) {
    if (!dt) return;
    var cols = [];
    $(dt.table().header()).find('th').each(function() { cols.push($(this).text().trim()); });
    var rows = dt.rows({search:'applied'}).data();

    function escCsv(val) {
        var s = $('<div/>').html(String(val)).text().replace(/\r?\n/g,' ').trim();
        return (s.indexOf(',') !== -1 || s.indexOf('"') !== -1)
            ? '"' + s.replace(/"/g,'""') + '"' : s;
    }

    var csv = cols.map(escCsv).join(',') + '\r\n';
    for (var i = 0; i < rows.length; i++) {
        var line = [];
        for (var j = 0; j < rows[i].length; j++) line.push(escCsv(rows[i][j]));
        csv += line.join(',') + '\r\n';
    }

    /* UTF-8 BOM so Excel / mobile apps render ₹ and Indian names correctly */
    var blob = new Blob(['﻿' + csv], {type:'text/csv;charset=utf-8'});
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement('a');
    a.href = url;
    a.download = filename + '_' + new Date().toISOString().slice(0,10) + '.csv';
    document.body.appendChild(a); a.click();
    document.body.removeChild(a); URL.revokeObjectURL(url);
}
</script>
<body>
<%@include file="../../header.jsp" %>

<%
    int selectedEmpId = -1;
    String empIdParam = request.getParameter("empId");
    if (empIdParam != null && !empIdParam.isEmpty()) {
        try { selectedEmpId = Integer.parseInt(empIdParam.trim()); } catch (Exception e) { selectedEmpId = -1; }
    }

    EmployeeInfoService empService = new EmployeeInfoService();
    AssignResourceEmployeeToFarmService farmService = new AssignResourceEmployeeToFarmService();
    PaymentProcessingDao salaryDao = new PaymentProcessingDao();
    List<EmployeeInfoEntity> employees = empService.getListOfEmployee();
%>

<fieldset>
<legend>Employee Task &amp; Payment Report</legend>

<!-- Employee filter -->
<form method="get" action="reportEmployee.jsp">
    <div class="rpt-filter-bar">
        <label>Employee:</label>
        <select name="empId" onchange="this.form.submit()">
            <option value="">-- All Employees --</option>
            <% for (EmployeeInfoEntity emp : employees) {
                String fn = (emp.getFirstName() != null ? emp.getFirstName() + " " : "")
                          + (emp.getMiddleName() != null ? emp.getMiddleName() + " " : "")
                          + (emp.getLastName() != null ? emp.getLastName() : "");
            %>
            <option value="<%=emp.getEmployeeInfoId()%>"
                <%=emp.getEmployeeInfoId() == selectedEmpId ? "selected=\"selected\"" : ""%>><%=fn.trim()%></option>
            <% } %>
        </select>
        <% if (selectedEmpId > 0) { %>
        <a href="reportEmployee.jsp" style="font-size:12px; color:var(--red-md); text-decoration:none;">&#10005; Clear</a>
        <% } %>
    </div>
</form>

<%
if (selectedEmpId > 0) {
    // ===== SINGLE EMPLOYEE DETAIL VIEW =====
    EmployeeInfoEntity selEmp = empService.getEmployeeById(selectedEmpId);
    List<AssignEmployeeToFarmEntity> empAssignments = farmService.getListByEmployeeInfoId(selectedEmpId);

    // Pre-compute salary per assignment
    Map<Integer, Double> salMap = new LinkedHashMap<Integer, Double>();
    for (AssignEmployeeToFarmEntity aef : empAssignments) {
        salMap.put(aef.getAssignResourceId(),
            salaryDao.getTotalSalaryPaidByAssignResourceId(aef.getAssignResourceId()));
    }

    // Compute summary totals
    double ttlAssigned = 0, ttlAdv = 0, ttlSalary = 0;
    int doneCount = 0, pendingCount = 0;
    for (AssignEmployeeToFarmEntity aef : empAssignments) {
        ttlAssigned += aef.getAmount();
        ttlAdv += aef.getAdvPayment();
        ttlSalary += salMap.containsKey(aef.getAssignResourceId()) ? salMap.get(aef.getAssignResourceId()) : 0;
        if ("Completed".equals(aef.getWorkStatus())) doneCount++;
        else pendingCount++;
    }
    double ttlPaid = ttlAdv + ttlSalary;
    double ttlBalance = ttlAssigned - ttlPaid;
    double ttlExcess = 0;
    if (ttlBalance < 0) { ttlExcess = -ttlBalance; ttlBalance = 0; }

    String empFullName = selEmp != null
        ? ((selEmp.getFirstName() != null ? selEmp.getFirstName() + " " : "")
         + (selEmp.getMiddleName() != null ? selEmp.getMiddleName() + " " : "")
         + (selEmp.getLastName() != null ? selEmp.getLastName() : "")).trim()
        : "";
%>

<div class="section-hdr">
    <h3><%=empFullName%></h3>
    <div class="tbl-export-btns">
        <button class="btn-tbl-csv" onclick="exportCSV(detailDt,'EmployeeDetail_<%=empFullName.trim().replace(" ","_")%>')">&#8595; Download CSV</button>
    </div>
</div>

<!-- Summary cards -->
<div class="report-summary-bar">
    <div class="rpt-card">
        <div class="rpt-label">Total Assigned</div>
        <div class="rpt-val">Rs <%=String.format("%.2f", ttlAssigned)%></div>
    </div>
    <div class="rpt-card">
        <div class="rpt-label">Advance Paid</div>
        <div class="rpt-val" style="color:var(--text-muted);">Rs <%=String.format("%.2f", ttlAdv)%></div>
    </div>
    <div class="rpt-card">
        <div class="rpt-label">Salary Paid</div>
        <div class="rpt-val">Rs <%=String.format("%.2f", ttlSalary)%></div>
    </div>
    <div class="rpt-card">
        <div class="rpt-label">Total Paid</div>
        <div class="rpt-val">Rs <%=String.format("%.2f", ttlPaid)%></div>
    </div>
    <div class="rpt-card <%=ttlBalance > 0 ? "rpt-danger" : ""%>">
        <div class="rpt-label">Balance Due</div>
        <div class="rpt-val">Rs <%=String.format("%.2f", ttlBalance)%></div>
    </div>
    <% if (ttlExcess > 0) { %>
    <div class="rpt-card rpt-warn">
        <div class="rpt-label">Excess Paid</div>
        <div class="rpt-val">Rs <%=String.format("%.2f", ttlExcess)%></div>
    </div>
    <% } %>
    <div class="rpt-card rpt-ok">
        <div class="rpt-label">Tasks Done</div>
        <div class="rpt-val"><%=doneCount%></div>
    </div>
    <div class="rpt-card <%=pendingCount > 0 ? "rpt-warn" : ""%>">
        <div class="rpt-label">Tasks Pending</div>
        <div class="rpt-val"><%=pendingCount%></div>
    </div>
</div>

<!-- Assignment detail table -->
<table id="empDetailTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Sr.</th>
        <th>Date</th>
        <th>Site</th>
        <th>Crop</th>
        <th>Work Type</th>
        <th>Work Status</th>
        <th>Tasks Assigned</th>
        <th>Amount (Rs)</th>
        <th>Adv Paid (Rs)</th>
        <th>Salary Paid (Rs)</th>
        <th>Balance (Rs)</th>
        <th>Excess (Rs)</th>
    </tr>
    </thead>
    <tbody>
    <%
        int empDCnt = 0;
        double dTtlAmt = 0, dTtlAdv = 0, dTtlSal = 0, dTtlBal = 0, dTtlExc = 0;
        for (AssignEmployeeToFarmEntity aef : empAssignments) {
            if (aef == null) continue;
            empDCnt++;
            double salPaid = salMap.containsKey(aef.getAssignResourceId()) ? salMap.get(aef.getAssignResourceId()) : 0;
            double totalPaidRow = aef.getAdvPayment() + salPaid;
            double balRow = aef.getAmount() - totalPaidRow;
            double excRow = 0;
            if (balRow < 0) { excRow = -balRow; balRow = 0; }
            dTtlAmt += aef.getAmount(); dTtlAdv += aef.getAdvPayment();
            dTtlSal += salPaid; dTtlBal += balRow; dTtlExc += excRow;

            String siteName = "";
            if (aef.getCropToSiteEntity() != null && aef.getCropToSiteEntity().getSiteInformationEntity() != null)
                siteName = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
            String cropName = aef.getCropEntity() != null ? aef.getCropEntity().getCropName() : "";
            StringBuilder tasks = new StringBuilder();
            int ti = 0;
            for (ConfigFarmTaskEntity t : aef.getListFarmTaskEntities()) {
                if (ti++ > 0) tasks.append(", ");
                tasks.append(t.getTaskName());
            }
            String ws = aef.getWorkStatus() != null ? aef.getWorkStatus() : "";
            String wsStyle = "Completed".equals(ws) ? "color:#155724;font-weight:bold;"
                           : "Pending".equals(ws)   ? "color:#856404;font-weight:bold;"
                           : "Reject".equals(ws)    ? "color:#721c24;font-weight:bold;" : "";
    %>
    <tr>
        <td><%=empDCnt%></td>
        <td><%=aef.getAssignWorkDate() != null ? FarmUtility.convertfrom_yymmddToddmmyy(aef.getAssignWorkDate().toString()) : ""%></td>
        <td><%=siteName%></td>
        <td><%=cropName%></td>
        <td><%=aef.getTypeOfWork() != null ? aef.getTypeOfWork() : ""%></td>
        <td style="<%=wsStyle%>"><%=ws%></td>
        <td><%=tasks.toString()%></td>
        <td><%=String.format("%.2f", aef.getAmount())%></td>
        <td><%=String.format("%.2f", aef.getAdvPayment())%></td>
        <td><%=String.format("%.2f", salPaid)%></td>
        <td><%=String.format("%.2f", balRow)%></td>
        <td><%=String.format("%.2f", excRow)%></td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="7" style="text-align:right;">Total</td>
        <td><%=String.format("%.2f", dTtlAmt)%></td>
        <td><%=String.format("%.2f", dTtlAdv)%></td>
        <td><%=String.format("%.2f", dTtlSal)%></td>
        <td><%=String.format("%.2f", dTtlBal)%></td>
        <td><%=String.format("%.2f", dTtlExc)%></td>
    </tr>
    </tfoot>
</table>

<% } else { %>

<!-- ===== ALL EMPLOYEES SUMMARY TABLE ===== -->
<div class="section-hdr">
    <h3>All Employees Summary <small>(click employee name for details)</small></h3>
    <div class="tbl-export-btns">
        <button class="btn-tbl-csv" onclick="exportCSV(summaryDt,'EmployeePayments_Summary')">&#8595; Download CSV</button>
    </div>
</div>
<table id="empSummaryTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Sr.</th>
        <th>Employee</th>
        <th>Total Assigned (Rs)</th>
        <th>Advance Paid (Rs)</th>
        <th>Salary Paid (Rs)</th>
        <th>Total Paid (Rs)</th>
        <th>Balance (Rs)</th>
        <th>Excess Paid (Rs)</th>
        <th>Done</th>
        <th>Pending</th>
    </tr>
    </thead>
    <tbody>
    <%
        int empCnt = 0;
        double gAssigned = 0, gAdv = 0, gSalary = 0, gBalance = 0, gExcess = 0;
        for (EmployeeInfoEntity emp : employees) {
            empCnt++;
            double[] amtAdv = farmService.getTotalAmountAndAdvByEmployeeInfoId(emp.getEmployeeInfoId());
            double eAssigned = amtAdv[0];
            double eAdv = amtAdv[1];
            double eSalary = salaryDao.getTotalSalaryPaidByEmployeeInfoId(emp.getEmployeeInfoId());
            double ePaid = eAdv + eSalary;
            double eBalance = eAssigned - ePaid;
            double eExcess = 0;
            if (eBalance < 0) { eExcess = -eBalance; eBalance = 0; }
            gAssigned += eAssigned; gAdv += eAdv; gSalary += eSalary;
            gBalance += eBalance; gExcess += eExcess;

            List<AssignEmployeeToFarmEntity> eList = farmService.getListByEmployeeInfoId(emp.getEmployeeInfoId());
            int eDone = 0, ePending = 0;
            for (AssignEmployeeToFarmEntity aef : eList) {
                if ("Completed".equals(aef.getWorkStatus())) eDone++; else ePending++;
            }
            String fn = (emp.getFirstName() != null ? emp.getFirstName() + " " : "")
                      + (emp.getMiddleName() != null ? emp.getMiddleName() + " " : "")
                      + (emp.getLastName() != null ? emp.getLastName() : "");
    %>
    <tr>
        <td><%=empCnt%></td>
        <td><a href="reportEmployee.jsp?empId=<%=emp.getEmployeeInfoId()%>"><%=fn.trim()%></a></td>
        <td><%=String.format("%.2f", eAssigned)%></td>
        <td><%=String.format("%.2f", eAdv)%></td>
        <td><%=String.format("%.2f", eSalary)%></td>
        <td><%=String.format("%.2f", ePaid)%></td>
        <td><%=eBalance > 0 ? "<span style='color:var(--red-md);font-weight:bold;'>" + String.format("%.2f", eBalance) + "</span>" : String.format("%.2f", eBalance)%></td>
        <td><%=eExcess > 0 ? "<span style='color:#e65100;font-weight:bold;'>" + String.format("%.2f", eExcess) + "</span>" : String.format("%.2f", eExcess)%></td>
        <td style="color:#155724; font-weight:bold;"><%=eDone%></td>
        <td style="<%=ePending > 0 ? "color:#856404;font-weight:bold;" : ""%>"><%=ePending%></td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="2" style="text-align:right;">Grand Total</td>
        <td><%=String.format("%.2f", gAssigned)%></td>
        <td><%=String.format("%.2f", gAdv)%></td>
        <td><%=String.format("%.2f", gSalary)%></td>
        <td><%=String.format("%.2f", gAdv + gSalary)%></td>
        <td><%=String.format("%.2f", gBalance)%></td>
        <td><%=String.format("%.2f", gExcess)%></td>
        <td colspan="2"></td>
    </tr>
    </tfoot>
</table>

<% } %>
</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
