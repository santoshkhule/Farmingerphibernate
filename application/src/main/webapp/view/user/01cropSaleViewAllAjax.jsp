<%@page import="com.san.farm.adminuser.dao.CropSaleDao"%>
<%@page import="com.san.farm.adminuser.dao.SalePaymentDao"%>
<%@page import="com.san.farm.adminuser.entity.CropSaleEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    String fromDateParam = request.getParameter("fromDate");
    String siteIdParam   = request.getParameter("siteId");
    String cropIdParam   = request.getParameter("cropId");
    String buyerIdParam  = request.getParameter("buyerId");

    String filterDate = null;
    int    filterSite = 0;
    int    filterCrop = 0;
    int    filterBuyer = 0;

    if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
        filterDate = FarmUtility.convertfrom_ddmmyyToyymmdd(fromDateParam.trim());
    }
    if (siteIdParam != null && !siteIdParam.trim().isEmpty() && !"-1".equals(siteIdParam.trim())) {
        try { filterSite = Integer.parseInt(siteIdParam.trim()); } catch (Exception e) {}
    }
    if (cropIdParam != null && !cropIdParam.trim().isEmpty() && !"-1".equals(cropIdParam.trim())) {
        try { filterCrop = Integer.parseInt(cropIdParam.trim()); } catch (Exception e) {}
    }
    if (buyerIdParam != null && !buyerIdParam.trim().isEmpty() && !"-1".equals(buyerIdParam.trim())) {
        try { filterBuyer = Integer.parseInt(buyerIdParam.trim()); } catch (Exception e) {}
    }

    CropSaleDao cropSaleDao     = new CropSaleDao();
    SalePaymentDao paymentDao   = new SalePaymentDao();
    List<CropSaleEntity> allSales = new ArrayList<CropSaleEntity>();
    try {
        allSales = cropSaleDao.getAll();
    } catch (Exception ex) { ex.printStackTrace(); }

    double ttlTotal = 0, ttlReceived = 0, ttlBalance = 0;
