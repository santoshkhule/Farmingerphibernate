<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css"/>
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<title>Site Expenditure Report</title>
</head>
<script>
$(document).ready(function() {
    var dtOpts = {
        pageLength: 25,
        lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
        autoWidth: false, scrollX: true,
        language: {
            search: '', searchPlaceholder: 'Search...',
            lengthMenu: 'Show _MENU_ entries',
            info: '_START_ - _END_ of _TOTAL_',
            infoEmpty: '0 entries', emptyTable: 'No records found',
            paginate: { previous: '&#8249;', next: '&#8250;' }
        },
        dom: '<"dt-toolbar"lf>rt<"dt-footer"ip>'
    };
    $('#siteSummaryTable').DataTable($.extend({}, dtOpts, {
        columnDefs: [{ orderable: false, targets: [7] }]
    }));
    $('#siteDetailTable').DataTable($.extend({}, dtOpts, {
        columnDefs: [{ orderable: false, targets: [0] }]
    }));
});
</script>
<body>
<%@include file="../../header.jsp" %>

<%
    AssignResourceEmployeeToFarmService farmService = new AssignResourceEmployeeToFarmService();
    SalaryProcessingDao salaryDao = new SalaryProcessingDao();

    List<AssignEmployeeToFarmEntity> allAssignments = farmService.getListOFEmployeeToFarm();

    // Pre-compute salary paid per assignment
    Map<Integer, Double> salaryByAssignId = new LinkedHashMap<Integer, Double>();
    for (AssignEmployeeToFarmEntity aef : allAssignments) {
        salaryByAssignId.put(aef.getAssignResourceId(),
            salaryDao.getTotalSalaryPaidByAssignResourceId(aef.getAssignResourceId()));
    }

    // Group by (siteInfoId, date) — key = "siteId|dd/mm/yyyy"
    // stats[]: [0]=assigned [1]=paid [2]=done [3]=pending
    Map<String, double[]>  sdStats  = new LinkedHashMap<String, double[]>();
    Map<String, String[]>  sdLabels = new LinkedHashMap<String, String[]>(); // [siteName, dateDisplay]

    for (AssignEmployeeToFarmEntity aef : allAssignments) {
        if (aef.getCropToSiteEntity() == null || aef.getCropToSiteEntity().getSiteInformationEntity() == null) continue;
        int    siteId   = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteInfoId();
        String siteName = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
        String dateDisp = aef.getAssignWorkDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(aef.getAssignWorkDate().toString()) : "";
        String key = siteId + "|" + dateDisp;

        if (!sdStats.containsKey(key)) {
            sdStats.put(key, new double[]{0, 0, 0, 0});
            sdLabels.put(key, new String[]{siteName != null ? siteName : "", dateDisp});
        }
        double sp = salaryByAssignId.containsKey(aef.getAssignResourceId())
            ? salaryByAssignId.get(aef.getAssignResourceId()) : 0;
        double[] s = sdStats.get(key);
        s[0] += aef.getAmount();
        s[1] += aef.getAdvPayment() + sp;
        if ("Completed".equals(aef.getWorkStatus())) s[2]++;
        else s[3]++;
    }
%>

<fieldset>
<legend>Site Expenditure &amp; Dispatch Status Report</legend>

