<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<link rel="stylesheet" href="../../css/style.css">
<title>Assignment Detail</title>
<style>
    /* ── layout ── */
    .detail-wrap        { max-width:820px; margin:0 auto; padding:10px 0 30px; }
    .page-header        { display:flex; align-items:center; justify-content:space-between;
                          flex-wrap:wrap; gap:10px; margin-bottom:16px; }
    .page-header-left   { display:flex; align-items:center; gap:14px; flex-wrap:wrap; }
    .page-title         { font-size:1.1em; font-weight:700; color:var(--green-dk); margin:0; }
    .back-link          { font-size:12px; color:var(--green-dk); text-decoration:none; }
    .back-link:hover    { text-decoration:underline; }
    .record-id          { font-size:11px; color:var(--text-muted); font-weight:normal; }

    /* ── action buttons ── */
    .btn-edit           { background:var(--green-dk); color:#fff; border:none; padding:8px 22px;
                          border-radius:var(--r-sm,3px); font-size:13px; font-weight:700;
                          cursor:pointer; text-decoration:none; display:inline-block; }
    .btn-edit:hover     { background:#2e7d32; }
    .btn-print          { background:#fff; color:var(--green-dk); border:1px solid var(--green-dk);
                          padding:8px 16px; border-radius:var(--r-sm,3px); font-size:13px;
                          font-weight:600; cursor:pointer; }
    .btn-print:hover    { background:#f1f8e9; }

    /* ── info chips row ── */
    .info-bar           { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:18px; }
    .info-chip          { background:#f1f8e9; border:1px solid var(--green-bd,#a5d6a7);
                          border-radius:20px; padding:5px 14px; font-size:12px;
                          display:inline-flex; gap:5px; align-items:center; }
    .chip-lbl           { color:var(--text-muted,#666); }
    .chip-val           { font-weight:700; color:var(--green-dk); }

    /* ── status pill ── */
    .status-pill        { display:inline-block; padding:3px 12px; border-radius:12px;
                          font-size:12px; font-weight:700; }
    .pill-Completed     { background:#e8f5e9; color:#2e7d32; }
    .pill-Pending       { background:#fff3e0; color:#e65100; }
    .pill-Reject        { background:#fdecea; color:#c62828; }

    /* ── financial summary cards ── */
    .fin-grid           { display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr));
                          gap:12px; margin-bottom:18px; }
    .fin-card           { background:#fff; border:1px solid var(--gray-200,#e0e0e0);
                          border-radius:var(--r-md,6px); padding:14px 18px; text-align:center;
                          box-shadow:0 1px 3px rgba(0,0,0,.04); }
    .fin-card .fc-val   { font-size:1.35em; font-weight:700; color:var(--green-dk); }
    .fin-card .fc-lbl   { font-size:0.7em; text-transform:uppercase; letter-spacing:.5px;
                          color:var(--text-muted,#777); margin-top:4px; }
    .fin-card.balance   { border-color:#a5d6a7; background:#e8f5e9; }
    .fin-card.excess    { border-color:#ef9a9a; background:#fdecea; }
    .fin-card.excess .fc-val { color:#c62828; }
    .fin-card.warning   { border-color:#ffcc80; background:#fff8e1; }
    .fin-card.warning .fc-val { color:#e65100; }

    /* ── detail cards ── */
    .detail-card        { background:#fff; border:1px solid var(--gray-200,#e0e0e0);
                          border-radius:var(--r-md,6px); padding:18px 22px; margin-bottom:14px;
                          box-shadow:0 1px 3px rgba(0,0,0,.04); }
    .card-title         { font-size:0.78em; font-weight:700; text-transform:uppercase;
                          letter-spacing:.6px; color:var(--green-dk);
                          border-bottom:2px solid var(--green-bd,#a5d6a7);
                          padding-bottom:6px; margin:0 0 16px; }

    /* ── detail rows ── */
    .detail-grid        { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr));
                          gap:14px 24px; }
    .detail-field       { display:flex; flex-direction:column; gap:4px; }
    .df-label           { font-size:11px; font-weight:700; text-transform:uppercase;
                          letter-spacing:.4px; color:var(--text-muted,#666); }
    .df-value           { font-size:14px; color:#222; font-weight:500; }
    .df-value.muted     { color:var(--text-muted,#888); font-style:italic; }

    /* ── task badge pills ── */
    .task-pills         { display:flex; flex-wrap:wrap; gap:6px; margin-top:2px; }
    .task-pill          { background:#e8f5e9; border:1px solid var(--green-bd,#a5d6a7);
                          border-radius:12px; padding:3px 12px; font-size:12px;
                          font-weight:600; color:var(--green-dk); }

    /* ── comment box ── */
    .comment-box        { background:#fafafa; border:1px solid #e0e0e0; border-radius:var(--r-sm,3px);
                          padding:10px 14px; font-size:13px; color:#444; min-height:40px;
                          white-space:pre-wrap; }

    /* ── print ── */
    @media print {
        .no-print { display:none !important; }
        .detail-wrap { max-width:100%; }
        .fin-card, .detail-card { box-shadow:none; border:1px solid #ccc; }
    }
</style>
</head>
<body>
<%@include file="../../header.jsp"%>

<fieldset>
<legend>Assignment Detail</legend>

<%
AssignEmployeeToFarmEntity assignment = (AssignEmployeeToFarmEntity) request.getAttribute("assignment");
if (assignment == null) {
%>
    <p style="color:var(--text-muted); padding:20px;">No record found. Please select an assignment to view.</p>
<%
} else {
    String formattedDate      = (String) request.getAttribute("formattedDate");
    double ttlTransactionPaid = (Double) request.getAttribute("ttlTransactionPaid");
    double balanceAmount      = (Double) request.getAttribute("balanceAmount");
    double excessAmount       = (Double) request.getAttribute("excessAmount");

    String curStatus    = assignment.getWorkStatus()  != null ? assignment.getWorkStatus()  : "";
    String curTypeWork  = assignment.getTypeOfWork()  != null ? assignment.getTypeOfWork()  : "—";
    String curComment   = assignment.getComment()     != null ? assignment.getComment()     : "";
    double amount       = assignment.getAmount();
    double advPayment   = assignment.getAdvPayment();
    double totalPaid    = advPayment + ttlTransactionPaid;

    String empName = "";
    if (assignment.getEmployeeInfoEntity() != null) {
        String fn = assignment.getEmployeeInfoEntity().getFirstName()  != null ? assignment.getEmployeeInfoEntity().getFirstName().trim()  + " " : "";
        String mn = assignment.getEmployeeInfoEntity().getMiddleName() != null ? assignment.getEmployeeInfoEntity().getMiddleName().trim() + " " : "";
        String ln = assignment.getEmployeeInfoEntity().getLastName()   != null ? assignment.getEmployeeInfoEntity().getLastName().trim()          : "";
        empName = (fn + mn + ln).trim();
    }
    String siteName = (assignment.getCropToSiteEntity() != null && assignment.getCropToSiteEntity().getSiteInformationEntity() != null)
                    ? assignment.getCropToSiteEntity().getSiteInformationEntity().getSiteName() : "—";
    String cropName = assignment.getCropEntity() != null ? assignment.getCropEntity().getCropName() : "—";

    /* determine fin-card variant for balance */
    boolean hasExcess  = excessAmount > 0;
    boolean hasBalance = balanceAmount > 0;

    List<ConfigFarmTaskEntity> taskList = assignment.getListFarmTaskEntities();
%>

<div class="detail-wrap">

    <!-- Page header -->
    <div class="page-header">
        <div class="page-header-left">
            <a class="back-link no-print"
               href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">&#8592; Back to All Assignments</a>
            <span style="color:#ccc;" class="no-print">|</span>
            <span class="page-title">Assignment Detail
                <span class="record-id">&nbsp;#<%=assignment.getAssignResourceId()%></span>
            </span>
        </div>
        <div class="no-print" style="display:flex; gap:8px;">
            <button class="btn-print" onclick="window.print()">&#128438; Print</button>
            <a class="btn-edit"
               href="<%=request.getContextPath()%>/AssignResourcesController?action=edit&assignResourceId=<%=assignment.getAssignResourceId()%>">
               Edit
            </a>
        </div>
    </div>

    <!-- Info chips -->
    <div class="info-bar">
        <span class="info-chip">
            <span class="chip-lbl">Employee:</span>
            <span class="chip-val"><%=empName.isEmpty() ? "—" : empName%></span>
        </span>
        <% if (formattedDate != null && !formattedDate.isEmpty()) { %>
        <span class="info-chip">
            <span class="chip-lbl">Work Date:</span>
            <span class="chip-val"><%=formattedDate%></span>
        </span>
        <% } %>
        <span class="info-chip">
            <span class="chip-lbl">Site:</span>
            <span class="chip-val"><%=siteName%></span>
        </span>
        <span class="info-chip">
            <span class="chip-lbl">Status:</span>
            <span class="status-pill pill-<%=curStatus%>"><%=curStatus.isEmpty() ? "—" : curStatus%></span>
        </span>
    </div>

    <!-- Financial summary cards -->
    <div class="fin-grid">
        <div class="fin-card">
            <div class="fc-val">&#8377; <%=String.format("%.2f", amount)%></div>
            <div class="fc-lbl">Amount Due</div>
        </div>
        <div class="fin-card">
            <div class="fc-val">&#8377; <%=String.format("%.2f", advPayment)%></div>
            <div class="fc-lbl">Advance Paid</div>
        </div>
        <div class="fin-card">
            <div class="fc-val">&#8377; <%=String.format("%.2f", ttlTransactionPaid)%></div>
            <div class="fc-lbl">Transactions Paid</div>
        </div>
        <div class="fin-card">
            <div class="fc-val">&#8377; <%=String.format("%.2f", totalPaid)%></div>
            <div class="fc-lbl">Total Paid</div>
        </div>
        <% if (hasBalance) { %>
        <div class="fin-card <%=hasBalance ? "warning" : "balance"%>">
            <div class="fc-val">&#8377; <%=String.format("%.2f", balanceAmount)%></div>
            <div class="fc-lbl">Balance Due</div>
        </div>
        <% } %>
        <% if (hasExcess) { %>
        <div class="fin-card excess">
            <div class="fc-val">&#8377; <%=String.format("%.2f", excessAmount)%></div>
            <div class="fc-lbl">Excess Paid</div>
        </div>
        <% } %>
    </div>

    <!-- Work details card -->
    <div class="detail-card">
        <div class="card-title">Work Details</div>
        <div class="detail-grid">
            <div class="detail-field">
                <span class="df-label">Type of Work</span>
                <span class="df-value"><%=curTypeWork%></span>
            </div>
            <div class="detail-field">
                <span class="df-label">Crop</span>
                <span class="df-value"><%=cropName%></span>
            </div>
            <div class="detail-field" style="grid-column:span 2;">
                <span class="df-label">Task(s)</span>
                <% if (taskList != null && !taskList.isEmpty()) { %>
                <div class="task-pills">
                    <% for (ConfigFarmTaskEntity t : taskList) { %>
                    <span class="task-pill"><%=t.getTaskName()%></span>
                    <% } %>
                </div>
                <% } else { %>
                <span class="df-value muted">No tasks assigned</span>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Site & assignment card -->
    <div class="detail-card">
        <div class="card-title">Site &amp; Assignment</div>
        <div class="detail-grid">
            <div class="detail-field">
                <span class="df-label">Site</span>
                <span class="df-value"><%=siteName%></span>
            </div>
            <div class="detail-field">
                <span class="df-label">Work Date</span>
                <span class="df-value"><%=formattedDate != null ? formattedDate : "—"%></span>
            </div>
            <div class="detail-field">
                <span class="df-label">Work Status</span>
                <span class="status-pill pill-<%=curStatus%>" style="font-size:13px;"><%=curStatus.isEmpty() ? "—" : curStatus%></span>
            </div>
            <div class="detail-field">
                <span class="df-label">Assignment ID</span>
                <span class="df-value">#<%=assignment.getAssignResourceId()%></span>
            </div>
        </div>
    </div>

    <!-- Comment card (only if present) -->
    <% if (!curComment.isEmpty()) { %>
    <div class="detail-card">
        <div class="card-title">Remarks</div>
        <div class="comment-box"><%=curComment%></div>
    </div>
    <% } %>

    <!-- Bottom action bar -->
    <div class="no-print" style="display:flex; justify-content:flex-end; gap:10px; margin-top:6px;">
        <a class="back-link" style="align-self:center;"
           href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">&#8592; Back to All Assignments</a>
        <a class="btn-edit"
           href="<%=request.getContextPath()%>/AssignResourcesController?action=edit&assignResourceId=<%=assignment.getAssignResourceId()%>">
           Edit Assignment
        </a>
    </div>

</div>
<% } %>
</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
