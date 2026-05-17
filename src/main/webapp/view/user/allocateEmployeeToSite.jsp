<%@page import="com.san.farm.adminuser.entity.*"%>
<%@page import="com.san.farm.adminuser.dao.*"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    /* ── cropToSiteId ── */
    int cropToSiteId = 0;
    try {
        String ctSid = request.getParameter("cropToSiteId");
        if (ctSid != null && !ctSid.trim().isEmpty()) cropToSiteId = Integer.parseInt(ctSid.trim());
    } catch (Exception ignore) {}

    /* ── site info ── */
    AssignCropToSiteService cropSvc = new AssignCropToSiteService();
    AssignCropToSiteEntity cropToSite = cropSvc.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);

    /* ── dropdown data ── */
    EmployeeInfoService empSvc = new EmployeeInfoService();
    ConfigFarmTaskService taskSvc = new ConfigFarmTaskService();
    List<EmployeeInfoEntity> employees = empSvc.getListOfEmployee();
    List<ConfigFarmTaskEntity> tasks = taskSvc.fetch();

    /* ── existing allocations ── */
    AssignResourceEmployeeToFarmService allocSvc = new AssignResourceEmployeeToFarmService();
    List<AssignEmployeeToFarmEntity> allocations = allocSvc.getByCropToSiteId(cropToSiteId);

    /* ── site display info ── */
    String siteName = (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                    ? cropToSite.getSiteInformationEntity().getSiteName() : "Unknown Site";
    String siteDate = (cropToSite != null && cropToSite.getCropAssignDate() != null)
                    ? FarmUtility.convertfrom_yymmddToddmmyy(cropToSite.getCropAssignDate().toString()) : "";

    /* ── crops string ── */
    String cropNamesStr = "";
    if (cropToSite != null && cropToSite.getCropToSiteRefEntity() != null) {
        StringBuilder sb = new StringBuilder();
        for (AssignCropToSiteRefEntity ref : cropToSite.getCropToSiteRefEntity()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(ref.getConfigCropEntity().getCropName());
        }
        cropNamesStr = sb.toString();
    }

    /* ── totals ── */
    double totalAmount = 0, totalAdv = 0;
    for (AssignEmployeeToFarmEntity a : allocations) {
        totalAmount += a.getAmount();
        totalAdv    += a.getAdvPayment();
    }

    /* ── physical siteInfoId + all site allocations (for duplicate validation) ── */
    int siteInfoId = (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                   ? cropToSite.getSiteInformationEntity().getSiteInfoId() : 0;
    List<AssignEmployeeToFarmEntity> siteAllocations = siteInfoId > 0
                   ? allocSvc.getListBySiteInfoId(siteInfoId) : allocations;

    /* ── today's date ── */
    String todayStr = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title><%= msg.getString("emp_alloc.page_title") %> — <%=siteName%></title>
<style>
    .site-banner { background:#e8f5e9; border:1px solid var(--green-bd); border-radius:var(--r-md);
                   padding:8px 16px; margin-bottom:12px; display:flex; align-items:center; gap:18px; flex-wrap:wrap; }
    .site-banner .sb-label { font-size:0.78em; color:var(--text-muted); text-transform:uppercase; }
    .site-banner .sb-val   { font-weight:700; color:var(--green-dk); }
    .stats-bar  { display:flex; gap:12px; flex-wrap:wrap; margin-bottom:12px; }
    .stat-card  { background:#fff; border:1px solid var(--gray-200); border-radius:var(--r-md);
                  padding:8px 18px; min-width:130px; text-align:center; }
    .stat-card .sc-val   { font-size:1.25em; font-weight:700; color:var(--green-dk); }
    .stat-card .sc-label { font-size:0.72em; color:var(--text-muted); text-transform:uppercase; margin-top:2px; }
    .stat-card.highlight { background:#e8f5e9; border-color:var(--green-bd); }
    .section-title { font-weight:700; color:var(--green-dk); font-size:0.95em;
                     border-bottom:2px solid var(--green-bd); padding-bottom:4px;
                     margin:14px 0 8px; display:flex; align-items:center; gap:10px; }
    .back-link  { font-size:12px; color:var(--green-dk); text-decoration:none; }
    .back-link:hover { text-decoration:underline; }
    .btn-add-row { background:#fff; border:1px solid var(--green-dk); color:var(--green-dk);
                   padding:2px 10px; cursor:pointer; border-radius:var(--r-sm);
                   font-size:12px; font-weight:700; }
    .btn-add-row:hover { background:#e8f5e9; }
    .btn-save-all { background:var(--green-dk); color:#fff; border:none; padding:5px 20px;
                    cursor:pointer; border-radius:var(--r-sm); font-size:13px; font-weight:700; }
    .btn-save-all:hover { background:#2e7d32; }
    .btn-remove-row { color:#c62828; border:none; background:none; font-size:16px;
                      cursor:pointer; line-height:1; padding:0 4px; }
    .inp-sm  { font-size:12px; padding:3px 4px; }
    .sel-emp { width:140px; }
    .sel-typework { width:120px; }
    .sel-status { width:100px; }
    .inp-num  { width:70px; text-align:right; }
    .inp-date { width:90px; }
    .inp-rem  { width:110px; }
    .status-Pending   { color:#e65100; font-weight:600; }
    .status-Completed { color:#2e7d32; font-weight:600; }
    .status-Rejected  { color:#c62828; font-weight:600; }
    .btn-row-edit   { background:#e8f5e9; border:1px solid var(--green-dk); color:var(--green-dk);
                      padding:2px 8px; cursor:pointer; border-radius:2px; font-size:11px; font-weight:600; }
    .btn-row-edit:hover { background:#c8e6c9; }
    .btn-row-save   { background:#28a745; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; margin-left:2px; }
    .btn-row-cancel { background:#6c757d; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; margin-left:2px; }

    /* ── Checkbox dropdown ── */
    .chk-drop        { position:relative; display:inline-block; }
    .chk-drop-btn    { background:#fff; border:1px solid var(--gray-400); border-radius:var(--r-sm);
                       padding:3px 22px 3px 6px; font-size:11px; cursor:pointer; text-align:left;
                       min-width:130px; max-width:160px; position:relative; white-space:nowrap;
                       overflow:hidden; text-overflow:ellipsis; font-family:inherit; color:#333; }
    .chk-drop-btn::after { content:'\25BE'; position:absolute; right:6px; top:50%;
                            transform:translateY(-50%); color:#888; pointer-events:none; }
    .chk-drop-btn.has-val { border-color:var(--green-bd); background:var(--green-lt);
                             color:var(--green-dk); font-weight:600; }
    .chk-drop-panel  { position:absolute; top:calc(100% + 2px); left:0; z-index:1000; background:#fff;
                       border:1px solid var(--gray-400); border-radius:var(--r-sm);
                       box-shadow:0 4px 12px rgba(0,0,0,.15); min-width:170px; max-height:190px;
                       overflow-y:auto; padding:4px 0; }
    .chk-drop-item   { display:flex; align-items:center; gap:7px; padding:4px 10px;
                       font-size:11px; cursor:pointer; user-select:none; }
    .chk-drop-item:hover { background:var(--green-lt); }
    .chk-drop-item input { margin:0; cursor:pointer; accent-color:var(--green-md); }
</style>
</head>
<body>
<%@include file="../../header.jsp" %>
<script src="../../js/jquery-ui.js"></script>
<script>
/* ─── Employee options HTML ─── */
var empOptions = '<option value=""><%= msg.getString("emp_alloc.select_employee") %></option>';
<%
    for (EmployeeInfoEntity e : employees) {
        String fn = e.getFirstName()  != null ? e.getFirstName().trim()  : "";
        String mn = e.getMiddleName() != null && !e.getMiddleName().trim().isEmpty()
                    ? " " + e.getMiddleName().trim() : "";
        String ln = e.getLastName()   != null ? " " + e.getLastName().trim() : "";
        String fullName = (fn + mn + ln).replace("'", "\\'").replace("\"", "&quot;");
%>
empOptions += '<option value="<%=e.getEmployeeInfoId()%>"><%=fullName%></option>';
<% } %>

/* ─── Task checkbox items HTML (for new rows) ─── */
var taskChkItems = '';
<%
    for (ConfigFarmTaskEntity t : tasks) {
        String tName = t.getTaskName() != null ? t.getTaskName().replace("'", "\\'").replace("\"", "&quot;") : "";
%>
taskChkItems += '<label class="chk-drop-item"><input type="checkbox" class="task-chk" value="<%=t.getTaskId()%>" onchange="updateNewRowDropBtn(this)"><%=tName%></label>';
<% } %>

/* ─── Task name lookup map ─── */
var taskNameMap = {};
<% for (ConfigFarmTaskEntity t : tasks) {
    String tName = t.getTaskName() != null ? t.getTaskName().replace("'", "\\'") : "";
%>
taskNameMap['<%=t.getTaskId()%>'] = '<%=tName%>';
<% } %>

/* ─── Site-wide allocations for duplicate checking ─── */
var existingAllocs = [
<%
    for (AssignEmployeeToFarmEntity xa : siteAllocations) {
        int xEmpId = xa.getEmployeeInfoEntity() != null ? xa.getEmployeeInfoEntity().getEmployeeInfoId() : 0;
        if (xEmpId == 0) continue;
        String xDate = xa.getAssignWorkDate() != null
                     ? FarmUtility.convertfrom_yymmddToddmmyy(xa.getAssignWorkDate().toString()) : "";
        if (xa.getListFarmTaskEntities().isEmpty()) {
%>
    {empId:'<%=xEmpId%>', date:'<%=xDate%>', taskId:'0'},
<%
        } else {
            for (ConfigFarmTaskEntity xt : xa.getListFarmTaskEntities()) {
%>
    {empId:'<%=xEmpId%>', date:'<%=xDate%>', taskId:'<%=xt.getTaskId()%>'},
<%
            }
        }
    }
%>
];

var todayDate   = '<%=todayStr%>';
var dropCounter = 0;

$(function() {
    $(".date-inp").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });

    /* close all dropdowns when clicking outside */
    $(document).on('click', function(e) {
        if (!$(e.target).closest('.chk-drop').length) {
            $('.chk-drop-panel').hide();
        }
    });
});

/* ── Checkbox dropdown helpers ── */
function toggleDrop(panelId, btnId, event) {
    if (event) event.stopPropagation();
    var $panel = $('#' + panelId);
    $('.chk-drop-panel').not($panel).hide();
    $panel.toggle();
}

/* updates button label for new-row task dropdowns */
function updateNewRowDropBtn(chkEl) {
    var $drop    = $(chkEl).closest('.task-drop');
    var $btn     = $drop.find('.chk-drop-btn');
    var $checked = $drop.find('.task-chk:checked');
    if ($checked.length === 0) {
        $btn.text('Select tasks...').removeClass('has-val');
    } else if ($checked.length === 1) {
        $btn.text($checked.first().closest('.chk-drop-item').text().trim()).addClass('has-val');
    } else {
        $btn.text($checked.length + ' tasks selected').addClass('has-val');
    }
}

/* updates button label for edit-row task dropdowns */
function updateEditRowDropBtn(rid) {
    var $panel   = $('#editTaskPanel_' + rid);
    var $btn     = $('#editTaskBtn_' + rid);
    var $checked = $panel.find('.edit-task-chk:checked');
    if ($checked.length === 0) {
        $btn.text('Select tasks...').removeClass('has-val');
    } else if ($checked.length === 1) {
        $btn.text($checked.first().closest('.chk-drop-item').text().trim()).addClass('has-val');
    } else {
        $btn.text($checked.length + ' tasks selected').addClass('has-val');
    }
}

/* builds task checkbox dropdown HTML for a new dynamically-added row */
function buildTaskDropHtml() {
    dropCounter++;
    var btnId   = 'tDropBtn_' + dropCounter;
    var panelId = 'tDropPanel_' + dropCounter;
    return '<div class="chk-drop task-drop">' +
               '<button type="button" class="chk-drop-btn" id="' + btnId + '" ' +
                   'onclick="toggleDrop(\'' + panelId + '\',\'' + btnId + '\',event)">' +
                   'Select tasks...</button>' +
               '<div class="chk-drop-panel" id="' + panelId + '" style="display:none;">' +
                   taskChkItems +
               '</div>' +
           '</div>' +
           '<input type="hidden" name="taskIdsCsv" class="task-csv">';
}

/* ── Validate & collect CSV before new-row form submit ── */
function validateBeforeSubmit() {
    /* populate hidden taskIdsCsv from each row's checkbox dropdown */
    $('#empTableBody tr').each(function() {
        var selected = [];
        $(this).find('.task-drop .task-chk:checked').each(function() {
            if (this.value) selected.push(this.value);
        });
        $(this).find('.task-csv').val(selected.join(','));
    });

    var rows  = $('#empTableBody tr');
    var seen  = {};
    var valid = true, msg = '';

    rows.each(function(idx) {
        if (!valid) return false;

        var empSel  = $(this).find('select[name="empId"]');
        var dateInp = $(this).find('input[name="workDate"]');

        var empId = empSel.val() || '';
        var date  = $.trim(dateInp.val());
        if (!empId) return;

        var empName  = empSel.find('option:selected').text();
        var selTasks = [];
        $(this).find('.task-drop .task-chk:checked').each(function() {
            if (this.value) selTasks.push(this.value);
        });

        for (var t = 0; t < selTasks.length; t++) {
            var tid = selTasks[t];
            var key = empId + '|' + date + '|' + tid;

            if (seen.hasOwnProperty(key)) {
                msg = 'Row ' + (idx + 1) + ' duplicates row ' + seen[key] + ':\n'
                    + '"' + empName + '" — ' + (date || 'no date') + ' — task "' + (taskNameMap[tid] || tid) + '".\n'
                    + 'Remove or change the duplicate row.';
                valid = false; return false;
            }

            for (var i = 0; i < existingAllocs.length; i++) {
                var ex = existingAllocs[i];
                if (ex.empId === empId && ex.date === date && ex.taskId === tid) {
                    msg = '"' + empName + '" on ' + (date || 'no date') + ' is already assigned task "'
                        + (taskNameMap[tid] || tid) + '" at site "<%=siteName%>".\nChange the employee, date or task.';
                    valid = false; return false;
                }
            }

            seen[key] = idx + 1;
        }
    });

    if (!valid) { alert('Duplicate Entry Detected:\n\n' + msg); return false; }
    return true;
}

/* ── Add new row ── */
function addRow() {
    var tr = $('<tr>');
    tr.html(
        '<td><select name="empId" class="inp-sm sel-emp">'      + empOptions + '</select></td>' +
        '<td><input type="text" name="workDate" class="inp-sm inp-date date-inp-dyn" value="' + todayDate + '" placeholder="dd/mm/yyyy" readonly></td>' +
        '<td>' + buildTaskDropHtml() + '</td>' +
        '<td><select name="typeOfWork" class="inp-sm sel-typework">' +
            '<option value="Contract"><%= msg.getString("emp_alloc.work_type_contract") %></option>' +
            '<option value="Per Day Payment"><%= msg.getString("emp_alloc.work_type_per_day") %></option>' +
        '</select></td>' +
        '<td><input type="number" name="amount"     class="inp-sm inp-num" value="0" step="0.01" min="0"></td>' +
        '<td><input type="number" name="advPayment" class="inp-sm inp-num" value="0" step="0.01" min="0"></td>' +
        '<td><select name="workStatus" class="inp-sm sel-status">' +
            '<option value="Pending"><%= msg.getString("emp_alloc.status_pending") %></option>' +
            '<option value="Completed"><%= msg.getString("emp_alloc.status_completed") %></option>' +
            '<option value="Rejected"><%= msg.getString("emp_alloc.status_rejected") %></option>' +
        '</select></td>' +
        '<td><input type="text" name="remark" class="inp-sm inp-rem"></td>' +
        '<td style="text-align:center;"><button type="button" class="btn-remove-row" onclick="removeRow(this)">&#10005;</button></td>'
    );
    $('#empTableBody').append(tr);
    tr.find('.date-inp-dyn').datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
}

function removeRow(btn) {
    if (document.getElementById('empTableBody').rows.length <= 1) {
        alert('<%= msg.getString("emp_alloc.validation_min_row") %>'); return;
    }
    $(btn).closest('tr').remove();
}

/* ── Inline edit for Already-Assigned rows ── */
var ALLOC_FIELDS = ['Date','Emp','Tasks','TypeOfWork','Amount','AdvPay','Status','Remark'];

function editAllocRow(id) {
    ALLOC_FIELDS.forEach(function(f) {
        var sp  = document.getElementById('view' + f + '_' + id);
        var inp = document.getElementById('edit' + f + '_' + id);
        if (sp)  sp.style.display = 'none';
        if (inp) inp.style.display = '';
    });
    $('#editDate_' + id).datepicker({ changeMonth:true, changeYear:true, dateFormat:'dd/mm/yy' });
    document.getElementById('btnEdit_'   + id).style.display = 'none';
    document.getElementById('btnRemove_' + id).style.display = 'none';
    document.getElementById('btnSave_'   + id).style.display = '';
    document.getElementById('btnCancel_' + id).style.display = '';
}

function cancelAllocRow(id) {
    ALLOC_FIELDS.forEach(function(f) {
        var sp  = document.getElementById('view' + f + '_' + id);
        var inp = document.getElementById('edit' + f + '_' + id);
        if (sp)  sp.style.display = '';
        if (inp) inp.style.display = 'none';
    });
    /* close task dropdown panel if open */
    $('#editTaskPanel_' + id).hide();
    document.getElementById('btnEdit_'   + id).style.display = '';
    document.getElementById('btnRemove_' + id).style.display = '';
    document.getElementById('btnSave_'   + id).style.display = 'none';
    document.getElementById('btnCancel_' + id).style.display = 'none';
}

function saveAllocRow(id) {
    /* collect checked task IDs from the edit-row dropdown panel */
    var tids = [];
    $('#editTaskPanel_' + id + ' .edit-task-chk:checked').each(function() {
        if (this.value) tids.push(this.value);
    });
    document.getElementById('hidTasksCsv_'    + id).value = tids.join(',');
    document.getElementById('hidEmp_'         + id).value = document.getElementById('editEmp_'        + id).value;
    document.getElementById('hidDate_'        + id).value = document.getElementById('editDate_'       + id).value;
    document.getElementById('hidTypeOfWork_'  + id).value = document.getElementById('editTypeOfWork_' + id).value;
    document.getElementById('hidAmount_'      + id).value = document.getElementById('editAmount_'     + id).value;
    document.getElementById('hidAdvPay_'      + id).value = document.getElementById('editAdvPay_'     + id).value;
    document.getElementById('hidStatus_'      + id).value = document.getElementById('editStatus_'     + id).value;
    document.getElementById('hidRemark_'      + id).value = document.getElementById('editRemark_'     + id).value;
    document.getElementById('frmUpdate_'      + id).submit();
}
</script>

<fieldset>
<legend><%= msg.getString("emp_alloc.fieldset_title") %></legend>

<a class="back-link" href="assignCropToSite.jsp">&#8592; <%= msg.getString("btn.back") %></a>

<!-- Site banner -->
<div class="site-banner" style="margin-top:8px;">
    <div><div class="sb-label"><%= msg.getString("site_alloc.tbl_col_site") %></div><div class="sb-val"><%=siteName%></div></div>
    <% if (!siteDate.isEmpty()) { %>
    <div><div class="sb-label"><%= msg.getString("site_alloc.tbl_col_date") %></div><div class="sb-val"><%=siteDate%></div></div>
    <% } %>
    <% if (!cropNamesStr.isEmpty()) { %>
    <div><div class="sb-label"><%= msg.getString("site_alloc.tbl_col_crop") %></div><div class="sb-val"><%=cropNamesStr%></div></div>
    <% } %>
</div>

<!-- Stats bar -->
<div class="stats-bar">
    <div class="stat-card highlight">
        <div class="sc-val"><%=allocations.size()%></div>
        <div class="sc-label"><%= msg.getString("dashboard.kpi_work_orders") %></div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val">&#8377; <%=String.format("%.2f", totalAmount)%></div>
        <div class="sc-label"><%= msg.getString("tbl.col_total_amount") %></div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val">&#8377; <%=String.format("%.2f", totalAdv)%></div>
        <div class="sc-label"><%= msg.getString("payment.amt_adv_paid") %></div>
    </div>
</div>

<!-- ── New assignment form ── -->
<form method="post" action="<%=request.getContextPath()%>/AllocateEmployeeController"
      onsubmit="return validateBeforeSubmit()">
    <input type="hidden" name="action"       value="save">
    <input type="hidden" name="cropToSiteId" value="<%=cropToSiteId%>">

    <div class="section-title">
        <%= msg.getString("emp_alloc.section_new_assignment") %>
        <button type="button" class="btn-add-row" onclick="addRow()">+ <%= msg.getString("btn.add") %></button>
    </div>

    <div style="overflow-x:auto;">
    <table class="tbl-data" cellspacing="0">
        <thead>
        <tr>
            <th><%= msg.getString("emp_alloc.tbl_col_employee") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_date") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_task") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_type_of_work") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_amount_rs") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_advance_rs") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_work_status") %></th>
            <th><%= msg.getString("emp_alloc.tbl_col_remark") %></th>
            <th></th>
        </tr>
        </thead>
        <tbody id="empTableBody">
        <tr>
            <td>
                <select name="empId" class="inp-sm sel-emp">
                    <option value=""><%= msg.getString("emp_alloc.select_employee") %></option>
                    <% for (EmployeeInfoEntity e : employees) {
                        String fn = e.getFirstName()  != null ? e.getFirstName().trim()  : "";
                        String mn = e.getMiddleName() != null && !e.getMiddleName().trim().isEmpty()
                                    ? " " + e.getMiddleName().trim() : "";
                        String ln = e.getLastName()   != null ? " " + e.getLastName().trim() : "";
                    %>
                    <option value="<%=e.getEmployeeInfoId()%>"><%=fn + mn + ln%></option>
                    <% } %>
                </select>
            </td>
            <td>
                <input type="text" name="workDate" class="inp-sm inp-date date-inp"
                       value="<%=todayStr%>" placeholder="dd/mm/yyyy" readonly>
            </td>
            <td>
                <!-- static first row uses counter 0 -->
                <div class="chk-drop task-drop">
                    <button type="button" class="chk-drop-btn" id="tDropBtn_0"
                        onclick="toggleDrop('tDropPanel_0','tDropBtn_0',event)">Select tasks...</button>
                    <div class="chk-drop-panel" id="tDropPanel_0" style="display:none;">
                        <% for (ConfigFarmTaskEntity t : tasks) { %>
                        <label class="chk-drop-item">
                            <input type="checkbox" class="task-chk" value="<%=t.getTaskId()%>"
                                onchange="updateNewRowDropBtn(this)">
                            <%=t.getTaskName()%>
                        </label>
                        <% } %>
                    </div>
                </div>
                <input type="hidden" name="taskIdsCsv" class="task-csv">
            </td>
            <td>
                <select name="typeOfWork" class="inp-sm sel-typework">
                    <option value="Contract"><%= msg.getString("emp_alloc.work_type_contract") %></option>
                    <option value="Per Day Payment"><%= msg.getString("emp_alloc.work_type_per_day") %></option>
                </select>
            </td>
            <td><input type="number" name="amount"     class="inp-sm inp-num" value="0" step="0.01" min="0"></td>
            <td><input type="number" name="advPayment" class="inp-sm inp-num" value="0" step="0.01" min="0"></td>
            <td>
                <select name="workStatus" class="inp-sm sel-status">
                    <option value="Pending"><%= msg.getString("emp_alloc.status_pending") %></option>
                    <option value="Completed"><%= msg.getString("emp_alloc.status_completed") %></option>
                    <option value="Rejected"><%= msg.getString("emp_alloc.status_rejected") %></option>
                </select>
            </td>
            <td><input type="text" name="remark" class="inp-sm inp-rem"></td>
            <td style="text-align:center;">
                <button type="button" class="btn-remove-row" onclick="removeRow(this)">&#10005;</button>
            </td>
        </tr>
        </tbody>
    </table>
    </div>

    <div style="margin:10px 0;">
        <button type="submit" class="btn-save-all"><%= msg.getString("btn.save_all") %></button>
    </div>
</form>

<!-- ── Already assigned ── -->
<div class="section-title" style="margin-top:18px;">
    <%= msg.getString("emp_alloc.section_already_assigned") %>
    <span style="font-size:0.8em; font-weight:normal; color:var(--text-muted);">(<%=allocations.size()%> record(s))</span>
</div>

<% if (allocations.isEmpty()) { %>
<p style="color:var(--text-muted); font-size:13px;"><%= msg.getString("emp_alloc.no_employees_assigned") %></p>
<% } else { %>
<div style="overflow-x:auto;">
<table class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th><%= msg.getString("emp_alloc.tbl_col_date") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_employee") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_task") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_type_of_work") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_amount_rs") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_advance_rs") %></th>
        <th><%= msg.getString("tbl.col_status") %></th>
        <th><%= msg.getString("emp_alloc.tbl_col_remark") %></th>
        <th><%= msg.getString("tbl.col_actions") %></th>
    </tr>
    </thead>
    <tbody>
    <%
        for (AssignEmployeeToFarmEntity a : allocations) {
            int rid = a.getAssignResourceId();
            EmployeeInfoEntity emp = a.getEmployeeInfoEntity();
            int curEmpId = emp != null ? emp.getEmployeeInfoId() : 0;
            String empFn = emp != null && emp.getFirstName()  != null ? emp.getFirstName().trim()  : "";
            String empMn = emp != null && emp.getMiddleName() != null && !emp.getMiddleName().trim().isEmpty()
                           ? " " + emp.getMiddleName().trim() : "";
            String empLn = emp != null && emp.getLastName()   != null ? " " + emp.getLastName().trim() : "";
            String empName = empFn + empMn + empLn;

            StringBuilder taskNames = new StringBuilder();
            List<ConfigFarmTaskEntity> curTasks = a.getListFarmTaskEntities();
            for (ConfigFarmTaskEntity t : curTasks) {
                if (taskNames.length() > 0) taskNames.append(", ");
                taskNames.append(t.getTaskName());
            }

            String editDropBtnLabel = curTasks.isEmpty() ? "Select tasks..."
                                    : curTasks.size() == 1 ? curTasks.get(0).getTaskName()
                                    : curTasks.size() + " tasks selected";

            String aDate         = a.getAssignWorkDate() != null
                                 ? FarmUtility.convertfrom_yymmddToddmmyy(a.getAssignWorkDate().toString()) : "";
            String statusCls     = "status-" + (a.getWorkStatus() != null ? a.getWorkStatus() : "");
            String comment       = a.getComment()    != null ? a.getComment()    : "";
            String curStatus     = a.getWorkStatus() != null ? a.getWorkStatus() : "Pending";
            String curTypeOfWork = a.getTypeOfWork() != null ? a.getTypeOfWork() : "Contract";
    %>
    <tr id="allocRow_<%=rid%>">
        <!-- Date -->
        <td>
            <span id="viewDate_<%=rid%>"><%=aDate%></span>
            <input type="text" id="editDate_<%=rid%>" class="inp-sm inp-date"
                   value="<%=aDate%>" style="display:none;" readonly placeholder="dd/mm/yyyy">
        </td>
        <!-- Employee -->
        <td>
            <span id="viewEmp_<%=rid%>"><%=empName%></span>
            <select id="editEmp_<%=rid%>" class="inp-sm sel-emp" style="display:none;">
                <% for (EmployeeInfoEntity ev : employees) {
                    String efn = ev.getFirstName()  != null ? ev.getFirstName().trim()  : "";
                    String emn = ev.getMiddleName() != null && !ev.getMiddleName().trim().isEmpty()
                                 ? " " + ev.getMiddleName().trim() : "";
                    String eln = ev.getLastName()   != null ? " " + ev.getLastName().trim() : "";
                    String esel = ev.getEmployeeInfoId() == curEmpId ? "selected" : "";
                %>
                <option value="<%=ev.getEmployeeInfoId()%>" <%=esel%>><%=efn+emn+eln%></option>
                <% } %>
            </select>
        </td>
        <!-- Task(s) — checkbox dropdown; id="editTasks_RID" on wrapper so ALLOC_FIELDS show/hide works -->
        <td>
            <span id="viewTasks_<%=rid%>"><%=taskNames.length() > 0 ? taskNames.toString() : "<span style='color:var(--text-muted)'>&#8212;</span>"%></span>
            <div class="chk-drop" id="editTasks_<%=rid%>" style="display:none;">
                <button type="button" class="chk-drop-btn <%=curTasks.size() > 0 ? "has-val" : ""%>"
                    id="editTaskBtn_<%=rid%>"
                    onclick="toggleDrop('editTaskPanel_<%=rid%>','editTaskBtn_<%=rid%>',event)"><%=editDropBtnLabel%></button>
                <div class="chk-drop-panel" id="editTaskPanel_<%=rid%>" style="display:none;">
                    <% for (ConfigFarmTaskEntity tv : tasks) {
                        boolean isSel = false;
                        for (ConfigFarmTaskEntity ct : curTasks) {
                            if (ct.getTaskId() == tv.getTaskId()) { isSel = true; break; }
                        }
                    %>
                    <label class="chk-drop-item">
                        <input type="checkbox" class="edit-task-chk" value="<%=tv.getTaskId()%>"
                            <%=isSel ? "checked" : ""%>
                            onchange="updateEditRowDropBtn(<%=rid%>)">
                        <%=tv.getTaskName()%>
                    </label>
                    <% } %>
                </div>
            </div>
        </td>
        <!-- Type of Work -->
        <td style="text-align:center;">
            <span id="viewTypeOfWork_<%=rid%>"><%=curTypeOfWork%></span>
            <select id="editTypeOfWork_<%=rid%>" class="inp-sm sel-typework" style="display:none;">
                <option value="Contract"        <%="Contract".equals(curTypeOfWork)        ? "selected" : ""%>><%= msg.getString("emp_alloc.work_type_contract") %></option>
                <option value="Per Day Payment" <%="Per Day Payment".equals(curTypeOfWork) ? "selected" : ""%>><%= msg.getString("emp_alloc.work_type_per_day") %></option>
            </select>
        </td>
        <!-- Amount -->
        <td style="text-align:right;">
            <span id="viewAmount_<%=rid%>"><%=String.format("%.2f", a.getAmount())%></span>
            <input type="number" id="editAmount_<%=rid%>" class="inp-sm inp-num"
                   value="<%=a.getAmount()%>" step="0.01" min="0" style="display:none;">
        </td>
        <!-- Advance -->
        <td style="text-align:right;">
            <span id="viewAdvPay_<%=rid%>"><%=String.format("%.2f", a.getAdvPayment())%></span>
            <input type="number" id="editAdvPay_<%=rid%>" class="inp-sm inp-num"
                   value="<%=a.getAdvPayment()%>" step="0.01" min="0" style="display:none;">
        </td>
        <!-- Status -->
        <td style="text-align:center;">
            <span id="viewStatus_<%=rid%>" class="<%=statusCls%>"><%=curStatus%></span>
            <select id="editStatus_<%=rid%>" class="inp-sm sel-status" style="display:none;">
                <option value="Pending"   <%="Pending".equals(curStatus)   ? "selected" : ""%>><%= msg.getString("emp_alloc.status_pending") %></option>
                <option value="Completed" <%="Completed".equals(curStatus) ? "selected" : ""%>><%= msg.getString("emp_alloc.status_completed") %></option>
                <option value="Rejected"  <%="Rejected".equals(curStatus)  ? "selected" : ""%>><%= msg.getString("emp_alloc.status_rejected") %></option>
            </select>
        </td>
        <!-- Remark -->
        <td>
            <span id="viewRemark_<%=rid%>"><%=comment%></span>
            <input type="text" id="editRemark_<%=rid%>" class="inp-sm inp-rem"
                   value="<%=comment%>" style="display:none;">
        </td>
        <!-- Action -->
        <td style="text-align:center; white-space:nowrap;">
            <button type="button" class="btn-row-edit" id="btnEdit_<%=rid%>"
                    onclick="editAllocRow(<%=rid%>)"><%= msg.getString("btn.edit") %></button>

            <span id="btnRemove_<%=rid%>">
            <form method="post" action="<%=request.getContextPath()%>/AllocateEmployeeController" style="display:inline;">
                <input type="hidden" name="action"           value="delete">
                <input type="hidden" name="assignResourceId" value="<%=rid%>">
                <input type="hidden" name="cropToSiteId"     value="<%=cropToSiteId%>">
                <button type="submit" class="btn-delete"
                    onclick="return (window.top||window).confirm('Remove this assignment?')"><%= msg.getString("btn.remove") %></button>
            </form>
            </span>

            <!-- Hidden update form — populated and submitted by saveAllocRow() -->
            <form id="frmUpdate_<%=rid%>" method="post"
                  action="<%=request.getContextPath()%>/AllocateEmployeeController">
                <input type="hidden" name="action"           value="update">
                <input type="hidden" name="assignResourceId" value="<%=rid%>">
                <input type="hidden" name="cropToSiteId"     value="<%=cropToSiteId%>">
                <input type="hidden" id="hidEmp_<%=rid%>"         name="empId">
                <input type="hidden" id="hidDate_<%=rid%>"        name="workDate">
                <input type="hidden" id="hidTasksCsv_<%=rid%>"    name="taskIdsCsv">
                <input type="hidden" id="hidTypeOfWork_<%=rid%>"  name="typeOfWork">
                <input type="hidden" id="hidAmount_<%=rid%>"      name="amount">
                <input type="hidden" id="hidAdvPay_<%=rid%>"      name="advPayment">
                <input type="hidden" id="hidStatus_<%=rid%>"      name="workStatus">
                <input type="hidden" id="hidRemark_<%=rid%>"      name="remark">
            </form>

            <button type="button" class="btn-row-save" id="btnSave_<%=rid%>"
                    style="display:none;" onclick="saveAllocRow(<%=rid%>)"><%= msg.getString("btn.save") %></button>
            <button type="button" class="btn-row-cancel" id="btnCancel_<%=rid%>"
                    style="display:none;" onclick="cancelAllocRow(<%=rid%>)"><%= msg.getString("btn.cancel") %></button>
        </td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="4" style="text-align:right;"><%= msg.getString("fert_alloc.tbl_footer_grand_total") %></td>
        <td style="text-align:right;"><%=String.format("%.2f", totalAmount)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", totalAdv)%></td>
        <td colspan="3"></td>
    </tr>
    </tfoot>
</table>
</div>
<% } %>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
