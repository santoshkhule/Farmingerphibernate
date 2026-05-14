<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.CropSaleDao"%>
<%@page import="com.san.farm.adminuser.dao.SalePaymentDao"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.CropSaleEntity"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    /* ── Financial Year ── */
    Calendar cal = Calendar.getInstance();
    int curYear  = cal.get(Calendar.YEAR);
    int curMonth = cal.get(Calendar.MONTH) + 1;
    int curFyStart = (curMonth >= 4) ? curYear : curYear - 1;

    int selFy = curFyStart;
    String fyParam = request.getParameter("fyYear");
    if (fyParam != null && !fyParam.trim().isEmpty()) {
        try { selFy = Integer.parseInt(fyParam.trim()); } catch (Exception e) {}
    }

    Date fyFrom = Date.valueOf(selFy + "-04-01");
    Date fyTo   = Date.valueOf((selFy + 1) + "-03-31");

    /* ── Fetch raw data ── */
    List<AssignEmployeeToFarmEntity> allAssignments = new ArrayList<AssignEmployeeToFarmEntity>();
    List<CropSaleEntity>             allSales       = new ArrayList<CropSaleEntity>();
    try {
        allAssignments = new AssignResourceEmployeeToFarmService().getListOFEmployeeToFarm();
        allSales       = new CropSaleDao().getAll();
    } catch (Exception ex) { ex.printStackTrace(); }

    SalePaymentDao paymentDao = new SalePaymentDao();

    /*
     * Key structure: siteInfoId -> cropId -> double[3]
     *   [0] = expenditure   (total labor amount assigned, FY-filtered by assignWorkDate)
     *   [1] = incomeExpected (total sale amount, FY-filtered by saleDate)
     *   [2] = incomeReceived (total payments received against those sales)
     */
    Map<Integer, Map<Integer, double[]>> data = new LinkedHashMap<Integer, Map<Integer, double[]>>();

    /* site name and crop name lookup */
    Map<Integer, String> siteNames = new LinkedHashMap<Integer, String>();
    Map<Integer, String> cropNames = new LinkedHashMap<Integer, String>();

    /* ── Expenditure: filter by assignWorkDate in FY ── */
    for (AssignEmployeeToFarmEntity aef : allAssignments) {
        if (aef == null) continue;
        if (aef.getCropToSiteEntity() == null || aef.getCropToSiteEntity().getSiteInformationEntity() == null) continue;
        if (aef.getAssignWorkDate() == null) continue;
        if (aef.getAssignWorkDate().before(fyFrom) || aef.getAssignWorkDate().after(fyTo)) continue;

        int siteId = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteInfoId();
        String sn  = aef.getCropToSiteEntity().getSiteInformationEntity().getSiteName();
        if (sn == null) sn = "Site #" + siteId;
        siteNames.put(siteId, sn);

        int cropId = 0;
        String cn  = "(No Crop)";
        if (aef.getCropEntity() != null) {
            cropId = aef.getCropEntity().getCropId();
            cn     = aef.getCropEntity().getCropName() != null ? aef.getCropEntity().getCropName() : cn;
        }
        cropNames.put(cropId, cn);

        if (!data.containsKey(siteId)) data.put(siteId, new LinkedHashMap<Integer, double[]>());
        if (!data.get(siteId).containsKey(cropId)) data.get(siteId).put(cropId, new double[]{0,0,0});
        data.get(siteId).get(cropId)[0] += aef.getAmount();
    }

    /* ── Income: filter by saleDate in FY ── */
    for (CropSaleEntity cs : allSales) {
        if (cs == null || cs.getSaleDate() == null) continue;
        if (cs.getSaleDate().before(fyFrom) || cs.getSaleDate().after(fyTo)) continue;
        if (cs.getAssignCropToSiteEntity() == null || cs.getAssignCropToSiteEntity().getSiteInformationEntity() == null) continue;

        int siteId = cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteInfoId();
        String sn  = cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName();
        if (sn == null) sn = "Site #" + siteId;
        siteNames.put(siteId, sn);

        int cropId = 0;
        String cn  = "(No Crop)";
        if (cs.getCropEntity() != null) {
            cropId = cs.getCropEntity().getCropId();
            cn     = cs.getCropEntity().getCropName() != null ? cs.getCropEntity().getCropName() : cn;
        }
        cropNames.put(cropId, cn);

        if (!data.containsKey(siteId)) data.put(siteId, new LinkedHashMap<Integer, double[]>());
        if (!data.get(siteId).containsKey(cropId)) data.get(siteId).put(cropId, new double[]{0,0,0});

        double received = 0;
        try { received = paymentDao.getTotalReceivedBySaleId(cs.getSaleId()); } catch (Exception e) {}

        data.get(siteId).get(cropId)[1] += cs.getTotalAmount();
        data.get(siteId).get(cropId)[2] += received;
    }

    /* ── Grand totals ── */
    double grandExp = 0, grandInc = 0, grandRec = 0;
    for (Map<Integer, double[]> cropMap : data.values()) {
        for (double[] v : cropMap.values()) { grandExp += v[0]; grandInc += v[1]; grandRec += v[2]; }
    }
    double grandPL  = grandInc - grandExp;
    double grandPLR = grandRec - grandExp;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Profit &amp; Loss Report</title>
