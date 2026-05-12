<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    AssignResourceEmployeeToFarmService farmService = new AssignResourceEmployeeToFarmService();
    PaymentProcessingDao salaryDao = new PaymentProcessingDao();
    List<AssignEmployeeToFarmEntity> allAssignments = farmService.getListOFEmployeeToFarm();

    Map<Integer, Double> salaryByAssignId = new LinkedHashMap<Integer, Double>();
    for (AssignEmployeeToFarmEntity aef : allAssignments) {
        salaryByAssignId.put(aef.getAssignResourceId(),
            salaryDao.getTotalSalaryPaidByAssignResourceId(aef.getAssignResourceId()));
    }

    /* Group by (siteInfoId|date|crop) for summary table */
    Map<String, double[]>  sdStats  = new LinkedHashMap<String, double[]>();
    Map<String, String[]>  sdLabels = new LinkedHashMap<String, String[]>();

    for (AssignEmployeeToFarmEntity aef : allAssignments) {
        if (aef.getCropToSiteEntity() == null || aef.getCropToSiteEntity().getSiteInformationEntity() == null) continue;
        int    siteId   = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteInfoId();
        String siteName = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
        String cropName = aef.getCropEntity() != null ? aef.getCropEntity().getCropName() : "";
        String dateDisp = aef.getAssignWorkDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(aef.getAssignWorkDate().toString()) : "";
        String key = siteId + "|" + dateDisp + "|" + cropName;

        if (!sdStats.containsKey(key)) {
            sdStats.put(key, new double[]{0,0,0,0});
            sdLabels.put(key, new String[]{siteName != null ? siteName : "", dateDisp, cropName});
        }
        double sp = salaryByAssignId.containsKey(aef.getAssignResourceId())
                  ? salaryByAssignId.get(aef.getAssignResourceId()) : 0;
        double[] s = sdStats.get(key);
        s[0] += aef.getAmount();
        s[1] += aef.getAdvPayment() + sp;
        if ("Completed".equals(aef.getWorkStatus())) s[2]++; else s[3]++;
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<link rel="stylesheet" href="../../css/datatables.min.css">
<title>Site Expenditure &amp; Dispatch Status Report</title>
<style>
    /* ── filter bar ── */
    .filter-bar         { display:flex; align-items:flex-end; gap:12px; flex-wrap:wrap;
                          background:#f1f8e9; border:1px solid var(--green-bd,#a5d6a7);
                          border-radius:var(--r-md,6px); padding:12px 16px; margin-bottom:12px; }
    .filter-group       { display:flex; flex-direction:column; gap:4px; }
    .filter-group label { font-size:11px; font-weight:700; text-transform:uppercase;
                          letter-spacing:.4px; color:var(--text-muted,#666); }
    .filter-group select{ border:1px solid #ccc; border-radius:var(--r-sm,3px);
                          padding:6px 10px; font-size:13px; min-width:160px; }
    .filter-group select:focus { outline:none; border-color:var(--green-dk); }
    .filter-actions     { display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; margin-left:auto; }
    .btn-reset          { background:#fff; border:1px solid var(--green-dk); color:var(--green-dk);
                          padding:7px 16px; border-radius:var(--r-sm,3px); font-size:12px;
                          font-weight:600; cursor:pointer; }
    .btn-reset:hover    { background:#f1f8e9; }
    .btn-export         { background:var(--green-dk); color:#fff; border:none;
                          padding:7px 14px; border-radius:var(--r-sm,3px); font-size:12px;
                          font-weight:600; cursor:pointer; }
    .btn-export:hover   { background:#2e7d32; }
    .btn-pdf            { background:#1565c0; color:#fff; border:none;
                          padding:7px 14px; border-radius:var(--r-sm,3px); font-size:12px;
                          font-weight:600; cursor:pointer; }
    .btn-pdf:hover      { background:#0d47a1; }

    /* ── active filter chips ── */
    .chip-bar           { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:10px; min-height:0; }
    .chip               { display:inline-flex; align-items:center; gap:5px; background:#e8f5e9;
                          border:1px solid var(--green-bd,#a5d6a7); border-radius:12px;
                          padding:3px 12px; font-size:12px; }
    .chip .chip-lbl     { color:var(--text-muted,#777); }
    .chip .chip-val     { font-weight:700; color:var(--green-dk); }
    .chip .chip-x       { color:var(--green-dk); cursor:pointer; font-size:14px; line-height:1;
                          margin-left:2px; font-weight:700; }
    .chip .chip-x:hover { color:#c62828; }

    /* ── stats bar ── */
    .stats-bar          { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:14px; }
    .stat-card          { background:#fff; border:1px solid var(--gray-200,#e0e0e0);
                          border-radius:var(--r-md,6px); padding:10px 18px; min-width:140px;
                          text-align:center; box-shadow:0 1px 3px rgba(0,0,0,.04); }
    .stat-card.highlight{ background:#e8f5e9; border-color:var(--green-bd,#a5d6a7); }
    .stat-card.warn     { background:#fff8e1; border-color:#ffcc80; }
    .sc-val             { font-size:1.2em; font-weight:700; color:var(--green-dk); }
    .sc-val.red         { color:#c62828; }
    .sc-lbl             { font-size:0.7em; text-transform:uppercase; letter-spacing:.5px;
                          color:var(--text-muted,#777); margin-top:3px; }

    /* ── section headers ── */
    .section-title      { font-weight:700; color:var(--green-dk); font-size:0.95em;
                          border-bottom:2px solid var(--green-bd,#a5d6a7);
                          padding-bottom:4px; margin:14px 0 8px;
                          display:flex; align-items:center; justify-content:space-between; }
    .section-title small{ font-weight:normal; color:var(--text-muted,#888); font-size:0.8em; }

    /* ── export sub-buttons beside section titles ── */
    .tbl-export-btns    { display:flex; gap:6px; }
    .btn-tbl-xls        { background:#217346; color:#fff; border:none; padding:3px 10px;
                          border-radius:var(--r-sm,3px); font-size:11px; font-weight:600; cursor:pointer; }
    .btn-tbl-xls:hover  { background:#1a5c38; }

    /* ── print-only layout ── */
    @media print {
        .no-print { display:none !important; }
        .filter-bar, .chip-bar, .stats-bar { display:none !important; }
        fieldset { border:none; }
        legend   { display:none; }
        .section-title { font-size:12px; }
        .print-header  { display:block !important; }
    }
    .print-header { display:none; text-align:center; margin-bottom:12px; }
    .print-header h2 { font-size:16px; margin:0 0 4px; color:#2e7d32; }
    .print-header p  { font-size:11px; color:#555; margin:0; }
</style>
</head>
<body>
<%@include file="../../header.jsp" %>
<script>
/* ── Filter lookup data (built server-side) ── */
var filterData = [
<%
for (Map.Entry<String, String[]> e : sdLabels.entrySet()) {
    String[] lbl = e.getValue();
    String s = lbl[0].replace("\\","\\\\").replace("'","\\'");
    String d = lbl[1].replace("\\","\\\\").replace("'","\\'");
    String c = lbl[2].replace("\\","\\\\").replace("'","\\'");
%>
{ site:'<%=s%>', date:'<%=d%>', crop:'<%=c%>' },
<% } %>
];

/* ── Build lookup maps ── */
var siteDateMap  = {};  /* site -> { date: true }   */
var sdCropMap    = {};  /* "site|date" -> { crop: true } */

filterData.forEach(function(r) {
    if (!r.site) return;
    if (!siteDateMap[r.site]) siteDateMap[r.site] = {};
    if (r.date) siteDateMap[r.site][r.date] = true;
    var key = r.site + '|' + r.date;
    if (!sdCropMap[key]) sdCropMap[key] = {};
    if (r.crop) sdCropMap[key][r.crop] = true;
});

var summaryDt, detailDt;

/* ── Custom DataTables search filter ── */
$.fn.dataTable.ext.search.push(function(settings, data) {
    var site = $('#filterSite').val();
    var date = $('#filterDate').val();
    var crop = $('#filterCrop').val();
    if (!site && !date && !crop) return true;
    var id = settings.nTable.id;
    var sc, dc, cc;
    if      (id === 'siteSummaryTable') { sc=1; dc=2; cc=3; }
    else if (id === 'siteDetailTable')  { sc=2; dc=1; cc=3; }
    else return true;
    if (site && $.trim(data[sc]) !== site) return false;
    if (date && $.trim(data[dc]) !== date) return false;
    if (crop && $.trim(data[cc]) !== crop) return false;
    return true;
});

$(document).ready(function() {
    /* init DataTables */
    var dtOpts = {
        destroy:true,          /* allow re-init after tableInit.js generic pass */
        pageLength:25,
        lengthMenu:[[10,25,50,-1],[10,25,50,'All']],
        autoWidth:false, scrollX:true,
        language:{
            search:'', searchPlaceholder:'Search within table…',
            lengthMenu:'Show _MENU_ entries',
            info:'_START_ – _END_ of _TOTAL_',
            infoEmpty:'0 entries', emptyTable:'No records',
            paginate:{ previous:'&#8249;', next:'&#8250;' }
        },
        dom:'<"dt-toolbar"lf>rt<"dt-footer"ip>'
    };
    summaryDt = $('#siteSummaryTable').DataTable($.extend({},dtOpts,{
        columnDefs:[{ orderable:false, targets:[8] }]
    }));
    detailDt = $('#siteDetailTable').DataTable($.extend({},dtOpts,{
        columnDefs:[{ orderable:false, targets:[0] }]
    }));

    /* populate site dropdown */
    var sites = Object.keys(siteDateMap).sort();
    sites.forEach(function(s) {
        $('#filterSite').append('<option value="'+escHtml(s)+'">'+escHtml(s)+'</option>');
    });

    updateStats();

    /* ── dependent dropdowns ── */
    $('#filterSite').on('change', function() {
        var site = $(this).val();
        resetSelect('#filterDate','-- All Dates --');
        resetSelect('#filterCrop','-- All Crops --');
        if (site && siteDateMap[site]) {
            var dates = Object.keys(siteDateMap[site]).sort(dateSort);
            dates.forEach(function(d) {
                $('#filterDate').append('<option value="'+escHtml(d)+'">'+escHtml(d)+'</option>');
            });
        }
        applyFilters();
    });

    $('#filterDate').on('change', function() {
        var site = $('#filterSite').val();
        var date = $(this).val();
        resetSelect('#filterCrop','-- All Crops --');
        if (site && date) {
            var crops = Object.keys(sdCropMap[site+'|'+date] || {}).sort();
            crops.forEach(function(c) {
                if (c) $('#filterCrop').append('<option value="'+escHtml(c)+'">'+escHtml(c)+'</option>');
            });
        }
        applyFilters();
    });

    $('#filterCrop').on('change', function() { applyFilters(); });

    $('#btnReset').on('click', function() {
        resetSelect('#filterSite','-- All Sites --');
        resetSelect('#filterDate','-- All Dates --');
        resetSelect('#filterCrop','-- All Crops --');
        /* re-populate site options */
        sites.forEach(function(s) {
            $('#filterSite').append('<option value="'+escHtml(s)+'">'+escHtml(s)+'</option>');
        });
        applyFilters();
    });
});

/* ── helpers ── */
function escHtml(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function resetSelect(sel, placeholder) {
    $(sel).empty().append('<option value="">'+placeholder+'</option>');
}
function dateSort(a, b) {
    /* sort dd/mm/yyyy strings */
    function toNum(d) {
        var p = d.split('/');
        return p.length===3 ? parseInt(p[2])*10000+parseInt(p[1])*100+parseInt(p[0]) : 0;
    }
    return toNum(a) - toNum(b);
}

function applyFilters() {
    summaryDt.draw();
    detailDt.draw();
    updateChips();
    updateStats();
}

function updateStats() {
    var rows = detailDt.rows({search:'applied'}).data();
    var tAmt=0, tAdv=0, tSal=0;
    for (var i=0; i<rows.length; i++) {
        tAmt += parseFloat(String(rows[i][8]).replace(/[^0-9.\-]/g,'')) || 0;
        tAdv += parseFloat(String(rows[i][9]).replace(/[^0-9.\-]/g,'')) || 0;
        tSal += parseFloat(String(rows[i][10]).replace(/[^0-9.\-]/g,'')) || 0;
    }
    var tPaid = tAdv + tSal;
    var bal   = Math.max(0, tAmt - tPaid);
    $('#statRecords').text(rows.length);
    $('#statAssigned').text('\u20B9 '+tAmt.toFixed(2));
    $('#statPaid').text('\u20B9 '+tPaid.toFixed(2));
    $('#statBalance').text('\u20B9 '+bal.toFixed(2));
}

function updateChips() {
    var bar = $('#chipBar').empty();
    var site = $('#filterSite').val();
    var date = $('#filterDate').val();
    var crop = $('#filterCrop').val();
    if (!site && !date && !crop) { bar.hide(); return; }
    if (site) bar.append(chip('Site', site, function(){ $('#filterSite').val('').trigger('change'); }));
    if (date) bar.append(chip('Date', date, function(){ $('#filterDate').val('').trigger('change'); }));
    if (crop) bar.append(chip('Crop', crop, function(){ $('#filterCrop').val('').trigger('change'); }));
    bar.show();
}
function chip(lbl, val, removeFn) {
    var c = $('<span class="chip"><span class="chip-lbl">'+escHtml(lbl)+':</span> <span class="chip-val">'+escHtml(val)+'</span><span class="chip-x" title="Clear">&times;</span></span>');
    c.find('.chip-x').on('click', removeFn);
    return c;
}

/* ── CSV export (filtered rows) ── */
function exportCSV(dt, filename) {
    var cols = [];
    $(dt.table().header()).find('th').each(function() { cols.push($(this).text().trim()); });
    var rows = dt.rows({search:'applied'}).data();

    function escCsv(val) {
        /* strip any HTML tags, then quote the value if it contains special chars */
        var s = $('<div/>').html(String(val)).text().replace(/\r?\n/g,' ').trim();
        return (s.indexOf(',') !== -1 || s.indexOf('"') !== -1 || s.indexOf('\n') !== -1)
            ? '"' + s.replace(/"/g,'""') + '"'
            : s;
    }

    var csv = cols.map(escCsv).join(',') + '\r\n';
    for (var i = 0; i < rows.length; i++) {
        var line = [];
        for (var j = 0; j < rows[i].length; j++) line.push(escCsv(rows[i][j]));
        csv += line.join(',') + '\r\n';
    }

    /* UTF-8 BOM so Excel / mobile apps render characters (₹, Indian names) correctly */
    var blob = new Blob(['﻿' + csv], {type:'text/csv;charset=utf-8'});
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement('a');
    a.href   = url;
    a.download = filename + '_' + new Date().toISOString().slice(0,10) + '.csv';
    document.body.appendChild(a); a.click();
    document.body.removeChild(a); URL.revokeObjectURL(url);
}

/* ── PDF / Print export ── */
function printReport() {
    var site = $('#filterSite').val() || 'All';
    var date = $('#filterDate').val() || 'All';
    var crop = $('#filterCrop').val() || 'All';
    var generated = new Date().toLocaleDateString('en-IN');

    function tblHtml(dt, caption) {
        var cols = [];
        $(dt.table().header()).find('th').each(function() { cols.push($(this).text().trim()); });
        var rows = dt.rows({search:'applied'}).data();
        var h = '<p style="font-weight:700;color:#2e7d32;margin:14px 0 4px;">'+caption+'</p><table border="1" cellspacing="0" cellpadding="4" style="width:100%;border-collapse:collapse;font-size:10px;"><thead><tr>';
        cols.forEach(function(c) { h += '<th style="background:#4caf50;color:#fff;padding:5px;">'+c+'</th>'; });
        h += '</tr></thead><tbody>';
        for (var i=0; i<rows.length; i++) {
            var bg = i%2===0 ? '#fff' : '#f9fbe7';
            h += '<tr style="background:'+bg+'">';
            for (var j=0; j<rows[i].length; j++) {
                var v = $('<div/>').html(String(rows[i][j])).text();
                h += '<td style="padding:4px;">'+v+'</td>';
            }
            h += '</tr>';
        }
        h += '</tbody></table>';
        return h;
    }

    var win = window.open('','_blank','width=1100,height=700');
    win.document.write(
        '<html><head><title>Site Expenditure Report</title>'+
        '<style>body{font-family:Arial,sans-serif;font-size:11px;margin:20px;}'+
        'h2{color:#2e7d32;margin:0 0 4px;}'+
        '.meta{font-size:10px;color:#555;margin-bottom:14px;}'+
        'table{page-break-inside:auto;} tr{page-break-inside:avoid;}</style></head><body>'+
        '<h2>Site Expenditure &amp; Dispatch Status Report</h2>'+
        '<div class="meta">Site: <b>'+site+'</b> &nbsp;|&nbsp; Date: <b>'+date+'</b> &nbsp;|&nbsp; Crop: <b>'+crop+'</b> &nbsp;|&nbsp; Generated: <b>'+generated+'</b></div>'+
        tblHtml(summaryDt, 'Summary by Site, Date &amp; Crop')+
        tblHtml(detailDt,  'Assignment Details')+
        '</body></html>'
    );
    win.document.close();
    win.focus();
    setTimeout(function(){ win.print(); }, 400);
}
</script>

<fieldset>
<legend>Site Expenditure &amp; Dispatch Status Report</legend>

<!-- ── Filter bar ── -->
<div class="filter-bar no-print">
    <div class="filter-group">
        <label for="filterSite">Site</label>
        <select id="filterSite"><option value="">-- All Sites --</option></select>
    </div>
    <div class="filter-group">
        <label for="filterDate">Date</label>
        <select id="filterDate"><option value="">-- All Dates --</option></select>
    </div>
    <div class="filter-group">
        <label for="filterCrop">Crop</label>
        <select id="filterCrop"><option value="">-- All Crops --</option></select>
    </div>
    <div class="filter-actions">
        <button id="btnReset" class="btn-reset">&#10005; Reset</button>
        <button class="btn-export" onclick="exportCSV(summaryDt,'SiteSummary')">&#8595; Summary CSV</button>
        <button class="btn-export" onclick="exportCSV(detailDt,'SiteDetail')">&#8595; Detail CSV</button>
        <button class="btn-pdf"   onclick="printReport()">&#128438; Print / PDF</button>
    </div>
</div>

<!-- ── Active filter chips ── -->
<div id="chipBar" class="chip-bar no-print" style="display:none;"></div>

<!-- ── Filtered stats ── -->
<div class="stats-bar no-print">
    <div class="stat-card highlight">
        <div class="sc-val" id="statRecords">—</div>
        <div class="sc-lbl">Filtered Records</div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val" id="statAssigned">—</div>
        <div class="sc-lbl">Total Assigned</div>
    </div>
    <div class="stat-card">
        <div class="sc-val" id="statPaid">—</div>
        <div class="sc-lbl">Total Paid</div>
    </div>
    <div class="stat-card warn">
        <div class="sc-val red" id="statBalance">—</div>
        <div class="sc-lbl">Balance Due</div>
    </div>
</div>

<!-- ── Summary table ── -->
<div class="section-title">
    <span>Site Summary <small>&mdash; grouped by Site, Date &amp; Crop</small></span>
    <div class="tbl-export-btns no-print">
        <button class="btn-tbl-xls" onclick="exportCSV(summaryDt,'SiteSummary')">&#8595; CSV</button>
    </div>
</div>
<div style="overflow-x:auto;">
<table id="siteSummaryTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Sr.</th>
        <th>Site</th>
        <th>Date</th>
        <th>Crop</th>
        <th>Total Assigned (Rs)</th>
        <th>Total Paid (Rs)</th>
        <th>Balance (Rs)</th>
        <th>Done / Pending</th>
        <th>Status</th>
    </tr>
    </thead>
    <tbody>
    <%
        int siteCnt=0; double grandAssigned=0, grandPaid=0;
        for (Map.Entry<String, double[]> entry : sdStats.entrySet()) {
            siteCnt++;
            String[] lbl      = sdLabels.get(entry.getKey());
            double[] s        = entry.getValue();
            double rowBalance = Math.max(0, s[0]-s[1]);
            int rowDone=(int)s[2], rowPending=(int)s[3];
            boolean ready = (rowDone>0||rowPending>0) && rowPending==0;
            grandAssigned += s[0]; grandPaid += s[1];
    %>
    <tr>
        <td><%=siteCnt%></td>
        <td><%=lbl[0]%></td>
        <td><%=lbl[1]%></td>
        <td><%=lbl[2]%></td>
        <td style="text-align:right;"><%=String.format("%.2f",s[0])%></td>
        <td style="text-align:right;"><%=String.format("%.2f",s[1])%></td>
        <td style="text-align:right;"><%=String.format("%.2f",rowBalance)%></td>
        <td style="text-align:center;"><%=rowDone%>&nbsp;/&nbsp;<%=rowPending%></td>
        <td style="text-align:center;">
            <% if (rowDone==0&&rowPending==0) { %><span class="dispatch-badge pending">No Tasks</span>
            <% } else if (ready) { %><span class="dispatch-badge ready">&#10003; All Done</span>
            <% } else { %><span class="dispatch-badge pending">&#9888; <%=rowPending%> Pending</span>
            <% } %>
        </td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="4" style="text-align:right;">Grand Total</td>
        <td style="text-align:right;"><%=String.format("%.2f",grandAssigned)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",grandPaid)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",Math.max(0,grandAssigned-grandPaid))%></td>
        <td colspan="2"></td>
    </tr>
    </tfoot>
</table>
</div>

<hr style="margin:18px 0;">

<!-- ── Detail table ── -->
<div class="section-title">
    <span>Assignment Details <small>&mdash; all individual records</small></span>
    <div class="tbl-export-btns no-print">
        <button class="btn-tbl-xls" onclick="exportCSV(detailDt,'SiteDetail')">&#8595; CSV</button>
    </div>
</div>
<div style="overflow-x:auto;">
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
        int detailCnt=0; double ttlAmt=0,ttlAdv=0,ttlSal=0;
        for (AssignEmployeeToFarmEntity aef : allAssignments) {
            if (aef==null) continue;
            detailCnt++;
            double salPaid    = salaryByAssignId.containsKey(aef.getAssignResourceId())
                              ? salaryByAssignId.get(aef.getAssignResourceId()) : 0;
            double totalPaidRow = aef.getAdvPayment() + salPaid;
            double balRow       = Math.max(0, aef.getAmount()-totalPaidRow);
            ttlAmt+=aef.getAmount(); ttlAdv+=aef.getAdvPayment(); ttlSal+=salPaid;

            String empName="";
            if (aef.getEmployeeInfoEntity()!=null) {
                if(aef.getEmployeeInfoEntity().getFirstName() !=null) empName+=aef.getEmployeeInfoEntity().getFirstName()+" ";
                if(aef.getEmployeeInfoEntity().getMiddleName()!=null) empName+=aef.getEmployeeInfoEntity().getMiddleName()+" ";
                if(aef.getEmployeeInfoEntity().getLastName()  !=null) empName+=aef.getEmployeeInfoEntity().getLastName();
            }
            String siteName="";
            if (aef.getCropToSiteEntity()!=null&&aef.getCropToSiteEntity().getSiteInformationEntity()!=null)
                siteName=aef.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
            String cropName = aef.getCropEntity()!=null ? aef.getCropEntity().getCropName() : "";
            StringBuilder tasks=new StringBuilder(); int ti=0;
            for(ConfigFarmTaskEntity t:aef.getListFarmTaskEntities()){if(ti++>0)tasks.append(", ");tasks.append(t.getTaskName());}
            String ws=aef.getWorkStatus()!=null?aef.getWorkStatus():"";
            String wsStyle="Completed".equals(ws)?"color:#155724;font-weight:bold;"
                          :"Pending".equals(ws)?"color:#856404;font-weight:bold;"
                          :"Reject".equals(ws)?"color:#721c24;font-weight:bold;":"";
    %>
    <tr>
        <td><%=detailCnt%></td>
        <td><%=aef.getAssignWorkDate()!=null?FarmUtility.convertfrom_yymmddToddmmyy(aef.getAssignWorkDate().toString()):""%></td>
        <td><%=siteName%></td>
        <td><%=cropName%></td>
        <td><%=empName.trim()%></td>
        <td><%=aef.getTypeOfWork()!=null?aef.getTypeOfWork():""%></td>
        <td style="<%=wsStyle%>"><%=ws%></td>
        <td><%=tasks.toString()%></td>
        <td style="text-align:right;"><%=String.format("%.2f",aef.getAmount())%></td>
        <td style="text-align:right;"><%=String.format("%.2f",aef.getAdvPayment())%></td>
        <td style="text-align:right;"><%=String.format("%.2f",salPaid)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",balRow)%></td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="8" style="text-align:right;">Total</td>
        <td style="text-align:right;"><%=String.format("%.2f",ttlAmt)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",ttlAdv)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",ttlSal)%></td>
        <td style="text-align:right;"><%=String.format("%.2f",Math.max(0,ttlAmt-ttlAdv-ttlSal))%></td>
    </tr>
    </tfoot>
</table>
</div>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
