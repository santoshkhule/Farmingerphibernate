<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="com.san.farm.adminuser.dao.BuyerService"%>
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
                saleUnit    = selectedSale.getUnit()     != null ? selectedSale.getUnit()                               : "";
                saleQty     = String.format("%.2f", selectedSale.getQuantity());
                salePrice   = String.format("%.2f", selectedSale.getPricePerUnit());
                saleTotalDisp = String.format("%.2f", selectedSale.getTotalAmount());
                saleComment = selectedSale.getComment() != null ? selectedSale.getComment() : "";
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    // IDs needed to pre-populate dropdowns when editing
    int selAssignCroptoSiteId = (selectedSale != null && selectedSale.getAssignCropToSiteEntity() != null)
            ? selectedSale.getAssignCropToSiteEntity().getAssignCroptoSiteId() : 0;
    int selCropId  = (selectedSale != null && selectedSale.getCropEntity()  != null) ? selectedSale.getCropEntity().getCropId()   : 0;
    int selBuyerId = (selectedSale != null && selectedSale.getBuyerEntity() != null) ? selectedSale.getBuyerEntity().getBuyerId() : 0;

    // Preload data for dropdowns
    List<AssignCropToSiteEntity>      siteList     = new ArrayList<AssignCropToSiteEntity>();
    List<ConfigSiteInformationEntity> siteInfoList = new ArrayList<ConfigSiteInformationEntity>();
    List<ConfigCropEntity>            cropList     = new ArrayList<ConfigCropEntity>();
    List<BuyerEntity>                 buyerList    = new ArrayList<BuyerEntity>();
    try {
        siteList     = new AssignCropToSiteService().getListOFAssignCropToSite();
        siteInfoList = new ConfigSiteInformationService().fetch();
        cropList     = new ConfigCropService().fetch();
        buyerList    = new BuyerService().getAll();
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

    .info-strip {
        display: flex; flex-wrap: wrap; gap: 6px 10px; margin-bottom: 10px;
        padding: 8px 12px; background: var(--gray-100); border-radius: var(--r-sm); border: 1px solid var(--gray-200);
    }
    .info-chip { font-size: 12px; color: var(--text); }
    .info-chip .lbl { font-size: 10px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; margin-right: 4px; }

    .amt-bar { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
    .amt-card { flex: 1; min-width: 100px; text-align: center; padding: 10px 12px; border-radius: var(--r-md); background: var(--gray-50); border: 1px solid var(--gray-200); }
    .amt-card .ac-lbl { font-size: 10px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; }
    .amt-card .ac-val { font-size: 1.3em; font-weight: 700; color: var(--green-dk); margin-top: 3px; }
    .amt-card.balance { background: var(--blue-lt); border-color: var(--blue-bd); }
    .amt-card.balance .ac-val { color: var(--blue-dk); }
    .amt-card.received .ac-val { color: #2e7d32; }

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

    .sale-form { background: #f1f8e9; border: 1px solid var(--green-bd); border-radius: var(--r-md); padding: 12px 16px; }
    .sale-grid { display: grid; grid-template-columns: 130px 1fr; gap: 6px 8px; align-items: center; max-width: 600px; }
    .sale-grid label { text-align: right; font-weight: 600; color: #424242; font-size: 12px; }
    .sale-grid input[type=text], .sale-grid select {
        padding: 5px 8px; border: 1px solid #bdbdbd; border-radius: 3px;
        font-size: 12px; font-family: inherit; outline: none; width: 220px;
        transition: border-color 0.15s;
    }
    .sale-grid input:focus, .sale-grid select:focus { border-color: var(--green-md); }
    .sale-btns { grid-column: 1 / -1; text-align: center; margin-top: 6px; }

    .hist-section { margin-top: 4px; }
    .hist-section h4 { font-size: 12px; font-weight: 700; color: var(--green-dk); margin: 0 0 6px; }
    .sp-pill { display: inline-block; padding: 2px 8px; border-radius: 8px; font-size: 10px; font-weight: 700; white-space: nowrap; }
</style>
</head>
<body>
<script type="text/javascript">
    var salePayments = {};

    function togglePanel(bodyId, chevId) {
        var body = document.getElementById(bodyId);
        var chev = document.getElementById(chevId);
        if (body.style.display === 'none') {
            body.style.display = ''; if (chev) chev.classList.add('open');
        } else {
            body.style.display = 'none'; if (chev) chev.classList.remove('open');
        }
    }

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
        var fromDate  = document.getElementById('txtDate').value;
        var siteId    = document.getElementById('selSiteId').value;
        var cropId    = document.getElementById('selCropId').value;
        var buyerId   = document.getElementById('selBuyerId').value;
        var xmlhttp   = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var tbl = $('#showTable table.tbl-data');
                if (tbl.length && $.fn.DataTable.isDataTable(tbl)) { tbl.DataTable().destroy(); }
                document.getElementById('showTable').innerHTML = xmlhttp.responseText;
                initSaleTable();
            }
        };
        xmlhttp.open('GET', '01cropSaleViewAllAjax.jsp'
            + '?fromDate='  + encodeURIComponent(fromDate)
            + '&siteId='    + encodeURIComponent(siteId)
            + '&cropId='    + encodeURIComponent(cropId)
            + '&buyerId='   + encodeURIComponent(buyerId), true);
        xmlhttp.send();
    }

    function initSaleTable() {
        var tbl = $('#showTable table.tbl-data');
        if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
            tbl.DataTable({
                pageLength: 10,
                lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
                columnDefs: [{ orderable: false, targets: [0, 12] }],
                dom: '<"dt-toolbar"lf>t<"dt-footer"ip>'
            });
        }
    }

    function computeTotal() {
        var qty   = parseFloat(document.getElementById('saleQty').value)   || 0;
        var price = parseFloat(document.getElementById('salePrice').value) || 0;
        document.getElementById('saleTotalAmt').value = (qty * price).toFixed(2);
    }

    function editPayment(id) {
        var d = salePayments[id];
        if (!d) return;
        document.getElementById('paymentMode').value   = d.paymentMode;
        document.getElementById('amountReceived').value = d.amountReceived;
        document.getElementById('paymentDate').value   = d.paymentDate;
        document.getElementById('referenceNo').value   = d.referenceNo;
        document.getElementById('payComment').value    = d.comment;
        document.getElementById('salePaymentId').value = id;
        document.getElementById('sbtUpdatePayment').removeAttribute('hidden');
        document.getElementById('sbtAddPayment').setAttribute('hidden', 'true');
        document.getElementById('payFormPanel').scrollIntoView({ behavior: 'smooth' });
    }

    function resetPayForm() {
        document.getElementById('paymentMode').value    = '';
        document.getElementById('amountReceived').value = '';
        document.getElementById('paymentDate').value    = '';
        document.getElementById('referenceNo').value    = '';
        document.getElementById('payComment').value     = '';
        document.getElementById('salePaymentId').value  = '';
        document.getElementById('sbtUpdatePayment').setAttribute('hidden', 'true');
        document.getElementById('sbtAddPayment').removeAttribute('hidden');
    }

    /* ── Sale edit ── */
    function editSale() {
        var selSiteId  = <%=selAssignCroptoSiteId%>;
        var selCropId  = <%=selCropId%>;
        var selBuyerId = <%=selBuyerId%>;

        document.getElementById('editSaleId').value = <%=saleId%>;
        setSelectValue('assignCroptoSiteId', selSiteId);
        setSelectValue('cropId',             selCropId);
        setSelectValue('buyerId',            selBuyerId);
        document.getElementById('saleQty').value      = '<%=saleQty%>';
        document.getElementById('saleUnit').value     = '<%=saleUnit%>';
        document.getElementById('salePrice').value    = '<%=salePrice%>';
        document.getElementById('saleTotalAmt').value = '<%=saleTotalDisp%>';
        document.getElementById('saleDate').value     = '<%=saleDateDisp%>';
        document.getElementById('saleComment').value  = '<%=saleComment.replace("'", "\\'")%>';

        document.getElementById('saleFormTitle').innerText = 'Edit Sale';
        document.getElementById('btnRecordSale').style.display = 'none';
        document.getElementById('btnUpdateSale').style.display = '';
        document.getElementById('btnClearSale').style.display  = '';

        var body = document.getElementById('panelNewSaleBody');
        var chev = document.getElementById('newSaleChev');
        body.style.display = '';
        chev.classList.add('open');
        body.scrollIntoView({ behavior: 'smooth' });
    }

    function resetSaleForm() {
        document.getElementById('editSaleId').value   = '';
        document.getElementById('assignCroptoSiteId').selectedIndex = 0;
        document.getElementById('cropId').selectedIndex    = 0;
        document.getElementById('buyerId').selectedIndex   = 0;
        document.getElementById('saleQty').value      = '';
        document.getElementById('saleUnit').selectedIndex = 0;
        document.getElementById('salePrice').value    = '';
        document.getElementById('saleTotalAmt').value = '';
        document.getElementById('saleDate').value     = '';
        document.getElementById('saleComment').value  = '';
        document.getElementById('saleFormTitle').innerText = 'Record New Sale';
        document.getElementById('btnRecordSale').style.display = '';
        document.getElementById('btnUpdateSale').style.display = 'none';
        document.getElementById('btnClearSale').style.display  = 'none';
    }

    function setSelectValue(id, val) {
        var sel = document.getElementById(id);
        for (var i = 0; i < sel.options.length; i++) {
            if (parseInt(sel.options[i].value) === val) { sel.selectedIndex = i; return; }
        }
    }

    $(document).ready(function() {
        $('#txtDate').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
        $('#paymentDate').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
        $('#saleDate').datepicker({ changeMonth: true, changeYear: true, dateFormat: 'dd/mm/yy' });
        loadSaleTable();
    });
</script>
<fieldset><legend>Crop Sale Processing</legend>

    <!-- Panel 1: All Sales -->
    <div class="cpanel">
        <div class="cpanel-head clickable" onclick="togglePanel('panelSalesBody','salesChev')">
            <h3>All Sales</h3>
            <span class="cpanel-chevron <%=hasSelection ? "" : "open"%>" id="salesChev">&#9660;</span>
        </div>
        <div id="panelSalesBody" class="cpanel-body" style="<%=hasSelection ? "display:none;" : ""%>">
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
                <div class="filter-field" style="justify-content:flex-end;">
                    <button type="button" class="btn-cancel" onclick="clearAllFilters()">Clear</button>
                </div>
            </div>
            <div id="showTable"></div>
        </div>
    </div>

    <!-- Panel 2: Sale Detail (only when saleId selected) -->
    <% if (hasSelection && selectedSale != null) { %>
    <div class="cpanel">
        <div class="cpanel-head" style="cursor:default;">
            <h3>Sale Detail
                <span class="cpanel-sub">&#8212; <%=siteName%> &bull; <%=cropName%> &bull; <%=saleDateDisp%></span>
            </h3>
            <div style="display:flex; gap:8px;">
                <button type="button" class="btn-cancel" onclick="togglePanel('panelSalesBody','salesChev'); document.getElementById('panelSalesBody').scrollIntoView({behavior:'smooth'});">&#8645; All Sales</button>
                <button type="button" class="btn-update" onclick="editSale()">&#9998; Edit Sale</button>
                <button type="button" class="btn-add" onclick="resetSaleForm(); togglePanel('panelNewSaleBody','newSaleChev'); document.getElementById('panelNewSaleBody').scrollIntoView({behavior:'smooth'});">+ New Sale</button>
            </div>
        </div>
        <div class="cpanel-body">

            <div class="info-strip">
                <span class="info-chip"><span class="lbl">Site</span><%=siteName%></span>
                <span class="info-chip"><span class="lbl">Crop</span><%=cropName%></span>
                <span class="info-chip"><span class="lbl">Buyer</span><%=buyerName%></span>
                <% if (!buyerType.isEmpty()) { %>
                <span class="info-chip"><span class="lbl">Buyer Type</span><%=buyerType%></span>
                <% } %>
                <span class="info-chip"><span class="lbl">Date</span><%=saleDateDisp%></span>
                <span class="info-chip"><span class="lbl">Qty</span><%=saleQty%> <%=saleUnit%></span>
                <span class="info-chip"><span class="lbl">Price/Unit</span><%=salePrice%></span>
                <% if (saleComment != null && !saleComment.isEmpty()) { %>
                <span class="info-chip"><span class="lbl">Note</span><%=saleComment%></span>
                <% } %>
            </div>

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

            <!-- Payment entry form -->
            <div class="pay-form" id="payFormPanel">
                <form method="post">
                    <input type="hidden" name="saleId"        value="<%=saleId%>">
                    <input type="hidden" name="salePaymentId" id="salePaymentId">
                    <div class="pay-row">
                        <div class="pay-field">
                            <label>Payment Mode *</label>
                            <select name="paymentMode" id="paymentMode" required style="width:120px;">
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
                                   pattern="[0-9]+(\.[0-9]+)?" style="width:100px;">
                        </div>
                        <div class="pay-field">
                            <label>Payment Date *</label>
                            <input type="text" name="paymentDate" id="paymentDate" required
                                   placeholder="dd/mm/yyyy" style="width:110px;">
                        </div>
                        <div class="pay-field">
                            <label>Reference No</label>
                            <input type="text" name="referenceNo" id="referenceNo" style="width:120px;">
                        </div>
                        <div class="pay-field">
                            <label>Comment</label>
                            <input type="text" name="comment" id="payComment" placeholder="Optional" style="width:140px;">
                        </div>
                        <div class="pay-btns">
                            <input type="submit" class="btn-add"    id="sbtAddPayment"    name="sbtAddPayment"    value="Add Payment"
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
            <div class="hist-section">
                <h4>Payment History</h4>
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
                            <td><%=sp.getPaymentMode()  != null ? sp.getPaymentMode()  : ""%></td>
                            <td><%=payDateDisp%></td>
                            <td style="text-align:right; font-weight:600;"><%=String.format("%.2f", sp.getAmountReceived())%></td>
                            <td><%=sp.getReferenceNo()  != null ? sp.getReferenceNo()  : ""%></td>
                            <td><%=sp.getComment()      != null ? sp.getComment()      : ""%></td>
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

    <!-- Panel 3: Record / Edit Sale -->
    <div class="cpanel" id="panelNewSale">
        <div class="cpanel-head clickable" onclick="togglePanel('panelNewSaleBody','newSaleChev')">
            <h3 id="saleFormTitle">Record New Sale</h3>
            <span class="cpanel-chevron" id="newSaleChev">&#9660;</span>
        </div>
        <div id="panelNewSaleBody" class="cpanel-body" style="display:none;">
            <div class="sale-form">
                <form method="post" action="../../CropSaleController">
                    <input type="hidden" name="saleId" id="editSaleId" value="">
                    <div class="sale-grid">
                        <label for="assignCroptoSiteId">Site Allocation *</label>
                        <select name="assignCroptoSiteId" id="assignCroptoSiteId" required style="width:240px;">
                            <option value="">--- Select Site ---</option>
                            <%
                                for (AssignCropToSiteEntity s : siteList) {
                                    if (s == null) continue;
                                    String sn = (s.getSiteInformationEntity() != null && s.getSiteInformationEntity().getSiteName() != null)
                                        ? s.getSiteInformationEntity().getSiteName() : "Site #" + s.getAssignCroptoSiteId();
                                    String sd = s.getCropAssignDate() != null
                                        ? FarmUtility.convertfrom_yymmddToddmmyy(s.getCropAssignDate().toString()) : "";
                            %>
                            <option value="<%=s.getAssignCroptoSiteId()%>"><%=sn%><%=sd.isEmpty() ? "" : " (" + sd + ")"%></option>
                            <% } %>
                        </select>

                        <label for="cropId">Crop *</label>
                        <select name="cropId" id="cropId" required style="width:240px;">
                            <option value="">--- Select Crop ---</option>
                            <%
                                for (ConfigCropEntity cr : cropList) {
                                    if (cr == null) continue;
                            %>
                            <option value="<%=cr.getCropId()%>"><%=cr.getCropName() != null ? cr.getCropName() : ""%></option>
                            <% } %>
                        </select>

                        <label for="buyerId">Buyer *</label>
                        <select name="buyerId" id="buyerId" required style="width:240px;">
                            <option value="">--- Select Buyer ---</option>
                            <%
                                for (BuyerEntity b : buyerList) {
                                    if (b == null) continue;
                            %>
                            <option value="<%=b.getBuyerId()%>"><%=(b.getBuyerName() != null ? b.getBuyerName() : "")%><%=(b.getBuyerType() != null ? " [" + b.getBuyerType() + "]" : "")%></option>
                            <% } %>
                        </select>

                        <label for="saleQty">Quantity *</label>
                        <input type="text" name="quantity" id="saleQty" required
                               pattern="[0-9]+(\.[0-9]*)?" style="width:120px;"
                               oninput="computeTotal()">

                        <label for="saleUnit">Unit *</label>
                        <select name="unit" id="saleUnit" required style="width:120px;">
                            <option value="">-- Select --</option>
                            <option value="Kg">Kg</option>
                            <option value="Quintal">Quintal</option>
                            <option value="Ton">Ton</option>
                        </select>

                        <label for="salePrice">Price/Unit *</label>
                        <input type="text" name="pricePerUnit" id="salePrice" required
                               pattern="[0-9]+(\.[0-9]*)?" style="width:120px;"
                               oninput="computeTotal()">

                        <label for="saleTotalAmt">Total Amount</label>
                        <input type="text" name="totalAmount" id="saleTotalAmt" readonly
                               style="width:120px; background:#f5f5f5;">

                        <label for="saleDate">Sale Date *</label>
                        <input type="text" name="saleDate" id="saleDate" required
                               placeholder="dd/mm/yyyy" style="width:120px;">

                        <label for="saleComment">Comment</label>
                        <input type="text" name="comment" id="saleComment" placeholder="Optional" style="width:240px;">

                        <div class="sale-btns">
                            <input type="submit" class="btn-add"    id="btnRecordSale" name="add"  value="Record Sale">
                            <input type="submit" class="btn-update" id="btnUpdateSale" name="edit" value="Update Sale" style="display:none">
                            <input type="button" class="btn-cancel" id="btnClearSale"  value="Clear" style="display:none" onclick="resetSaleForm()">
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

</fieldset>

<!-- Payment data for JS edit population -->
<script>
<%
    for (SalePaymentEntity sp : payments) {
        if (sp == null) continue;
        String payDateDisp = sp.getPaymentDate() != null
            ? FarmUtility.convertfrom_yymmddToddmmyy(sp.getPaymentDate().toString()) : "";
%>
salePayments[<%=sp.getSalePaymentId()%>] = {
    paymentMode:    '<%=sp.getPaymentMode()  != null ? sp.getPaymentMode().replace("'","\\'")  : ""%>',
    amountReceived:  <%=sp.getAmountReceived()%>,
    paymentDate:    '<%=payDateDisp%>',
    referenceNo:    '<%=sp.getReferenceNo()  != null ? sp.getReferenceNo().replace("'","\\'")  : ""%>',
    comment:        '<%=sp.getComment()      != null ? sp.getComment().replace("'","\\'")      : ""%>'
};
<% } %>
</script>

<%@include file="../../footer.jsp" %>
</body>
</html>