<!-- ===== SITE SUMMARY TABLE (grouped by site + date) ===== -->
<h3 style="margin:8px 0 8px; color:var(--green-dk); font-size:1em;">Site Summary — by Site &amp; Date</h3>
<table id="siteSummaryTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Sr.</th>
        <th>Site</th>
        <th>Date</th>
        <th>Total Assigned (Rs)</th>
        <th>Total Paid (Rs)</th>
        <th>Balance (Rs)</th>
        <th>Done / Pending</th>
        <th>Status</th>
    </tr>
    </thead>
    <tbody>
    <%
        int siteCnt = 0;
        double grandAssigned = 0, grandPaid = 0;
        for (Map.Entry<String, double[]> entry : sdStats.entrySet()) {
            siteCnt++;
            String[]  lbl     = sdLabels.get(entry.getKey());
            double[]  s       = entry.getValue();
            double rowBalance = Math.max(0, s[0] - s[1]);
            int rowDone    = (int) s[2];
            int rowPending = (int) s[3];
            boolean ready  = (rowDone > 0 || rowPending > 0) && rowPending == 0;
            grandAssigned += s[0];
            grandPaid     += s[1];
    %>
    <tr>
        <td><%=siteCnt%></td>
        <td><%=lbl[0]%></td>
        <td><%=lbl[1]%></td>
        <td><%=String.format("%.2f", s[0])%></td>
        <td><%=String.format("%.2f", s[1])%></td>
        <td><%=String.format("%.2f", rowBalance)%></td>
        <td style="text-align:center;"><%=rowDone%>&nbsp;/&nbsp;<%=rowPending%></td>
        <td style="text-align:center;">
            <% if (rowDone == 0 && rowPending == 0) { %>
                <span class="dispatch-badge pending">No Tasks</span>
            <% } else if (ready) { %>
                <span class="dispatch-badge ready">&#10003; All Done</span>
            <% } else { %>
                <span class="dispatch-badge pending">&#9888; <%=rowPending%> Pending</span>
            <% } %>
        </td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="3" style="text-align:right;">Grand Total</td>
        <td><%=String.format("%.2f", grandAssigned)%></td>
        <td><%=String.format("%.2f", grandPaid)%></td>
        <td><%=String.format("%.2f", Math.max(0, grandAssigned - grandPaid))%></td>
        <td colspan="2"></td>
    </tr>
    </tfoot>
</table>

<hr>

<!-- ===== ASSIGNMENT DETAIL TABLE ===== -->
<h3 style="margin:12px 0 8px; color:var(--green-dk); font-size:1em;">
    Assignment Details &mdash; All Sites
    <span style="font-size:0.78em; font-weight:normal; color:var(--text-muted);">
        (use search box to filter by site, employee, or crop)
    </span>
</h3>
<table id="siteDetailTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Sr.</th>
        <th>Date</th>
        <th>Site</th>
        <th>Crop</th>
        <th>Employee</th>
        <th>Work Type</th>
        <th>Work Status</th>
        <th>Tasks Assigned</th>
        <th>Amount (Rs)</th>
        <th>Adv Paid (Rs)</th>
        <th>Salary Paid (Rs)</th>
        <th>Balance (Rs)</th>
    </tr>
    </thead>
    <tbody>
    <%
        int detailCnt = 0;
        double ttlAmt = 0, ttlAdv = 0, ttlSal = 0;
        for (AssignEmployeeToFarmEntity aef : allAssignments) {
            if (aef == null) continue;
            detailCnt++;
            double salPaid = salaryByAssignId.containsKey(aef.getAssignResourceId())
                ? salaryByAssignId.get(aef.getAssignResourceId()) : 0;
            double totalPaidRow = aef.getAdvPayment() + salPaid;
            double balRow = Math.max(0, aef.getAmount() - totalPaidRow);
            ttlAmt += aef.getAmount(); ttlAdv += aef.getAdvPayment(); ttlSal += salPaid;

            String empName = "";
            if (aef.getEmployeeInfoEntity() != null) {
                if (aef.getEmployeeInfoEntity().getFirstName() != null)  empName += aef.getEmployeeInfoEntity().getFirstName() + " ";
                if (aef.getEmployeeInfoEntity().getMiddleName() != null) empName += aef.getEmployeeInfoEntity().getMiddleName() + " ";
                if (aef.getEmployeeInfoEntity().getLastName() != null)   empName += aef.getEmployeeInfoEntity().getLastName();
            }
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
                           : "Pending".equals(ws) ? "color:#856404;font-weight:bold;"
                           : "Reject".equals(ws) ? "color:#721c24;font-weight:bold;" : "";
    %>
    <tr>
        <td><%=detailCnt%></td>
        <td><%=aef.getAssignWorkDate() != null ? FarmUtility.convertfrom_yymmddToddmmyy(aef.getAssignWorkDate().toString()) : ""%></td>
        <td><%=siteName%></td>
        <td><%=cropName%></td>
        <td><%=empName.trim()%></td>
        <td><%=aef.getTypeOfWork() != null ? aef.getTypeOfWork() : ""%></td>
        <td style="<%=wsStyle%>"><%=ws%></td>
        <td><%=tasks.toString()%></td>
        <td><%=String.format("%.2f", aef.getAmount())%></td>
        <td><%=String.format("%.2f", aef.getAdvPayment())%></td>
        <td><%=String.format("%.2f", salPaid)%></td>
        <td><%=String.format("%.2f", balRow)%></td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="8" style="text-align:right;">Total</td>
        <td><%=String.format("%.2f", ttlAmt)%></td>
        <td><%=String.format("%.2f", ttlAdv)%></td>
        <td><%=String.format("%.2f", ttlSal)%></td>
        <td><%=String.format("%.2f", Math.max(0, ttlAmt - ttlAdv - ttlSal))%></td>
    </tr>
    </tfoot>
</table>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
