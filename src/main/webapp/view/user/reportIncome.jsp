<%@page import="com.san.farm.adminuser.dao.CropSaleDao"%>
<%@page import="com.san.farm.adminuser.dao.SalePaymentDao"%>
<%@page import="com.san.farm.adminuser.entity.CropSaleEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    // Determine current FY start year
    Calendar cal = Calendar.getInstance();
    int currentYear  = cal.get(Calendar.YEAR);
    int currentMonth = cal.get(Calendar.MONTH) + 1; // 1-based
    int currentFyStart = (currentMonth >= 4) ? currentYear : currentYear - 1;

    // Selected FY from filter (default: current FY)
    int selectedFyStart = currentFyStart;
    String fyParam = request.getParameter("fyYear");
    if (fyParam != null && !fyParam.trim().isEmpty()) {
        try { selectedFyStart = Integer.parseInt(fyParam.trim()); } catch (Exception e) {}
    }

    String fyFromDate = selectedFyStart + "-04-01";
    String fyToDate   = (selectedFyStart + 1) + "-03-31";

    // Fetch all sales and filter by FY
    CropSaleDao cropSaleDao   = new CropSaleDao();
    SalePaymentDao paymentDao = new SalePaymentDao();
    List<CropSaleEntity> allSales = new ArrayList<CropSaleEntity>();
    try {
        allSales = cropSaleDao.getAll();
    } catch (Exception ex) { ex.printStackTrace(); }

    // Build filtered list
    List<CropSaleEntity> fySales = new ArrayList<CropSaleEntity>();
    java.sql.Date fyFrom = java.sql.Date.valueOf(fyFromDate);
    java.sql.Date fyTo   = java.sql.Date.valueOf(fyToDate);
    for (CropSaleEntity cs : allSales) {
        if (cs == null || cs.getSaleDate() == null) continue;
        if (!cs.getSaleDate().before(fyFrom) && !cs.getSaleDate().after(fyTo)) {
            fySales.add(cs);
        }
    }

    // Group by site for subtotals
    // Key: siteInfoId, Value: list of sales
    Map<String, List<CropSaleEntity>> bySite = new LinkedHashMap<String, List<CropSaleEntity>>();
    Map<String, String> siteNameMap = new LinkedHashMap<String, String>();
    for (CropSaleEntity cs : fySales) {
        String siteKey = "0";
        String sn = "(No Site)";
        if (cs.getAssignCropToSiteEntity() != null
                && cs.getAssignCropToSiteEntity().getSiteInformationEntity() != null) {
            int sid = cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteInfoId();
            siteKey = String.valueOf(sid);
            if (cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName() != null)
                sn = cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName();
        }
        if (!bySite.containsKey(siteKey)) {
            bySite.put(siteKey, new ArrayList<CropSaleEntity>());
            siteNameMap.put(siteKey, sn);
        }
        bySite.get(siteKey).add(cs);
    }

    double grandTotal = 0, grandReceived = 0, grandBalance = 0;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= msg.getString("report.income.page_title") %></title>