%>
<style>
    .sp-pill { display:inline-block; padding:2px 8px; border-radius:8px; font-size:10px; font-weight:700; white-space:nowrap; }
    .sp-paid    { background:#e8f5e9; color:#1b5e20; }
    .sp-partial { background:#fff8e1; color:#e65100; }
    .sp-unpaid  { background:#fdecea; color:#b71c1c; }
    .btn-select { background:var(--green-lt,#e8f5e9); border:1px solid var(--green-bd,#a5d6a7);
        color:var(--green-dk,#1b5e20); padding:2px 10px; cursor:pointer;
        border-radius:3px; font-size:11px; font-family:inherit; }
    .btn-select:hover { background:#c8e6c9; }
</style>
<table border="1" cellspacing="0" width="100%" class="tbl-data" id="cropSaleTable">
    <thead>
    <tr>
        <th width="6%">Select</th>
        <th width="4%">#</th>
        <th width="9%">Sale Date</th>
        <th>Site</th>
        <th>Crop</th>
        <th>Buyer</th>
        <th width="8%">Type</th>
        <th width="11%">Qty &amp; Unit</th>
        <th width="9%">Price/Unit</th>
        <th width="9%">Total</th>
        <th width="9%">Received</th>
        <th width="9%">Balance</th>
        <th width="8%">Status</th>
    </tr>
    </thead>
    <tbody>
<%
    int cnt = 0;
    for (CropSaleEntity cs : allSales) {
        if (cs == null) continue;

        // Apply filters
        if (filterDate != null) {
            if (cs.getSaleDate() == null || !cs.getSaleDate().toString().equals(filterDate)) continue;
        }
        if (filterSite > 0) {
            if (cs.getAssignCropToSiteEntity() == null
                    || cs.getAssignCropToSiteEntity().getSiteInformationEntity() == null
                    || cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteInfoId() != filterSite) continue;
        }
        if (filterCrop > 0) {
            if (cs.getCropEntity() == null || cs.getCropEntity().getCropId() != filterCrop) continue;
        }
        if (filterBuyer > 0) {
            if (cs.getBuyerEntity() == null || cs.getBuyerEntity().getBuyerId() != filterBuyer) continue;
        }

        cnt++;
        String siteName = "";
        if (cs.getAssignCropToSiteEntity() != null
                && cs.getAssignCropToSiteEntity().getSiteInformationEntity() != null
                && cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName() != null) {
            siteName = cs.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName();
        }
        String cropName   = cs.getCropEntity()  != null && cs.getCropEntity().getCropName() != null  ? cs.getCropEntity().getCropName()  : "";
        String buyerName  = cs.getBuyerEntity() != null && cs.getBuyerEntity().getBuyerName() != null ? cs.getBuyerEntity().getBuyerName() : "";
        String buyerType  = cs.getBuyerEntity() != null && cs.getBuyerEntity().getBuyerType() != null ? cs.getBuyerEntity().getBuyerType() : "";
        String saleDateDisp = cs.getSaleDate() != null ? FarmUtility.convertfrom_yymmddToddmmyy(cs.getSaleDate().toString()) : "";
        String unit       = cs.getUnit() != null ? cs.getUnit() : "";

        double received = paymentDao.getTotalReceivedBySaleId(cs.getSaleId());
        double balance  = cs.getTotalAmount() - received;
        if (balance < 0) balance = 0;
        ttlTotal    += cs.getTotalAmount();
        ttlReceived += received;
        ttlBalance  += balance;

        String statusClass, statusLabel;
        if (received <= 0) {
            statusClass = "sp-unpaid"; statusLabel = "Unpaid";
        } else if (received >= cs.getTotalAmount()) {
            statusClass = "sp-paid"; statusLabel = "Paid";
        } else {
            statusClass = "sp-partial"; statusLabel = "Partial";
        }

        String typeClass = "B2B".equals(buyerType) ? "buyer-b2b" : "buyer-local";
%>
    <tr>
        <td style="text-align:center;">
            <button type="button" class="btn-select" onclick="processSale(<%=cs.getSaleId()%>)">Select</button>
        </td>
        <td><%=cnt%></td>
        <td><%=saleDateDisp%></td>
        <td><%=siteName%></td>
        <td><%=cropName%></td>
        <td><%=buyerName%></td>
        <td style="text-align:center;">
            <span class="sp-pill <%="B2B".equals(buyerType) ? "sp-paid" : "sp-partial"%>" style="<%="B2B".equals(buyerType) ? "background:#e3f2fd;color:#0d47a1;" : "background:#f3e5f5;color:#6a1b9a;"%>"><%=buyerType%></span>
        </td>
        <td style="text-align:right;"><%=String.format("%.2f", cs.getQuantity())%> <%=unit%></td>
        <td style="text-align:right;"><%=String.format("%.2f", cs.getPricePerUnit())%></td>
        <td style="text-align:right; font-weight:600;"><%=String.format("%.2f", cs.getTotalAmount())%></td>
        <td style="text-align:right; color:#2e7d32; font-weight:600;"><%=String.format("%.2f", received)%></td>
        <td style="text-align:right; color:<%=balance > 0 ? "#c62828" : "#2e7d32"%>; font-weight:600;"><%=String.format("%.2f", balance)%></td>
        <td style="text-align:center;"><span class="sp-pill <%=statusClass%>"><%=statusLabel%></span></td>
    </tr>
<%
    }
%>
    </tbody>
    <tfoot>
    <tr>
        <td colspan="9" style="font-weight:bold; text-align:right;">Total</td>
        <td style="text-align:right; font-weight:bold;"><%=String.format("%.2f", ttlTotal)%></td>
        <td style="text-align:right; font-weight:bold; color:#2e7d32;"><%=String.format("%.2f", ttlReceived)%></td>
        <td style="text-align:right; font-weight:bold; color:#c62828;"><%=String.format("%.2f", ttlBalance)%></td>
        <td></td>
    </tr>
    </tfoot>
</table>
