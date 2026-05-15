<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="com.san.farm.adminuser.dao.BuyerService"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteRefEntity"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@page import="com.san.farm.adminuser.dao.CropSaleDao"%>
<%@page import="com.san.farm.adminuser.dao.SalePaymentDao"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="com.san.farm.adminuser.entity.BuyerEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="com.san.farm.adminuser.entity.CropSaleEntity"%>
<%@page import="com.san.farm.adminuser.entity.SalePaymentEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    int saleId = 0;
    String saleIdParam = request.getParameter("saleId");
    if (saleIdParam != null && !saleIdParam.trim().isEmpty()) {
        try { saleId = Integer.parseInt(saleIdParam.trim()); } catch (Exception e) {}
    }
    boolean hasSelection = saleId > 0;

    CropSaleEntity selectedSale = null;
    List<SalePaymentEntity> payments = new ArrayList<SalePaymentEntity>();
    double totalSale = 0, totalReceived = 0, balance = 0;
    String siteName = "", cropName = "", buyerName = "", buyerType = "", saleDateDisp = "";
    String saleUnit = "", saleQty = "", salePrice = "", saleTotalDisp = "";
    String saleComment = "";

    if (hasSelection) {
        try {
            CropSaleDao cropSaleDao   = new CropSaleDao();
            SalePaymentDao paymentDao = new SalePaymentDao();
            selectedSale = cropSaleDao.getById(saleId);
            if (selectedSale != null) {
                payments      = paymentDao.getAllBySaleId(saleId);
                totalSale     = selectedSale.getTotalAmount();
                totalReceived = paymentDao.getTotalReceivedBySaleId(saleId);
                balance       = totalSale - totalReceived;
                if (balance < 0) balance = 0;
                if (selectedSale.getAssignCropToSiteEntity() != null
                        && selectedSale.getAssignCropToSiteEntity().getSiteInformationEntity() != null
                        && selectedSale.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName() != null) {
                    siteName = selectedSale.getAssignCropToSiteEntity().getSiteInformationEntity().getSiteName();
                }
                if (selectedSale.getCropEntity() != null && selectedSale.getCropEntity().getCropName() != null)
                    cropName = selectedSale.getCropEntity().getCropName();
                if (selectedSale.getBuyerEntity() != null) {
                    if (selectedSale.getBuyerEntity().getBuyerName() != null)
                        buyerName = selectedSale.getBuyerEntity().getBuyerName();
                    if (selectedSale.getBuyerEntity().getBuyerType() != null)
                        buyerType = selectedSale.getBuyerEntity().getBuyerType();
                }
                if (selectedSale.getSaleDate() != null)
                    saleDateDisp = FarmUtility.convertfrom_yymmddToddmmyy(selectedSale.getSaleDate().toString());
                saleUnit      = selectedSale.getUnit()        != null ? selectedSale.getUnit()                             : "";
                saleQty       = String.format("%.2f",           selectedSale.getQuantity());
                salePrice     = String.format("%.2f",           selectedSale.getPricePerUnit());
                saleTotalDisp = String.format("%.2f",           selectedSale.getTotalAmount());
                saleComment   = selectedSale.getComment()     != null ? selectedSale.getComment()                          : "";
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    int selAssignCroptoSiteId = (selectedSale != null && selectedSale.getAssignCropToSiteEntity() != null)
            ? selectedSale.getAssignCropToSiteEntity().getAssignCroptoSiteId() : 0;
    int selCropId  = (selectedSale != null && selectedSale.getCropEntity()  != null) ? selectedSale.getCropEntity().getCropId()   : 0;
    int selBuyerId = (selectedSale != null && selectedSale.getBuyerEntity() != null) ? selectedSale.getBuyerEntity().getBuyerId() : 0;

    List<AssignCropToSiteEntity>      readyToDispatchList = new ArrayList<AssignCropToSiteEntity>();
    List<ConfigSiteInformationEntity> siteInfoList        = new ArrayList<ConfigSiteInformationEntity>();
    List<ConfigCropEntity>            cropList            = new ArrayList<ConfigCropEntity>();
    List<BuyerEntity>                 buyerList           = new ArrayList<BuyerEntity>();
    try {
        AssignCropToSiteService assignSvc = new AssignCropToSiteService();
        readyToDispatchList = assignSvc.getReadyToDispatch();
        siteInfoList        = new ConfigSiteInformationService().fetch();
        cropList            = new ConfigCropService().fetch();
        buyerList           = new BuyerService().getAll();
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Crop Sale Processing</title>
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/jquery-ui.js"></script>
<style>
    /* ── Sale entry / edit form card ─────────────────────────── */
    .sale-form-card {
        background:#f1f8e9; border:1.5px solid var(--green-bd);
        border-radius:6px; padding:14px 18px; margin-bottom:14px;
    }
    .sale-form-hdr {
        display:flex; align-items:center; justify-content:space-between;
        padding-bottom:8px; margin-bottom:12px; border-bottom:1px solid var(--green-bd);
    }
    .sale-form-title { font-size:13px; font-weight:700; color:var(--green-dk); }
    .sale-form-ctx {
        font-size:11px; color:#5d4037; margin-left:8px;
        padding:2px 8px; background:#fff; border:1px solid #a5d6a7;
        border-radius:8px;
    }
    .sale-form-close {
        background:none; border:1px solid #bdbdbd; border-radius:3px;
        cursor:pointer; font-size:13px; color:#616161; padding:2px 8px; line-height:1.4;
        transition:background .12s, border-color .12s;
    }
    .sale-form-close:hover { background:#fdecea; border-color:#ef9a9a; color:#b71c1c; }

    .sale-form-grid {
        display:grid; grid-template-columns:repeat(3,1fr); gap:10px 18px; align-items:end;
    }
    .sfg-field { display:flex; flex-direction:column; gap:3px; }
    .sfg-field label { font-size:11px; font-weight:600; color:#424242; }
    .sfg-field input[type=text], .sfg-field select {
        padding:5px 8px; border:1px solid #bdbdbd; border-radius:3px;
        font-size:12px; font-family:inherit; outline:none; width:100%;
        box-sizing:border-box; transition:border-color .15s, box-shadow .15s;
    }
    .sfg-field input:focus, .sfg-field select:focus {
        border-color:var(--green-md); box-shadow:0 0 0 2px rgba(56,142,60,.12);
    }
    .sfg-field input[readonly] { background:#f5f5f5; color:#616161; cursor:default; }
    .sfg-full { grid-column:1 / -1; }
    .sfg-btns { grid-column:1 / -1; display:flex; gap:8px; margin-top:4px; }

    /* ── Dispatch chips ──────────────────────────────────────── */
    .dispatch-bar {
        display:flex; flex-wrap:wrap; align-items:center; gap:6px 8px;
        padding:7px 12px; background:#fff8e1; border:1px solid #ffe082;
        border-radius:6px; margin-bottom:12px;
    }
    .dispatch-bar-lbl { font-size:11px; font-weight:700; color:#856404; white-space:nowrap; margin-right:4px; }
    .dispatch-chip {
        display:inline-flex; align-items:center; gap:4px; cursor:pointer;
        padding:3px 11px; border-radius:12px; font-size:11px; font-weight:600;
        background:#fff; border:1px solid #ffc107; color:#5d4037;
        transition:background .12s, box-shadow .12s;
    }
    .dispatch-chip:hover { background:#fff3cd; box-shadow:0 1px 5px rgba(0,0,0,.15); }

    /* ── Sale detail card ────────────────────────────────────── */
    .detail-card {
        background:#fff; border:1px solid var(--green-bd);
        border-radius:6px; margin-bottom:14px; overflow:hidden;
    }
    .detail-card-hdr {
        display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:6px;
        padding:9px 14px; background:var(--green-row); border-bottom:1px solid var(--green-bd);
    }
    .detail-card-title { font-size:13px; font-weight:700; color:var(--green-dk); }
    .detail-card-sub { font-size:11px; color:var(--green-md); margin-left:6px; font-weight:400; }
    .detail-card-actions { display:flex; gap:6px; flex-wrap:wrap; }
    .detail-card-body { padding:14px; }

    .info-strip {
        display:flex; flex-wrap:wrap; gap:6px 16px; margin-bottom:12px;
        padding:8px 12px; background:var(--gray-100);
        border-radius:var(--r-sm); border:1px solid var(--gray-200);
    }
    .info-chip { font-size:12px; color:var(--text); }
    .info-chip .lbl {
        font-size:10px; font-weight:700; color:var(--text-muted);
        text-transform:uppercase; letter-spacing:.4px; margin-right:4px;
    }

    .amt-bar { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:14px; }
    .amt-card {
        flex:1; min-width:90px; text-align:center; padding:10px 12px;
        border-radius:var(--r-md); background:var(--gray-50); border:1px solid var(--gray-200);
    }
    .amt-card .ac-lbl { font-size:10px; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:.4px; }
    .amt-card .ac-val { font-size:1.3em; font-weight:700; color:var(--green-dk); margin-top:3px; }
    .amt-card.received .ac-val { color:#2e7d32; }
    .amt-card.balance  { background:var(--blue-lt); border-color:var(--blue-bd); }
    .amt-card.balance  .ac-val { color:var(--blue-dk); }

    /* ── Payment section ─────────────────────────────────────── */
    .pay-section-hdr {
        display:flex; align-items:center; justify-content:space-between;
        font-size:12px; font-weight:700; color:var(--green-dk);
        margin:0 0 8px; padding-bottom:5px; border-bottom:1px solid var(--green-bd);
    }
    .pay-mode-badge {
        font-size:10px; padding:2px 9px; border-radius:8px; font-weight:700;
        background:var(--blue-lt); border:1px solid var(--blue-bd); color:var(--blue-dk);
    }
    .pay-form {
        background:var(--blue-lt); border:1px solid var(--blue-bd);
        border-radius:var(--r-md); padding:10px 14px; margin-bottom:12px;
    }
    .pay-row { display:flex; flex-wrap:wrap; gap:8px 14px; align-items:flex-end; }
    .pay-field { display:flex; flex-direction:column; gap:3px; }
    .pay-field label { font-size:11px; font-weight:600; color:var(--gray-800); }
    .pay-field select, .pay-field input[type=text] {
        padding:5px 8px; border:1px solid var(--gray-400); border-radius:var(--r-sm);
        font-size:12px; font-family:inherit; outline:none;
        transition:border-color .15s, box-shadow .15s;
    }
    .pay-field select:focus, .pay-field input:focus {
        border-color:var(--blue-md); box-shadow:0 0 0 2px rgba(25,118,210,.15);
    }
    .pay-btns { display:flex; gap:6px; align-items:flex-end; }

    /* ── Sales list section ──────────────────────────────────── */
    .list-hdr {
        display:flex; align-items:center; justify-content:space-between;
        margin-bottom:10px; padding-bottom:8px; border-bottom:1px solid var(--green-bd);
    }
    .list-hdr-title { font-size:13px; font-weight:700; color:var(--green-dk); }

    .filter-bar {
        display:flex; flex-wrap:wrap; gap:8px 12px; align-items:flex-end;
        padding:8px 12px; background:var(--gray-50); border:1px solid var(--gray-200);
        border-radius:6px; margin-bottom:10px;
    }
    .filter-field { display:flex; flex-direction:column; gap:3px; }
    .filter-field label { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; color:var(--text-muted); }
    .filter-field input, .filter-field select {
        padding:5px 8px; border:1px solid var(--gray-400); border-radius:var(--r-sm);
        font-size:12px; font-family:inherit; outline:none; width:130px;
        transition:border-color .15s;
    }
    .filter-field input:focus, .filter-field select:focus { border-color:var(--green-md); }

    #showTable { width:100%; overflow-x:auto; }
    .tbl-data td, .tbl-data th { vertical-align:middle; }
    .sp-pill { display:inline-block; padding:2px 8px; border-radius:8px; font-size:10px; font-weight:700; white-space:nowrap; }
</style>
</head>
<body>
<script type="text/javascript">
    var salePayments = {};

    /* ── Sale form ── */
    function showSaleForm() {
        var card = document.getElementById('saleFormCard');
        card.style.display = '';
        card.scrollIntoView({ behavior:'smooth', block:'nearest' });
    }

    function hideSaleForm() {
        document.getElementById('saleFormCard').style.display = 'none';
        resetSaleForm();
    }

    function editSale() {
        resetSaleForm();
        document.getElementById('editSaleId').value = <%=saleId%>;
        setSelectByNum('assignCroptoSiteId', <%=selAssignCroptoSiteId%>);
        setSelectByNum('cropId',             <%=selCropId%>);
        setSelectByNum('buyerId',            <%=selBuyerId%>);
        document.getElementById('saleQty').value      = '<%=saleQty%>';
        document.getElementById('saleUnit').value     = '<%=saleUnit%>';
        document.getElementById('salePrice').value    = '<%=salePrice%>';
        document.getElementById('saleTotalAmt').value = '<%=saleTotalDisp%>';
        document.getElementById('saleDate').value     = '<%=saleDateDisp%>';
        document.getElementById('saleComment').value  = '<%=saleComment.replace("'", "\\'")%>';

        document.getElementById('saleFormTitle').innerText = 'Edit Sale';
        var ctx = document.getElementById('saleFormCtx');
        ctx.innerText = '<%=siteName.replace("'","\\'")%> — <%=cropName.replace("'","\\'")%>';
        ctx.style.display = '';
        document.getElementById('btnRecordSale').style.display = 'none';
        document.getElementById('btnUpdateSale').style.display = '';
        document.getElementById('btnCancelSale').style.display = '';

        showSaleForm();
    }

    function resetSaleForm() {
        document.getElementById('editSaleId').value              = '';
        document.getElementById('assignCroptoSiteId').selectedIndex = 0;
        document.getElementById('cropId').selectedIndex          = 0;
        document.getElementById('buyerId').selectedIndex         = 0;
        document.getElementById('saleQty').value                 = '';
        document.getElementById('saleUnit').selectedIndex        = 0;
        document.getElementById('salePrice').value               = '';
        document.getElementById('saleTotalAmt').value            = '';
        document.getElementById('saleDate').value                = '';
        document.getElementById('saleComment').value             = '';
        document.getElementById('saleFormTitle').innerText       = 'New Sale';
        document.getElementById('saleFormCtx').style.display    = 'none';
        document.getElementById('btnRecordSale').style.display  = '';
        document.getElementById('btnUpdateSale').style.display  = 'none';
        document.getElementById('btnCancelSale').style.display  = 'none';
    }

    function quickSale(assignId) {
        resetSaleForm();
        showSaleForm();
        setSelectByNum('assignCroptoSiteId', assignId);
    }

    function setSelectByNum(id, numVal) {
        var sel = document.getElementById(id);
        for (var i = 0; i < sel.options.length; i++) {
            if (parseInt(sel.options[i].value) === parseInt(numVal)) { sel.selectedIndex = i; return; }
        }
    }

    function computeTotal() {
        var qty   = parseFloat(document.getElementById('saleQty').value)   || 0;
        var price = parseFloat(document.getElementById('salePrice').value) || 0;
        document.getElementById('saleTotalAmt').value = (qty * price).toFixed(2);
    }

    /* ── Payment form ── */
    function editPayment(id) {
        var d = salePayments[id];
        if (!d) return;
        document.getElementById('paymentMode').value    = d.paymentMode;
        document.getElementById('amountReceived').value = d.amountReceived;
        document.getElementById('paymentDate').value    = d.paymentDate;
        document.getElementById('referenceNo').value    = d.referenceNo;
        document.getElementById('payComment').value     = d.comment;
        document.getElementById('salePaymentId').value  = id;
        document.getElementById('payModeBadge').style.display = '';
        document.getElementById('sbtUpdatePayment').removeAttribute('hidden');
        document.getElementById('sbtAddPayment').setAttribute('hidden', 'true');
        document.getElementById('payFormPanel').scrollIntoView({ behavior:'smooth' });
    }

    function resetPayForm() {
        document.getElementById('paymentMode').value    = '';
        document.getElementById('amountReceived').value = '';
        document.getElementById('paymentDate').value    = '';
        document.getElementById('referenceNo').value    = '';
        document.getElementById('payComment').value     = '';
        document.getElementById('salePaymentId').value  = '';
        document.getElementById('payModeBadge').style.display = 'none';
        document.getElementById('sbtUpdatePayment').setAttribute('hidden', 'true');
        document.getElementById('sbtAddPayment').removeAttribute('hidden');
    }

    /* ── Sale list ── */
    function processSale(id) {
        window.location.href = 'cropSaleProcess.jsp?saleId=' + id;
    }

    function clearAllFilters() {
        document.getElementById('txtDate').value    = '';
        document.getElementById('selSiteId').value  = '-1';
        document.getElementById('selCropId').value  = '-1';
        document.getElementById('selBuyerId').value = '-1';
        loadSaleTable();
    }

    function loadSaleTable() {
        var fromDate = document.getElementById('txtDate').value;
        var siteId   = document.getElementById('selSiteId').value;
        var cropId   = document.getElementById('selCropId').value;
        var buyerId  = document.getElementById('selBuyerId').value;
        var xmlhttp  = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var tbl = $('#showTable table.tbl-data');
                if (tbl.length && $.fn.DataTable.isDataTable(tbl)) { tbl.DataTable().destroy(); }
                document.getElementById('showTable').innerHTML = xmlhttp.responseText;
                initSaleTable();
            }
        };
        xmlhttp.open('GET', '01cropSaleViewAllAjax.jsp'
            + '?fromDate=' + encodeURIComponent(fromDate)
            + '&siteId='   + encodeURIComponent(siteId)
            + '&cropId='   + encodeURIComponent(cropId)
            + '&buyerId='  + encodeURIComponent(buyerId), true);
        xmlhttp.send();
    }

    function initSaleTable() {
        var tbl = $('#showTable table.tbl-data');
        if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
            tbl.DataTable({
                pageLength: 10,
                lengthMenu: [[10,25,50,-1],[10,25,50,'All']],
                columnDefs: [{ orderable:false, targets:[0,12] }],
                dom: '<"dt-toolbar"lf>t<"dt-footer"ip>'
            });
        }
    }

    $(document).ready(function() {
        $('#txtDate').datepicker({ changeMonth:true, changeYear:true, dateFormat:'dd/mm/yy' });
        $('#paymentDate').datepicker({ changeMonth:true, changeYear:true, dateFormat:'dd/mm/yy' });
        $('#saleDate').datepicker({ changeMonth:true, changeYear:true, dateFormat:'dd/mm/yy' });
        loadSaleTable();
    });
</script>

<fieldset><legend>Crop Sale Processing</legend>

<!-- ① Sale Entry / Edit Form (hidden until triggered) -->
<div id="saleFormCard" class="sale-form-card" style="display:none;">
    <div class="sale-form-hdr">
        <div style="display:flex; align-items:center; flex-wrap:wrap; gap:6px;">
            <span class="sale-form-title" id="saleFormTitle">New Sale</span>
            <span class="sale-form-ctx" id="saleFormCtx" style="display:none;"></span>
        </div>
        <button type="button" class="sale-form-close" onclick="hideSaleForm()">&#x2715; Close</button>
    </div>
    <form method="post" action="../../CropSaleController">
        <input type="hidden" name="saleId" id="editSaleId" value="">
        <div class="sale-form-grid">

            <div class="sfg-field">
                <label for="assignCroptoSiteId">Site Allocation *</label>
                <select name="assignCroptoSiteId" id="assignCroptoSiteId" required>
                    <option value="">--- Select Site ---</option>
                    <%
                        for (AssignCropToSiteEntity s : readyToDispatchList) {
                            if (s == null) continue;
                            String sn = (s.getSiteInformationEntity() != null && s.getSiteInformationEntity().getSiteName() != null)
                                ? s.getSiteInformationEntity().getSiteName() : "Site #" + s.getAssignCroptoSiteId();
                            String sd = s.getCropAssignDate() != null
                                ? FarmUtility.convertfrom_yymmddToddmmyy(s.getCropAssignDate().toString()) : "";
                    %>
                    <option value="<%=s.getAssignCroptoSiteId()%>"><%=sn%><%=sd.isEmpty() ? "" : " (" + sd + ")"%></option>
                    <% } %>
                </select>
            </div>

            <div class="sfg-field">
                <label for="cropId">Crop *</label>
                <select name="cropId" id="cropId" required>
                    <option value="">--- Select Crop ---</option>
                    <%
                        for (ConfigCropEntity cr : cropList) {
                            if (cr == null) continue;
                    %>
                    <option value="<%=cr.getCropId()%>"><%=cr.getCropName() != null ? cr.getCropName() : ""%></option>
                    <% } %>
                </select>
            </div>

            <div class="sfg-field">
                <label for="buyerId">Buyer *</label>
                <select name="buyerId" id="buyerId" required>
                    <option value="">--- Select Buyer ---</option>
                    <%
                        for (BuyerEntity b : buyerList) {
                            if (b == null) continue;
                    %>
                    <option value="<%=b.getBuyerId()%>"><%=(b.getBuyerName() != null ? b.getBuyerName() : "")%><%=(b.getBuyerType() != null ? " [" + b.getBuyerType() + "]" : "")%></option>
                    <% } %>
                </select>
            </div>

            <div class="sfg-field">
                <label for="saleQty">Quantity *</label>
                <input type="text" name="quantity" id="saleQty" required
                       pattern="[0-9]+(\.[0-9]*)?" oninput="computeTotal()">
            </div>

            <div class="sfg-field">
                <label for="saleUnit">Unit *</label>
                <select name="unit" id="saleUnit" required>
                    <option value="">-- Select --</option>
                    <option value="Kg">Kg</option>
                    <option value="Quintal">Quintal</option>
                    <option value="Ton">Ton</option>
                </select>
            </div>

            <div class="sfg-field">
                <label for="salePrice">Price / Unit *</label>
                <input type="text" name="pricePerUnit" id="salePrice" required
                       pattern="[0-9]+(\.[0-9]*)?" oninput="computeTotal()">
            </div>

            <div class="sfg-field">
                <label for="saleTotalAmt">Total Amount</label>
                <input type="text" name="totalAmount" id="saleTotalAmt" readonly>
            </div>

            <div class="sfg-field">
                <label for="saleDate">Sale Date *</label>
                <input type="text" name="saleDate" id="saleDate" required placeholder="dd/mm/yyyy">
            </div>

            <div class="sfg-field">
                <label for="saleComment">Comment</label>
                <input type="text" name="comment" id="saleComment" placeholder="Optional">
            </div>

            <div class="sfg-btns">
                <input type="submit" class="btn-add"    id="btnRecordSale" name="add"  value="Record Sale">
                <input type="submit" class="btn-update" id="btnUpdateSale" name="edit" value="Update Sale"
                       style="display:none">
                <input type="button" class="btn-cancel" id="btnCancelSale" value="Cancel"
                       style="display:none" onclick="hideSaleForm()">
            </div>
        </div>
    </form>
</div>

<!-- ② Ready to Dispatch bar (compact chips — only when items exist) -->
<% if (!readyToDispatchList.isEmpty()) { %>
<div class="dispatch-bar">
    <span class="dispatch-bar-lbl">&#128666; Ready to Dispatch:</span>
    <%
        for (AssignCropToSiteEntity rd : readyToDispatchList) {
            if (rd == null) continue;
            String rdSite = (rd.getSiteInformationEntity() != null && rd.getSiteInformationEntity().getSiteName() != null)
                    ? rd.getSiteInformationEntity().getSiteName() : "Site #" + rd.getAssignCroptoSiteId();
            StringBuilder rdCrops = new StringBuilder();
            if (rd.getCropToSiteRefEntity() != null) {
                for (AssignCropToSiteRefEntity ref : rd.getCropToSiteRefEntity()) {
                    if (ref != null && ref.getConfigCropEntity() != null) {
                        if (rdCrops.length() > 0) rdCrops.append(", ");
                        rdCrops.append(ref.getConfigCropEntity().getCropName());
                    }
                }
            }
    %>
    <span class="dispatch-chip" title="Click to record sale"
          onclick="quickSale(<%=rd.getAssignCroptoSiteId()%>)">
        <%=rdSite%><% if (rdCrops.length() > 0) { %>&nbsp;&mdash;&nbsp;<%=rdCrops.toString()%><% } %>
    </span>
    <% } %>
</div>
<% } %>

<!-- ③ Sale Detail (only when a sale is selected) -->
<% if (hasSelection && selectedSale != null) { %>
<div class="detail-card">
    <div class="detail-card-hdr">
        <div>
            <span class="detail-card-title">Sale Detail</span>
            <span class="detail-card-sub"><%=siteName%> &bull; <%=cropName%> &bull; <%=saleDateDisp%></span>
        </div>
        <div class="detail-card-actions">
            <button type="button" class="btn-cancel"
                    onclick="window.location='cropSaleProcess.jsp'">&#8592; All Sales</button>
            <button type="button" class="btn-update"
                    onclick="editSale()">&#9998; Edit Sale</button>
            <button type="button" class="btn-add"
                    onclick="resetSaleForm(); showSaleForm()">+ New Sale</button>
        </div>
    </div>
    <div class="detail-card-body">

        <!-- Info strip -->
        <div class="info-strip">
            <span class="info-chip"><span class="lbl">Site</span><%=siteName%></span>
            <span class="info-chip"><span class="lbl">Crop</span><%=cropName%></span>
            <span class="info-chip"><span class="lbl">Buyer</span><%=buyerName%>
                <% if (!buyerType.isEmpty()) { %>&nbsp;<em style="font-size:10px;color:var(--text-muted);">[<%=buyerType%>]</em><% } %>
            </span>
            <span class="info-chip"><span class="lbl">Date</span><%=saleDateDisp%></span>
            <span class="info-chip"><span class="lbl">Qty</span><%=saleQty%> <%=saleUnit%></span>
            <span class="info-chip"><span class="lbl">Price/Unit</span><%=salePrice%></span>
            <% if (saleComment != null && !saleComment.isEmpty()) { %>
            <span class="info-chip"><span class="lbl">Note</span><%=saleComment%></span>
            <% } %>
        </div>

        <!-- Amount summary -->
        <div class="amt-bar">
            <div class="amt-card">
                <div class="ac-lbl">Total Sale</div>
                <div class="ac-val"><%=String.format("%.2f", totalSale)%></div>
            </div>
            <div class="amt-card received">
                <div class="ac-lbl">Received</div>
                <div class="ac-val"><%=String.format("%.2f", totalReceived)%></div>
            </div>
            <div class="amt-card balance">
                <div class="ac-lbl">Balance</div>
                <div class="ac-val"><%=String.format("%.2f", balance)%></div>
            </div>
        </div>

        <!-- Payment form -->
        <div class="pay-section-hdr">
            <span>Payments</span>
            <span class="pay-mode-badge" id="payModeBadge" style="display:none;">Editing Payment</span>
        </div>
        <div class="pay-form" id="payFormPanel">
            <form method="post">
                <input type="hidden" name="saleId"        value="<%=saleId%>">
                <input type="hidden" name="salePaymentId" id="salePaymentId">
                <div class="pay-row">
                    <div class="pay-field">
                        <label>Mode *</label>
                        <select name="paymentMode" id="paymentMode" required style="width:110px;">
                            <option value="">Select</option>
                            <option value="Cash">Cash</option>
                            <option value="Check">Check</option>
                            <option value="Transfer">Transfer</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="pay-field">
                        <label>Amount *</label>
                        <input type="text" name="amountReceived" id="amountReceived" required
                               pattern="[0-9]+(\.[0-9]+)?" style="width:90px;">
                    </div>
                    <div class="pay-field">
                        <label>Date *</label>
                        <input type="text" name="paymentDate" id="paymentDate" required
                               placeholder="dd/mm/yyyy" style="width:105px;">
                    </div>
                    <div class="pay-field">
                        <label>Reference No</label>
                        <input type="text" name="referenceNo" id="referenceNo" style="width:110px;">
                    </div>
                    <div class="pay-field">
                        <label>Comment</label>
                        <input type="text" name="comment" id="payComment" placeholder="Optional" style="width:130px;">
                    </div>
                    <div class="pay-btns">
                        <input type="submit" class="btn-add"    id="sbtAddPayment"    name="sbtAddPayment"    value="Add"
                               onclick="this.form.action='../../SalePaymentController'">
                        <input type="submit" class="btn-update" id="sbtUpdatePayment" name="sbtUpdatePayment" value="Update" hidden
                               onclick="this.form.action='../../SalePaymentController'">
                        <input type="button" class="btn-cancel" value="Reset" onclick="resetPayForm()">
                    </div>
                </div>
            </form>
        </div>

        <!-- Payment history -->
        <% if (!payments.isEmpty()) { %>
        <table border="1" cellspacing="0" class="tbl-data" width="100%">
            <thead>
                <tr>
                    <th width="4%">#</th>
                    <th>Mode</th>
                    <th>Date</th>
                    <th>Amount</th>
                    <th>Reference</th>
                    <th>Comment</th>
                    <th width="12%">Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                int hcnt = 0;
                for (SalePaymentEntity sp : payments) {
                    if (sp == null) continue;
                    hcnt++;
                    String payDateDisp = sp.getPaymentDate() != null
                        ? FarmUtility.convertfrom_yymmddToddmmyy(sp.getPaymentDate().toString()) : "";
            %>
                <tr>
                    <td><%=hcnt%></td>
                    <td><%=sp.getPaymentMode() != null ? sp.getPaymentMode() : ""%></td>
                    <td><%=payDateDisp%></td>
                    <td style="text-align:right; font-weight:600;"><%=String.format("%.2f", sp.getAmountReceived())%></td>
                    <td><%=sp.getReferenceNo() != null ? sp.getReferenceNo() : ""%></td>
                    <td><%=sp.getComment()     != null ? sp.getComment()     : ""%></td>
                    <td style="text-align:center; white-space:nowrap;">
                        <button type="button" class="btn-row-edit"
                            onclick="editPayment(<%=sp.getSalePaymentId()%>)">Edit</button>
                        <form method="post" action="../../SalePaymentController" style="display:inline;"
                              onsubmit="return confirm('Delete this payment record?');">
                            <input type="hidden" name="salePaymentId" value="<%=sp.getSalePaymentId()%>">
                            <input type="hidden" name="saleId"        value="<%=saleId%>">
                            <input type="submit" class="btn-row-del"  name="sbtDeletePayment" value="Del">
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <p style="font-size:12px; color:var(--text-muted); margin:4px 0;">No payments recorded yet.</p>
        <% } %>

    </div>
</div>
<% } %>

<!-- ④ Sales List -->
<div>
    <div class="list-hdr">
        <span class="list-hdr-title">All Sales</span>
        <button type="button" class="btn-add" onclick="resetSaleForm(); showSaleForm()">+ New Sale</button>
    </div>

    <div class="filter-bar">
        <div class="filter-field">
            <label>Date</label>
            <input type="text" id="txtDate" placeholder="dd/mm/yyyy" onchange="loadSaleTable()">
        </div>
        <div class="filter-field">
            <label>Site</label>
            <select id="selSiteId" onchange="loadSaleTable()">
                <option value="-1">All Sites</option>
                <%
                    for (ConfigSiteInformationEntity si : siteInfoList) {
                        if (si == null) continue;
                %>
                <option value="<%=si.getSiteInfoId()%>"><%=si.getSiteName() != null ? si.getSiteName() : ""%></option>
                <% } %>
            </select>
        </div>
        <div class="filter-field">
            <label>Crop</label>
            <select id="selCropId" onchange="loadSaleTable()">
                <option value="-1">All Crops</option>
                <%
                    for (ConfigCropEntity cr : cropList) {
                        if (cr == null) continue;
                %>
                <option value="<%=cr.getCropId()%>"><%=cr.getCropName()%></option>
                <% } %>
            </select>
        </div>
        <div class="filter-field">
            <label>Buyer</label>
            <select id="selBuyerId" onchange="loadSaleTable()">
                <option value="-1">All Buyers</option>
                <%
                    for (BuyerEntity b : buyerList) {
                        if (b == null) continue;
                %>
                <option value="<%=b.getBuyerId()%>"><%=b.getBuyerName() != null ? b.getBuyerName() : ""%></option>
                <% } %>
            </select>
        </div>
        <div style="margin-left:auto; display:flex; align-items:flex-end;">
            <button type="button" class="btn-cancel" onclick="clearAllFilters()">Clear Filters</button>
        </div>
    </div>

    <div id="showTable"></div>
</div>

</fieldset>

<!-- Payment JS data for edit population -->
<script>
<%
    for (SalePaymentEntity sp : payments) {
        if (sp == null) continue;
        String payDateDisp2 = sp.getPaymentDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(sp.getPaymentDate().toString()) : "";
%>
salePayments[<%=sp.getSalePaymentId()%>] = {
    paymentMode:    '<%=sp.getPaymentMode() != null ? sp.getPaymentMode().replace("'","\\'") : ""%>',
    amountReceived:  <%=sp.getAmountReceived()%>,
    paymentDate:    '<%=payDateDisp2%>',
    referenceNo:    '<%=sp.getReferenceNo() != null ? sp.getReferenceNo().replace("'","\\'") : ""%>',
    comment:        '<%=sp.getComment()     != null ? sp.getComment().replace("'","\\'")     : ""%>'
};
<% } %>
</script>

<%@include file="../../footer.jsp" %>
</body>
</html>
