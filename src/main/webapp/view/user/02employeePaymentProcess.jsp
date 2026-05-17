<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.entity.PaymentProcessingEntity"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    int assignResourceId = 0;
    String arparam = request.getParameter("assignResourceId");
    if (arparam != null && !arparam.trim().isEmpty()) {
        try { assignResourceId = Integer.parseInt(arparam.trim()); } catch (Exception e) {}
    }
    boolean hasSelection = assignResourceId > 0;

    AssignEmployeeToFarmEntity employeeToFarm = null;
    List<PaymentProcessingEntity> processingEntities = new ArrayList<PaymentProcessingEntity>();
    double amountToPay = 0, advPayment = 0, ttlPaid = 0, balance = 0;
    String empName = "", workDate = "", siteName = "", workType = "", workStatus = "";
    String defaultBankName = "", defaultAccountNo = "";

    if (hasSelection) {
        try {
            AssignResourceEmployeeToFarmService farmSvc = new AssignResourceEmployeeToFarmService();
            employeeToFarm = farmSvc.getEmployeeToFarmById(assignResourceId);
            PaymentProcessingDao salaryDao = new PaymentProcessingDao();
            processingEntities = salaryDao.getAllSalaryTransactionByAssignResourceId(assignResourceId);

            if (employeeToFarm != null) {
                amountToPay = employeeToFarm.getAmount();
                advPayment  = employeeToFarm.getAdvPayment();
                for (PaymentProcessingEntity pe : processingEntities) ttlPaid += pe.getAmount();
                balance = amountToPay - (advPayment + ttlPaid);
                if (balance < 0) balance = 0;

                EmployeeInfoEntity emp = employeeToFarm.getEmployeeInfoEntity();
                if (emp != null) {
                    StringBuilder sb = new StringBuilder();
                    if (emp.getFirstName()  != null) sb.append(emp.getFirstName()).append(" ");
                    if (emp.getMiddleName() != null) sb.append(emp.getMiddleName()).append(" ");
                    if (emp.getLastName()   != null) sb.append(emp.getLastName());
                    empName = sb.toString().trim();
                    if (emp.getBankName()      != null) defaultBankName  = emp.getBankName();
                    if (emp.getAccountNumber() != null) defaultAccountNo = emp.getAccountNumber();
                }
                if (employeeToFarm.getAssignWorkDate() != null)
                    workDate = FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString());
                if (employeeToFarm.getCropToSiteEntity() != null
                        && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null
                        && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() != null)
                    siteName = employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
                if (employeeToFarm.getTypeOfWork() != null) workType   = employeeToFarm.getTypeOfWork();
                if (employeeToFarm.getWorkStatus() != null) workStatus = employeeToFarm.getWorkStatus();
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    String safeBankName  = defaultBankName.replace("'", "\\'");
    String safeAccountNo = defaultAccountNo.replace("'", "\\'");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= msg.getString("payment.page_title") %></title>
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/jquery-ui.js"></script>
<style>
    /* ── Collapsible panels ── */
    .cpanel { margin-bottom: 12px; border: 1px solid var(--green-bd); border-radius: var(--r-md); background: #fff; box-shadow: var(--sh-sm); }
    .cpanel-head {
        display: flex; align-items: center; justify-content: space-between;
        padding: 9px 14px; background: var(--green-row);
        border-radius: var(--r-md) var(--r-md) 0 0; user-select: none;
    }
    .cpanel-head.clickable { cursor: pointer; }
    .cpanel-head.clickable:hover { background: var(--green-bd); }
    .cpanel-head h3 { margin: 0; font-size: 13px; color: var(--green-dk); font-weight: 700; }
    .cpanel-sub { font-weight: 400; font-size: 11px; color: var(--green-md); margin-left: 8px; }
    .cpanel-chevron { font-size: 11px; color: var(--green-dk); display: inline-block; transition: transform 0.2s; }
    .cpanel-chevron.open { transform: rotate(180deg); }
    .cpanel-body { padding: 12px 14px; }

    /* ── Filter bar ── */
    .filter-bar { display: flex; flex-wrap: wrap; gap: 8px 14px; align-items: flex-end; margin-bottom: 10px; }
    .filter-field { display: flex; flex-direction: column; gap: 3px; }
    .filter-field label { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; color: var(--text-muted); }
    .filter-field input, .filter-field select {
        padding: 5px 8px; border: 1px solid var(--gray-400); border-radius: var(--r-sm);
        font-size: 12px; font-family: inherit; outline: none; width: 130px;
        transition: border-color 0.15s;
    }
    .filter-field input:focus, .filter-field select:focus { border-color: var(--green-md); }

    #showTable { width: 100%; overflow-x: auto; }
    #showTable table.tbl-data { min-width: 650px; }

    /* ── Info strip (selected assignment summary) ── */
    .info-strip {
        display: flex; flex-wrap: wrap; gap: 6px 10px; margin-bottom: 10px;
        padding: 8px 12px; background: var(--gray-100); border-radius: var(--r-sm); border: 1px solid var(--gray-200);
    }
    .info-chip { font-size: 12px; color: var(--text); }
    .info-chip .lbl { font-size: 10px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; margin-right: 4px; }

    /* ── Amount summary bar ── */
    .amt-bar { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
    .amt-card { flex: 1; min-width: 100px; text-align: center; padding: 10px 12px; border-radius: var(--r-md); background: var(--gray-50); border: 1px solid var(--gray-200); }
    .amt-card .ac-lbl { font-size: 10px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; }
    .amt-card .ac-val { font-size: 1.3em; font-weight: 700; color: var(--green-dk); margin-top: 3px; }
    .amt-card.balance { background: var(--blue-lt); border-color: var(--blue-bd); }
    .amt-card.balance .ac-val { color: var(--blue-dk); }

    /* ── Payment form ── */
    .pay-form { background: var(--blue-lt); border: 1px solid var(--blue-bd); border-radius: var(--r-md); padding: 12px 16px; margin-bottom: 14px; }
    .pay-row { display: flex; flex-wrap: wrap; gap: 8px 16px; align-items: flex-end; }
    .pay-field { display: flex; flex-direction: column; gap: 3px; }
    .pay-field label { font-size: 11px; font-weight: 600; color: var(--gray-800); }
    .pay-field select, .pay-field input[type=text] {
        padding: 5px 8px; border: 1px solid var(--gray-400); border-radius: var(--r-sm);
        font-size: 12px; font-family: inherit; outline: none;
        transition: border-color 0.15s, box-shadow 0.15s;
    }
    .pay-field select:focus, .pay-field input:focus {
        border-color: var(--blue-md); box-shadow: 0 0 0 2px rgba(25,118,210,0.15);
    }
    .pay-btns { display: flex; gap: 6px; align-items: flex-end; padding-bottom: 1px; }

    /* ── Status pills ── */
    .ws-pill { display: inline-block; padding: 2px 8px; border-radius: 8px; font-size: 10px; font-weight: 700; white-space: nowrap; }
    .ws-Completed { background: #e8f5e9; color: #1b5e20; }
    .ws-Pending   { background: #fff8e1; color: #e65100; }
    .ws-Reject    { background: #fdecea; color: #b71c1c; }

    /* ── Select button (in table) ── */
    .btn-select { background: var(--green-md); color: #fff; border: none; padding: 3px 10px; cursor: pointer; border-radius: var(--r-sm); font-size: 11px; font-family: inherit; font-weight: 600; transition: background 0.15s; }
    .btn-select:hover { background: var(--green-dk); }

    /* ── History table ── */
    .hist-section { margin-top: 4px; }
    .hist-section h4 { font-size: 12px; font-weight: 700; color: var(--green-dk); margin: 0 0 6px; }
    .dataTables_wrapper { width: 100%; }
</style>
</head>
<body>
<script type="text/javascript">
    var salaryTransactions = {};

    /* ── Toggle selection panel open/closed ── */
    function toggleSelectPanel() {
        var body = document.getElementById('panelSelectBody');
        var chev = document.getElementById('selChevron');
        if (body.style.display === 'none') {
            body.style.display = '';
            chev.classList.add('open');
        } else {
            body.style.display = 'none';
            chev.classList.remove('open');
        }
    }

    /* Always open (used by "Change Assignment" button) */
    function openSelectPanel() {
        var body = document.getElementById('panelSelectBody');
        var chev = document.getElementById('selChevron');
        body.style.display = '';
        chev.classList.add('open');
        body.scrollIntoView({behavior: 'smooth'});
    }

    /* ── Row selection: navigate to same page with the chosen assignment ── */
    function processSalary(id) {
        window.location.href = '02employeePaymentProcess.jsp?assignResourceId=' + id;
    }

    /* ── Filter / AJAX table ── */
    function clearAllFilters() {
        document.getElementById('txtDate').value      = '';
        document.getElementById('txtName').value      = '';
        document.getElementById('work_status').value  = '-1';
        document.getElementById('selWorkId').value    = '-1';
        showAllEmployeeByFilterId();
    }

    function showAllEmployeeByFilterId() {
        var fromDate   = document.getElementById('txtDate').value;
        var empName    = document.getElementById('txtName').value;
        var wstatus    = document.getElementById('work_status').value;
        var wid        = document.getElementById('selWorkId').value;
        var xmlhttp    = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var tbl = $('#showTable table.tbl-data');
                if (tbl.length && $.fn.DataTable.isDataTable(tbl)) { tbl.DataTable().destroy(); }
                document.getElementById('showTable').innerHTML = xmlhttp.responseText;
                initSelTable();
            }
        };
        xmlhttp.open('GET', '001ViewEmployeeForPaymentProcessAjax.jsp'
            + '?fromDate='    + encodeURIComponent(fromDate)
            + '&empName='     + encodeURIComponent(empName)
            + '&work_status=' + encodeURIComponent(wstatus)
            + '&work_Id='     + encodeURIComponent(wid), true);
        xmlhttp.send();
    }

    function initSelTable() {
        var tbl = $('#showTable table.tbl-data');
        if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
            tbl.DataTable({
                pageLength: 10,
                lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
                columnDefs: [{ orderable: false, targets: [0, 8] }],
                dom: '<"dt-toolbar"lf>t<"dt-footer"ip>'
            });
        }
    }

    /* ── Payment form ── */
    function validateForm() {
        if (!document.getElementById('paymentType').value) {
            alert('Select Payment Type'); return false;
        }
        return true;
    }

    function editTransaction(id) {
        var d = salaryTransactions[id];
        if (!d) return;
        document.getElementById('paymentType').value = d.paymentType;
        document.getElementById('amount').value      = d.amount;
        document.getElementById('payDate').value     = d.date;
        document.getElementById('bankName').value    = d.bankName;
        document.getElementById('accountNO').value   = d.accountNo;
        document.getElementById('comment').value     = d.comment;
        document.getElementById('salaryProcessId').value = id;
        document.getElementById('sbtUpdateAmount').removeAttribute('hidden');
        document.getElementById('sbtPayAmount').setAttribute('hidden', 'true');
        document.getElementById('payFormPanel').scrollIntoView({behavior: 'smooth'});
    }

    function resetPayForm() {
        document.getElementById('paymentType').value = '';
        document.getElementById('amount').value      = '';
        document.getElementById('payDate').value     = '';
        document.getElementById('bankName').value    = '<%=safeBankName%>';
        document.getElementById('accountNO').value   = '<%=safeAccountNo%>';
        document.getElementById('comment').value     = '';
        document.getElementById('salaryProcessId').value = '';
        document.getElementById('sbtUpdateAmount').setAttribute('hidden', 'true');
        document.getElementById('sbtPayAmount').removeAttribute('hidden');
    }

    $(document).ready(function() {
        $('#txtDate').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
        $('#payDate').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
        showAllEmployeeByFilterId();
    });
</script>
<fieldset><legend><%= msg.getString("payment.fieldset_title") %></legend>

    <!-- ══ Panel 1: Select Assignment ══ -->
    <div class="cpanel">
        <div class="cpanel-head clickable" onclick="toggleSelectPanel()">
            <h3>Select Assignment
                <% if (hasSelection) { %>
                <span class="cpanel-sub">&#8212; <%=empName%> &bull; <%=workDate%> &bull; <%=siteName%></span>
                <% } %>
            </h3>
            <span class="cpanel-chevron <%=hasSelection ? "" : "open"%>" id="selChevron">&#9660;</span>
        </div>
        <div id="panelSelectBody" class="cpanel-body" style="<%=hasSelection ? "display:none;" : ""%>">

            <div class="filter-bar">
                <div class="filter-field">
                    <label><%= msg.getString("payment.filter_label_date") %></label>
                    <input type="text" id="txtDate" placeholder="dd/mm/yyyy"
                           onchange="showAllEmployeeByFilterId()">
                </div>
                <div class="filter-field">
                    <label><%= msg.getString("payment.filter_label_name") %></label>
                    <input type="text" id="txtName" oninput="showAllEmployeeByFilterId()">
                </div>
                <div class="filter-field">
                    <label><%= msg.getString("payment.filter_label_work") %></label>
                    <select id="selWorkId" onchange="showAllEmployeeByFilterId()">
                        <option value="-1">All</option>
                        <%
                            try {
                                ConfigFarmTaskService taskSvc = new ConfigFarmTaskService();
                                List<ConfigFarmTaskEntity> taskList = taskSvc.fetch();
                                for (ConfigFarmTaskEntity task : taskList) {
                        %>
                        <option value="<%=task.getTaskId()%>"><%=task.getTaskName()%></option>
                        <%      }
                            } catch (Exception ex) { ex.printStackTrace(); }
                        %>
                    </select>
                </div>
                <div class="filter-field">
                    <label><%= msg.getString("payment.filter_label_status") %></label>
                    <select id="work_status" onchange="showAllEmployeeByFilterId()">
                        <option value="-1">All</option>
                        <option value="Completed">Completed</option>
                        <option value="Pending">Pending</option>
                        <option value="Reject">Reject</option>
                    </select>
                </div>
                <div class="filter-field" style="justify-content:flex-end;">
                    <button type="button" class="btn-cancel" onclick="clearAllFilters()"><%= msg.getString("btn.clear") %></button>
                </div>
            </div>

            <div id="showTable"></div>
        </div>
    </div>

    <!-- ══ Panel 2: Process Payment (only when assignment is selected) ══ -->
    <% if (hasSelection) { %>
    <div class="cpanel">
        <div class="cpanel-head" style="cursor:default;">
            <h3><%= msg.getString("payment.fieldset_title") %></h3>
            <button type="button" class="btn-cancel" onclick="openSelectPanel()">&#8645; Change Assignment</button>
        </div>
        <div class="cpanel-body">

            <!-- Assignment summary strip -->
            <div class="info-strip">
                <span class="info-chip"><span class="lbl"><%= msg.getString("payment.info_label_employee") %></span><%=empName%></span>
                <span class="info-chip"><span class="lbl"><%= msg.getString("tbl.col_date") %></span><%=workDate%></span>
                <span class="info-chip"><span class="lbl"><%= msg.getString("tbl.col_site") %></span><%=siteName%></span>
                <span class="info-chip"><span class="lbl"><%= msg.getString("payment.info_label_work_type") %></span><%=workType%></span>
                <% if (!workStatus.isEmpty()) { %>
                <span class="info-chip"><span class="lbl"><%= msg.getString("tbl.col_status") %></span>
                    <span class="ws-pill ws-<%=workStatus%>"><%=workStatus%></span>
                </span>
                <% } %>
            </div>

            <!-- Amount summary -->
            <div class="amt-bar">
                <div class="amt-card">
                    <div class="ac-lbl"><%= msg.getString("payment.amt_to_pay") %></div>
                    <div class="ac-val"><%=amountToPay%></div>
                </div>
                <div class="amt-card">
                    <div class="ac-lbl"><%= msg.getString("payment.amt_adv_paid") %></div>
                    <div class="ac-val"><%=advPayment%></div>
                </div>
                <div class="amt-card">
                    <div class="ac-lbl"><%= msg.getString("payment.amt_salary_paid") %></div>
                    <div class="ac-val"><%=ttlPaid%></div>
                </div>
                <div class="amt-card balance">
                    <div class="ac-lbl"><%= msg.getString("payment.amt_balance_due") %></div>
                    <div class="ac-val"><%=balance%></div>
                </div>
            </div>

            <!-- Payment entry form -->
            <div class="pay-form" id="payFormPanel">
                <form onsubmit="return validateForm();">
                    <input type="hidden" name="assignResourceId" value="<%=assignResourceId%>">
                    <input type="hidden" name="salaryProcessId"  id="salaryProcessId">
                    <div class="pay-row">
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_payment_type") %></label>
                            <select name="paymentType" id="paymentType" required style="width:120px;">
                                <option value="">Select</option>
                                <option value="Cash"><%= msg.getString("payment.form_cash") %></option>
                                <option value="Check"><%= msg.getString("payment.form_check") %></option>
                                <option value="Other"><%= msg.getString("payment.form_other") %></option>
                            </select>
                        </div>
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_amount") %></label>
                            <input type="text" name="txtAmount" id="amount" required
                                   pattern="[0-9]+(\.[0-9]+)?" style="width:100px;">
                        </div>
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_date") %></label>
                            <input type="text" name="txtDate" id="payDate" required
                                   placeholder="dd/mm/yyyy" style="width:110px;"
                                   oninvalid="setCustomValidity('Select Date')"
                                   onchange="setCustomValidity('')">
                        </div>
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_bank_name") %></label>
                            <input type="text" name="bankName" id="bankName"
                                   value="<%=defaultBankName%>" style="width:130px;">
                        </div>
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_account_no") %></label>
                            <input type="text" name="accountNO" id="accountNO"
                                   value="<%=defaultAccountNo%>" style="width:130px;">
                        </div>
                        <div class="pay-field">
                            <label><%= msg.getString("payment.form_label_comment") %></label>
                            <input type="text" name="comment" id="comment"
                                   placeholder="Optional" style="width:140px;">
                        </div>
                        <div class="pay-btns">
                            <input type="submit" class="btn-add" id="sbtPayAmount" name="sbtPayAmount"
                                   value="<%= msg.getString("btn.pay_amount") %>" onclick="this.form.action='../../PaymentProcessingServlet'">
                            <input type="submit" class="btn-update" id="sbtUpdateAmount" name="sbtUpdateAmount"
                                   value="<%= msg.getString("btn.update") %>" hidden onclick="this.form.action='../../PaymentProcessingServlet'">
                            <input type="button" class="btn-cancel" value="<%= msg.getString("btn.reset") %>" onclick="resetPayForm()">
                        </div>
                    </div>
                </form>
            </div>

            <!-- Payment history -->
            <% if (!processingEntities.isEmpty()) { %>
            <div class="hist-section">
                <h4><%= msg.getString("payment.history_title") %></h4>
                <table border="1" cellspacing="0" class="tbl-data" width="100%">
                    <thead>
                        <tr>
                            <th width="4%"><%= msg.getString("tbl.col_number") %></th>
                            <th><%= msg.getString("payment.history_col_type") %></th>
                            <th><%= msg.getString("tbl.col_date") %></th>
                            <th><%= msg.getString("tbl.col_amount") %></th>
                            <th><%= msg.getString("payment.history_col_bank") %></th>
                            <th><%= msg.getString("payment.history_col_account_no") %></th>
                            <th><%= msg.getString("tbl.col_comment") %></th>
                            <th width="10%"><%= msg.getString("tbl.col_actions") %></th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        int hcnt = 0;
                        for (PaymentProcessingEntity pe : processingEntities) {
                            hcnt++;
                            String peDate = (pe.getDate() != null)
                                ? FarmUtility.convertfrom_yymmddToddmmyy(pe.getDate().toString()) : "";
                    %>
                        <tr>
                            <td><%=hcnt%></td>
                            <td><%=pe.getPaymentType()   != null ? pe.getPaymentType()   : ""%></td>
                            <td><%=peDate%></td>
                            <td style="text-align:right; font-weight:600;"><%=pe.getAmount()%></td>
                            <td><%=pe.getBankName()      != null ? pe.getBankName()      : ""%></td>
                            <td><%=pe.getAccountNumber() != null ? pe.getAccountNumber() : ""%></td>
                            <td><%=pe.getComment()       != null ? pe.getComment()       : ""%></td>
                            <td style="text-align:center; white-space:nowrap;">
                                <button type="button" class="btn-row-edit"
                                    onclick="editTransaction(<%=pe.getSalaryProcessId()%>)"><%= msg.getString("btn.edit") %></button>
                                <form method="post" action="../../PaymentProcessingServlet" style="display:inline;"
                                      onsubmit="return confirm('Delete this payment record?');">
                                    <input type="hidden" name="salaryProcessId"  value="<%=pe.getSalaryProcessId()%>">
                                    <input type="hidden" name="assignResourceId" value="<%=assignResourceId%>">
                                    <input type="submit"  class="btn-row-del"    name="sbtDelete" value="<%= msg.getString("btn.delete") %>">
                                </form>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
            <% } %>

        </div>
    </div>
    <% } %>

</fieldset>

<!-- Transaction data for JS edit population -->
<script>
<%
    for (PaymentProcessingEntity pe : processingEntities) {
        String peDate = (pe.getDate() != null) ? FarmUtility.convertfrom_yymmddToddmmyy(pe.getDate().toString()) : "";
%>
salaryTransactions[<%=pe.getSalaryProcessId()%>] = {
    amount:      <%=pe.getAmount()%>,
    date:        '<%=peDate%>',
    paymentType: '<%=pe.getPaymentType()     != null ? pe.getPaymentType().replace("'","\\'")     : ""%>',
    bankName:    '<%=pe.getBankName()        != null ? pe.getBankName().replace("'","\\'")        : ""%>',
    accountNo:   '<%=pe.getAccountNumber()   != null ? pe.getAccountNumber().replace("'","\\'")   : ""%>',
    comment:     '<%=pe.getComment()         != null ? pe.getComment().replace("'","\\'")         : ""%>'
};
<% } %>
</script>

<%@include file="../../footer.jsp" %>
</body>
</html>