<link rel="stylesheet" href="../../css/style.css">
<script src="../../js/jquery-1.9.1.js"></script>
<style>
    /* ── Filter bar ── */
    .filter-bar { display:flex; align-items:flex-end; gap:12px; flex-wrap:wrap;
        background:#f1f8e9; border:1px solid var(--green-bd,#a5d6a7);
        border-radius:var(--r-md,6px); padding:12px 16px; margin-bottom:14px; }
    .filter-group { display:flex; flex-direction:column; gap:4px; }
    .filter-group label { font-size:11px; font-weight:700; text-transform:uppercase;
        letter-spacing:.4px; color:var(--text-muted,#666); }
    .filter-group select { border:1px solid #ccc; border-radius:var(--r-sm,3px);
        padding:6px 10px; font-size:13px; min-width:160px; }
    .filter-group select:focus { outline:none; border-color:var(--green-dk); }

    /* ── Summary cards ── */
    .kpi-bar { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:16px; }
    .kpi-card { flex:1; min-width:130px; text-align:center; padding:12px 10px;
        border-radius:var(--r-md,6px); border:1px solid var(--gray-200,#e0e0e0); background:#fff;
        box-shadow:0 1px 3px rgba(0,0,0,.05); }
    .kpi-card.income  { background:#e8f5e9; border-color:#a5d6a7; }
    .kpi-card.expense { background:#fff8e1; border-color:#ffcc80; }
    .kpi-card.profit  { background:#e3f2fd; border-color:#90caf9; }
    .kpi-card.loss    { background:#fdecea; border-color:#ef9a9a; }
    .kpi-val  { font-size:1.3em; font-weight:700; }
    .kpi-val.green  { color:#1b5e20; }
    .kpi-val.red    { color:#b71c1c; }
    .kpi-val.blue   { color:#0d47a1; }
    .kpi-val.orange { color:#e65100; }
    .kpi-lbl { font-size:10px; text-transform:uppercase; letter-spacing:.5px;
        color:var(--text-muted,#777); margin-top:3px; }

    /* ── Table ── */
    .tbl-data th, .tbl-data td { vertical-align:middle; }
    .row-site-hdr td { background:#c8e6c9; font-weight:700; color:#1b5e20; font-size:12px; padding:7px 10px; }
    .row-site-hdr .site-pl { font-size:13px; }
    .row-crop td { background:#fff; }
    .row-subtotal td { background:#f9fbe7; font-weight:700; font-style:italic; font-size:12px;
        border-top:2px solid #a5d6a7; }
    .row-grandtotal td { background:#e8f5e9; font-weight:700; font-size:12px;
        border-top:3px solid var(--green-bd,#a5d6a7); }
    .pl-profit { color:#1b5e20; font-weight:700; }
    .pl-loss   { color:#b71c1c; font-weight:700; }
    .pl-zero   { color:#757575; }
    .note-row  { font-size:10px; color:#888; padding:6px 14px !important; font-style:italic; }

    @media print {
        .no-print { display:none !important; }
        .kpi-bar  { display:none !important; }
    }
</style>
<script>
    function exportCSV() {
        var rows = [['Site','Crop','Expenditure','Income (Expected)','Income (Received)','P&L (Expected)','P&L (Received)']];
        $('#plTable tbody tr').not('.row-site-hdr').not('.row-subtotal').each(function() {
            var cells = [];
            $(this).find('td').each(function() { cells.push($(this).text().trim()); });
            if (cells.length >= 7) rows.push(cells);
        });
        var csv = rows.map(function(r) {
            return r.map(function(v) {
                v = (v + '').replace(/"/g, '""');
                return (v.indexOf(',') !== -1 || v.indexOf('"') !== -1) ? '"' + v + '"' : v;
            }).join(',');
        }).join('\r\n');
        var blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a'); a.href = url;
        a.download = 'ProfitLoss_FY<%=selFy%>-<%=selFy+1%>.csv';
        document.body.appendChild(a); a.click();
        document.body.removeChild(a); URL.revokeObjectURL(url);
    }
</script>
</head>
<body>

<fieldset><legend>Profit &amp; Loss Report by Site &amp; Crop</legend>

<!-- Filter bar -->
<form method="get" class="no-print">
<div class="filter-bar">
    <div class="filter-group">
        <label for="fyYear">Financial Year</label>
        <select name="fyYear" id="fyYear" onchange="this.form.submit()">
            <% for (int y = curFyStart; y >= curFyStart - 3; y--) { %>
            <option value="<%=y%>"<%=y==selFy?" selected":""%>>FY <%=y%>-<%=y+1%></option>
            <% } %>
        </select>
    </div>
    <div style="align-self:flex-end; margin-left:auto; display:flex; gap:8px;">
        <button type="button" class="btn-add" onclick="exportCSV()">&#8595; CSV</button>
    </div>
</div>
</form>

<!-- KPI summary cards -->
<div class="kpi-bar">
    <div class="kpi-card expense">
        <div class="kpi-val orange">&#8377; <%=String.format("%.2f", grandExp)%></div>
        <div class="kpi-lbl">Total Expenditure</div>
    </div>
    <div class="kpi-card income">
        <div class="kpi-val green">&#8377; <%=String.format("%.2f", grandInc)%></div>
        <div class="kpi-lbl">Total Income (Expected)</div>
    </div>
    <div class="kpi-card income">
        <div class="kpi-val green">&#8377; <%=String.format("%.2f", grandRec)%></div>
        <div class="kpi-lbl">Total Income (Received)</div>
    </div>
    <div class="kpi-card <%=grandPL >= 0 ? "profit" : "loss"%>">
        <div class="kpi-val <%=grandPL >= 0 ? "blue" : "red"%>">&#8377; <%=String.format("%.2f", Math.abs(grandPL))%></div>
        <div class="kpi-lbl">Net <%=grandPL >= 0 ? "Profit" : "Loss"%> (Expected)</div>
    </div>
    <div class="kpi-card <%=grandPLR >= 0 ? "profit" : "loss"%>">
        <div class="kpi-val <%=grandPLR >= 0 ? "blue" : "red"%>">&#8377; <%=String.format("%.2f", Math.abs(grandPLR))%></div>
        <div class="kpi-lbl">Net <%=grandPLR >= 0 ? "Profit" : "Loss"%> (Received)</div>
    </div>
</div>

<% if (data.isEmpty()) { %>
<p style="color:#888; font-size:12px; padding:10px;">No data found for FY <%=selFy%>-<%=selFy+1%>.</p>
<% } else { %>

<p class="note-row no-print">
    <b>Expenditure</b> = total labor cost assigned to employees for that site &amp; crop. &nbsp;
    <b>Income Expected</b> = total sale value. &nbsp;
    <b>Income Received</b> = actual payments collected. &nbsp;
    <b>P&amp;L</b> = Income &minus; Expenditure.
</p>

<div style="overflow-x:auto;">
<table id="plTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th width="4%">#</th>
        <th>Site</th>
        <th>Crop</th>
        <th width="12%">Expenditure (Rs)</th>
        <th width="13%">Income Expected (Rs)</th>
        <th width="13%">Income Received (Rs)</th>
        <th width="12%">P&amp;L Expected (Rs)</th>
        <th width="12%">P&amp;L Received (Rs)</th>
    </tr>
    </thead>
    <tbody>
<%
    int rowNum = 0;
    double gExp2 = 0, gInc2 = 0, gRec2 = 0;
    for (Map.Entry<Integer, Map<Integer, double[]>> siteEntry : data.entrySet()) {
        int siteId2 = siteEntry.getKey();
        String sn2  = siteNames.containsKey(siteId2) ? siteNames.get(siteId2) : "Site #" + siteId2;
        Map<Integer, double[]> cropMap = siteEntry.getValue();

        double siteExp = 0, siteInc = 0, siteRec = 0;
        for (double[] v : cropMap.values()) { siteExp += v[0]; siteInc += v[1]; siteRec += v[2]; }
        double sitePL  = siteInc - siteExp;
        double sitePLR = siteRec - siteExp;
        gExp2 += siteExp; gInc2 += siteInc; gRec2 += siteRec;

        String sitePlClass  = sitePL  >= 0 ? "pl-profit" : "pl-loss";
        String sitePlRClass = sitePLR >= 0 ? "pl-profit" : "pl-loss";
        String sitePlLabel  = sitePL  >= 0 ? "Profit" : "Loss";
        String sitePlRLabel = sitePLR >= 0 ? "Profit" : "Loss";
%>
    <!-- Site header -->
    <tr class="row-site-hdr">
        <td colspan="3"><b>&#127807; <%=sn2%></b></td>
        <td style="text-align:right;"><%=String.format("%.2f", siteExp)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", siteInc)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", siteRec)%></td>
        <td style="text-align:right;" class="<%=sitePlClass%>">
            <%=sitePlLabel%>: <%=String.format("%.2f", Math.abs(sitePL))%>
        </td>
        <td style="text-align:right;" class="<%=sitePlRClass%>">
            <%=sitePlRLabel%>: <%=String.format("%.2f", Math.abs(sitePLR))%>
        </td>
    </tr>
<%
        for (Map.Entry<Integer, double[]> cropEntry : cropMap.entrySet()) {
            int cropId2 = cropEntry.getKey();
            String cn2  = cropNames.containsKey(cropId2) ? cropNames.get(cropId2) : "Crop #" + cropId2;
            double[] v  = cropEntry.getValue();
            double pl   = v[1] - v[0];
            double plr  = v[2] - v[0];
            String plClass  = pl  >= 0 ? "pl-profit" : "pl-loss";
            String plrClass = plr >= 0 ? "pl-profit" : "pl-loss";
            rowNum++;
%>
    <tr class="row-crop">
        <td style="padding-left:20px;"><%=rowNum%></td>
        <td style="padding-left:20px; color:#555;"><%=sn2%></td>
        <td><%=cn2%></td>
        <td style="text-align:right;"><%=String.format("%.2f", v[0])%></td>
        <td style="text-align:right;"><%=String.format("%.2f", v[1])%></td>
        <td style="text-align:right;"><%=String.format("%.2f", v[2])%></td>
        <td style="text-align:right;" class="<%=plClass%>"><%=String.format("%.2f", pl)%></td>
        <td style="text-align:right;" class="<%=plrClass%>"><%=String.format("%.2f", plr)%></td>
    </tr>
<%      } %>
<%  } %>
    </tbody>
    <tfoot>
    <tr class="row-grandtotal">
        <td colspan="3" style="text-align:right;">Grand Total &mdash; FY <%=selFy%>-<%=selFy+1%></td>
        <td style="text-align:right;"><%=String.format("%.2f", grandExp)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", grandInc)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", grandRec)%></td>
        <% double gPL = grandInc - grandExp; double gPLR = grandRec - grandExp; %>
        <td style="text-align:right;" class="<%=gPL  >= 0 ? "pl-profit" : "pl-loss"%>"><%=String.format("%.2f", gPL)%></td>
        <td style="text-align:right;" class="<%=gPLR >= 0 ? "pl-profit" : "pl-loss"%>"><%=String.format("%.2f", gPLR)%></td>
    </tr>
    </tfoot>
</table>
</div>

<% } %>
</fieldset>

<%@include file="../../footer.jsp" %>
</body>
</html>