<link rel="stylesheet" href="../../css/style.css">
<script src="../../js/jquery-1.9.1.js"></script>
<style>
    .filter-bar {
        display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        background: #f1f8e9; border: 1px solid var(--green-bd, #a5d6a7);
        border-radius: var(--r-md, 6px); padding: 12px 16px; margin-bottom: 12px;
    }
    .filter-group { display: flex; flex-direction: column; gap: 4px; }
    .filter-group label { font-size: 11px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .4px; color: var(--text-muted, #666); }
    .filter-group select { border: 1px solid #ccc; border-radius: var(--r-sm, 3px);
        padding: 6px 10px; font-size: 13px; min-width: 160px; }
    .filter-group select:focus { outline: none; border-color: var(--green-dk); }
    .filter-actions { display: flex; gap: 8px; align-items: flex-end; margin-left: auto; }

    .section-title {
        font-weight: 700; color: var(--green-dk); font-size: 0.95em;
        border-bottom: 2px solid var(--green-bd, #a5d6a7);
        padding-bottom: 4px; margin: 14px 0 8px;
        display: flex; align-items: center; justify-content: space-between;
    }
    .site-header-row td {
        background: #e8f5e9; font-weight: 700; color: #1b5e20;
        font-size: 12px; padding: 6px 8px;
    }
    .site-subtotal-row td {
        background: #f9fbe7; font-weight: 700; font-style: italic;
        font-size: 12px; border-top: 2px solid #a5d6a7;
    }
    .grand-total-row td {
        background: var(--green-row, #e8f5e9); font-weight: 700;
        font-size: 12px; border-top: 3px solid var(--green-bd);
    }
    .sp-pill { display: inline-block; padding: 2px 8px; border-radius: 8px; font-size: 10px; font-weight: 700; }
    .sp-paid    { background: #e8f5e9; color: #1b5e20; }
    .sp-partial { background: #fff8e1; color: #e65100; }
    .sp-unpaid  { background: #fdecea; color: #b71c1c; }
</style>
<script>
    function exportCSV() {
        var rows = [['Site', 'Crop', 'Sale Date', 'Buyer', 'Buyer Type', 'Qty', 'Unit', 'Price/Unit', 'Total Sale', 'Received', 'Balance', 'Status']];
        $('#incomeTable tbody tr').not('.site-header-row').not('.site-subtotal-row').each(function() {
            var cols = [];
            $(this).find('td').each(function() { cols.push($(this).text().trim()); });
            if (cols.length > 0) rows.push(cols);
        });
        var csv = rows.map(function(r) {
            return r.map(function(v) {
                v = v.replace(/"/g, '""');
                return (v.indexOf(',') !== -1 || v.indexOf('"') !== -1) ? '"' + v + '"' : v;
            }).join(',');
        }).join('\r\n');
        var blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8' });
        var url  = URL.createObjectURL(blob);
        var a    = document.createElement('a');
        a.href   = url; a.download = 'IncomeReport.csv';
        document.body.appendChild(a); a.click();
        document.body.removeChild(a); URL.revokeObjectURL(url);
    }
</script>
</head>
<body>

<fieldset>
<legend><%= msg.getString("report.income.fieldset_title") %></legend>

<!-- Filter bar -->
<form method="get" id="frmFilter">
<div class="filter-bar">
    <div class="filter-group">
        <label for="fyYear"><%= msg.getString("report.income.filter_label_fy") %></label>
        <select name="fyYear" id="fyYear" onchange="this.form.submit()">
            <%
                for (int y = currentFyStart; y >= currentFyStart - 3; y--) {
                    String label = "FY " + y + "-" + (y + 1);
            %>
            <option value="<%=y%>"<%=y == selectedFyStart ? " selected" : ""%>><%=label%></option>
            <% } %>
        </select>
    </div>
    <div class="filter-actions">
        <button type="button" class="btn-add" onclick="exportCSV()">&#8595; <%= msg.getString("btn.download_csv") %></button>
    </div>
</div>
</form>

<div class="section-title">
    <span>Sales &amp; Income &mdash; FY <%=selectedFyStart%>-<%=(selectedFyStart+1)%></span>
</div>

<% if (fySales.isEmpty()) { %>
<p style="color:#888; font-size:12px; padding:10px;">No sales records found for FY <%=selectedFyStart%>-<%=(selectedFyStart+1)%>.</p>
<% } else { %>

<div style="overflow-x:auto;">
<table id="incomeTable" border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th width="4%">#</th>
        <th><%= msg.getString("report.income.tbl_col_site") %></th>
        <th><%= msg.getString("report.income.tbl_col_crop") %></th>
        <th width="9%"><%= msg.getString("report.income.tbl_col_sale_date") %></th>
        <th><%= msg.getString("report.income.tbl_col_buyer") %></th>
        <th width="8%"><%= msg.getString("report.income.tbl_col_buyer_type") %></th>
        <th width="7%"><%= msg.getString("report.income.tbl_col_qty") %></th>
        <th width="6%"><%= msg.getString("tbl.col_unit") %></th>
        <th width="8%"><%= msg.getString("report.income.tbl_col_price_per_unit") %></th>
        <th width="9%"><%= msg.getString("report.income.tbl_col_total_sale") %></th>
        <th width="9%"><%= msg.getString("report.income.tbl_col_received") %></th>
        <th width="9%"><%= msg.getString("report.income.tbl_col_balance") %></th>
        <th width="8%"><%= msg.getString("tbl.col_status") %></th>
    </tr>
    </thead>
    <tbody>
<%
    int rowCnt = 0;
    for (Map.Entry<String, List<CropSaleEntity>> entry : bySite.entrySet()) {
        String siteKey = entry.getKey();
        String sn = siteNameMap.get(siteKey);
        List<CropSaleEntity> siteSales = entry.getValue();
        double siteTotal = 0, siteReceived = 0, siteBalance = 0;
%>
    <tr class="site-header-row">
        <td colspan="13">Site: <%=sn%></td>
    </tr>
<%
        for (CropSaleEntity cs : siteSales) {
            if (cs == null) continue;
            rowCnt++;
            String cropName  = cs.getCropEntity()  != null && cs.getCropEntity().getCropName() != null  ? cs.getCropEntity().getCropName()  : "";
            String buyerName = cs.getBuyerEntity() != null && cs.getBuyerEntity().getBuyerName() != null ? cs.getBuyerEntity().getBuyerName() : "";
            String buyerType = cs.getBuyerEntity() != null && cs.getBuyerEntity().getBuyerType() != null ? cs.getBuyerEntity().getBuyerType() : "";
            String saleDateD = cs.getSaleDate() != null ? FarmUtility.convertfrom_yymmddToddmmyy(cs.getSaleDate().toString()) : "";
            String unit      = cs.getUnit() != null ? cs.getUnit() : "";

            double received = paymentDao.getTotalReceivedBySaleId(cs.getSaleId());
            double bal      = cs.getTotalAmount() - received;
            if (bal < 0) bal = 0;
            siteTotal    += cs.getTotalAmount();
            siteReceived += received;
            siteBalance  += bal;

            String statusClass, statusLabel;
            if (received <= 0) {
                statusClass = "sp-unpaid"; statusLabel = msg.getString("report.income.status_unpaid");
            } else if (received >= cs.getTotalAmount()) {
                statusClass = "sp-paid"; statusLabel = msg.getString("report.income.status_paid");
            } else {
                statusClass = "sp-partial"; statusLabel = msg.getString("report.income.status_partial");
            }
%>
    <tr>
        <td><%=rowCnt%></td>
        <td><%=sn%></td>
        <td><%=cropName%></td>
        <td><%=saleDateD%></td>
        <td><%=buyerName%></td>
        <td style="text-align:center;"><%=buyerType%></td>
        <td style="text-align:right;"><%=String.format("%.2f", cs.getQuantity())%></td>
        <td><%=unit%></td>
        <td style="text-align:right;"><%=String.format("%.2f", cs.getPricePerUnit())%></td>
        <td style="text-align:right; font-weight:600;"><%=String.format("%.2f", cs.getTotalAmount())%></td>
        <td style="text-align:right; color:#2e7d32; font-weight:600;"><%=String.format("%.2f", received)%></td>
        <td style="text-align:right; color:<%=bal > 0 ? "#c62828" : "#2e7d32"%>; font-weight:600;"><%=String.format("%.2f", bal)%></td>
        <td style="text-align:center;"><span class="sp-pill <%=statusClass%>"><%=statusLabel%></span></td>
    </tr>
<%
        }
        grandTotal    += siteTotal;
        grandReceived += siteReceived;
        grandBalance  += siteBalance;
%>
    <tr class="site-subtotal-row">
        <td colspan="9" style="text-align:right;">Subtotal &mdash; <%=sn%></td>
        <td style="text-align:right;"><%=String.format("%.2f", siteTotal)%></td>
        <td style="text-align:right; color:#2e7d32;"><%=String.format("%.2f", siteReceived)%></td>
        <td style="text-align:right; color:#c62828;"><%=String.format("%.2f", siteBalance)%></td>
        <td></td>
    </tr>
<%
    }
%>
    </tbody>
    <tfoot>
    <tr class="grand-total-row">
        <td colspan="9" style="text-align:right;"><%= msg.getString("report.income.grand_total") %></td>
        <td style="text-align:right;"><%=String.format("%.2f", grandTotal)%></td>
        <td style="text-align:right; color:#2e7d32;"><%=String.format("%.2f", grandReceived)%></td>
        <td style="text-align:right; color:#c62828;"><%=String.format("%.2f", grandBalance)%></td>
        <td></td>
    </tr>
    </tfoot>
</table>
</div>

<% } %>

</fieldset>

<%@include file="../../footer.jsp" %>
</body>
</html>
