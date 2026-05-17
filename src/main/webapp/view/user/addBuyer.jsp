<%@page import="com.san.farm.adminuser.dao.BuyerService"%>
<%@page import="com.san.farm.adminuser.entity.BuyerEntity"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    String msgParam = request.getParameter("msg");
    String errParam = request.getParameter("err");
    String bannerMsg   = null;
    String bannerClass = null;
    if ("saved".equals(msgParam))        { bannerMsg = msg.getString("buyer.banner_saved");   bannerClass = "banner-ok"; }
    else if ("updated".equals(msgParam)) { bannerMsg = msg.getString("buyer.banner_updated"); bannerClass = "banner-ok"; }
    else if ("deleted".equals(msgParam)) { bannerMsg = msg.getString("buyer.banner_deleted"); bannerClass = "banner-ok"; }
    else if ("failed".equals(errParam))  { bannerMsg = msg.getString("buyer.banner_failed");  bannerClass = "banner-err"; }

    List<BuyerEntity> buyerList = new ArrayList<BuyerEntity>();
    try {
        buyerList = new BuyerService().getAll();
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= msg.getString("buyer.page_title") %></title>
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/datatables.min.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<style>
    .banner-ok  { background:#e8f5e9; border:1px solid #a5d6a7; color:#1b5e20; padding:7px 14px; border-radius:4px; margin-bottom:10px; font-size:12px; font-weight:600; }
    .banner-err { background:#fdecea; border:1px solid #ef9a9a; color:#b71c1c; padding:7px 14px; border-radius:4px; margin-bottom:10px; font-size:12px; font-weight:600; }

    .form-card {
        background:#f9fbe7; border:1px solid var(--green-bd,#a5d6a7);
        border-radius:var(--r-md,6px); padding:14px 18px; margin-bottom:16px;
    }
    .form-card-title {
        font-size:12px; font-weight:700; color:var(--green-dk,#1b5e20);
        text-transform:uppercase; letter-spacing:.5px; margin-bottom:10px;
        padding-bottom:6px; border-bottom:1px solid var(--green-bd,#a5d6a7);
    }
    .edit-notice {
        background:#fff8e1; border:1px solid #ffe082; color:#5d4037;
        padding:4px 10px; border-radius:3px; margin-bottom:8px;
        font-size:11px; font-weight:700; display:none;
    }
    .field-grid {
        display:grid; grid-template-columns:repeat(2, 1fr); gap:8px 20px; align-items:end;
    }
    .field-group { display:flex; flex-direction:column; gap:3px; }
    .field-group label { font-size:11px; font-weight:600; color:var(--gray-800,#424242); }
    .field-group input, .field-group select {
        padding:5px 8px; border:1px solid #bdbdbd; border-radius:3px;
        font-size:12px; font-family:inherit; outline:none; width:100%;
        box-sizing:border-box; transition:border-color .15s, box-shadow .15s;
    }
    .field-group input:focus, .field-group select:focus {
        border-color:#1976d2; box-shadow:0 0 0 2px rgba(25,118,210,.12);
    }
    .field-full { grid-column:1 / -1; }
    .form-btns  { grid-column:1 / -1; display:flex; gap:8px; margin-top:4px; }
    .b2b-fields { grid-column:1 / -1; display:none; grid-template-columns:repeat(2,1fr); gap:8px 20px; }
    .b2b-fields.visible { display:grid; }

    .tbl-data td.cell-trunc { max-width:120px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .buyer-badge { display:inline-block; font-size:10px; font-weight:700; padding:1px 8px; border-radius:8px; }
    .buyer-local { background:#e8f5e9; color:#1b5e20; border:1px solid #a5d6a7; }
    .buyer-b2b   { background:#e3f2fd; color:#0d47a1; border:1px solid #90caf9; }
    .tbl-data td, .tbl-data th { vertical-align:middle; }
    .dataTables_wrapper { width:100%; }
</style>
<script type="text/javascript">
    var editingRowEl = null;

    function toggleB2BFields(type) {
        var b2bDiv = document.getElementById('b2bFields');
        if (type === 'B2B') {
            b2bDiv.classList.add('visible');
        } else {
            b2bDiv.classList.remove('visible');
            document.getElementById('companyName').value = '';
            document.getElementById('gstNumber').value   = '';
        }
    }

    function editRow(id, nameVal, typeVal, companyVal, gstVal, contactVal, addressVal, emailVal, commentVal) {
        if (editingRowEl) editingRowEl.classList.remove('selected-row');
        editingRowEl = document.getElementById('row-' + id);
        if (editingRowEl) editingRowEl.classList.add('selected-row');

        document.getElementById('buyerId').value     = id;
        document.getElementById('buyerName').value   = nameVal;
        document.getElementById('buyerType').value   = typeVal;
        document.getElementById('companyName').value = companyVal;
        document.getElementById('gstNumber').value   = gstVal;
        document.getElementById('contactNo').value   = contactVal;
        document.getElementById('address').value     = addressVal;
        document.getElementById('email').value       = emailVal;
        document.getElementById('comment').value     = commentVal;

        toggleB2BFields(typeVal);

        document.getElementById('editNotice').style.display = 'block';
        document.getElementById('editNotice').innerText = 'Editing: ' + nameVal;
        document.getElementById('formTitle').innerText = 'Edit Buyer';
        document.getElementById('btnAdd').style.display    = 'none';
        document.getElementById('btnUpdate').style.display = '';
        document.getElementById('btnCancel').style.display = '';
        document.getElementById('formCard').scrollIntoView({ behavior:'smooth', block:'nearest' });
    }

    function resetForm() {
        if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
        document.getElementById('buyerId').value     = '';
        document.getElementById('buyerName').value   = '';
        document.getElementById('buyerType').value   = '';
        document.getElementById('companyName').value = '';
        document.getElementById('gstNumber').value   = '';
        document.getElementById('contactNo').value   = '';
        document.getElementById('address').value     = '';
        document.getElementById('email').value       = '';
        document.getElementById('comment').value     = '';
        document.getElementById('b2bFields').classList.remove('visible');
        document.getElementById('editNotice').style.display = 'none';
        document.getElementById('formTitle').innerText = 'Add New Buyer';
        document.getElementById('btnAdd').style.display    = '';
        document.getElementById('btnUpdate').style.display = 'none';
        document.getElementById('btnCancel').style.display = 'none';
    }

    function confirmDelete(id, name) {
        if (!confirm('Delete buyer "' + name + '"? This cannot be undone.')) return;
        document.getElementById('delBuyerId').value = id;
        document.getElementById('frmDelete').submit();
    }

    $(document).ready(function() {
        $('#buyerTable').DataTable({
            pageLength: 10,
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
            columnDefs: [{ orderable: false, targets: [-1] }],
            dom: '<"dt-toolbar"lf>t<"dt-footer"ip>'
        });
    });
</script>
</head>
<body>

<% if (bannerMsg != null) { %>
<div class="<%=bannerClass%>"><%=bannerMsg%></div>
<% } %>

<fieldset><legend><%= msg.getString("buyer.fieldset_title") %></legend>

    <!-- ── Add / Edit form ── -->
    <div class="form-card" id="formCard">
        <div class="form-card-title" id="formTitle"><%= msg.getString("buyer.form_title_add") %></div>
        <div class="edit-notice" id="editNotice"></div>
        <form method="post" action="../../BuyerController" id="frmBuyer">
            <input type="hidden" name="buyerId" id="buyerId">
            <div class="field-grid">
                <div class="field-group">
                    <label for="buyerName"><%= msg.getString("buyer.label_buyer_name") %></label>
                    <input type="text" name="buyerName" id="buyerName" required maxlength="100">
                </div>
                <div class="field-group">
                    <label for="buyerType"><%= msg.getString("buyer.label_buyer_type") %></label>
                    <select name="buyerType" id="buyerType" required onchange="toggleB2BFields(this.value)">
                        <option value=""><%= msg.getString("buyer.select_type") %></option>
                        <option value="Local"><%= msg.getString("buyer.type_local") %></option>
                        <option value="B2B"><%= msg.getString("buyer.type_b2b") %></option>
                    </select>
                </div>

                <!-- B2B-only fields (hidden unless B2B selected) -->
                <div class="b2b-fields" id="b2bFields">
                    <div class="field-group">
                        <label for="companyName"><%= msg.getString("buyer.label_company_name") %></label>
                        <input type="text" name="companyName" id="companyName" maxlength="150">
                    </div>
                    <div class="field-group">
                        <label for="gstNumber"><%= msg.getString("buyer.label_gst_number") %></label>
                        <input type="text" name="gstNumber" id="gstNumber" maxlength="20" placeholder="e.g. 27AAPFU0939F1ZV">
                    </div>
                </div>

                <div class="field-group">
                    <label for="contactNo"><%= msg.getString("buyer.label_contact_no") %></label>
                    <input type="text" name="contactNo" id="contactNo" maxlength="20">
                </div>
                <div class="field-group">
                    <label for="email"><%= msg.getString("buyer.label_email") %></label>
                    <input type="text" name="email" id="email" maxlength="100">
                </div>
                <div class="field-group">
                    <label for="address"><%= msg.getString("buyer.label_address") %></label>
                    <input type="text" name="address" id="address" maxlength="255">
                </div>
                <div class="field-group">
                    <label for="comment"><%= msg.getString("buyer.label_comment") %></label>
                    <input type="text" name="comment" id="comment" maxlength="255" placeholder="Optional">
                </div>

                <div class="form-btns">
                    <input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="<%= msg.getString("buyer.btn_add") %>">
                    <input type="submit" class="btn-update" id="btnUpdate" name="edit" value="<%= msg.getString("btn.update") %>" style="display:none">
                    <input type="button" class="btn-cancel" id="btnCancel" value="<%= msg.getString("btn.cancel") %>" style="display:none" onclick="resetForm()">
                </div>
            </div>
        </form>
    </div>

    <form method="post" id="frmDelete" action="../../BuyerController">
        <input type="hidden" name="delete"  value="1">
        <input type="hidden" name="buyerId" id="delBuyerId" value="">
    </form>

    <!-- ── Buyer table ── -->
    <table id="buyerTable" border="1" width="100%" class="tbl-data" cellspacing="0">
        <thead>
            <tr>
                <th width="4%"><%= msg.getString("tbl.col_number") %></th>
                <th><%= msg.getString("buyer.tbl_col_buyer_name") %></th>
                <th width="8%"><%= msg.getString("buyer.tbl_col_type") %></th>
                <th><%= msg.getString("buyer.tbl_col_company") %></th>
                <th width="13%"><%= msg.getString("buyer.tbl_col_gst_no") %></th>
                <th width="11%"><%= msg.getString("buyer.tbl_col_contact") %></th>
                <th><%= msg.getString("tbl.col_address") %></th>
                <th><%= msg.getString("buyer.label_email") %></th>
                <th><%= msg.getString("tbl.col_comment") %></th>
                <th width="11%"><%= msg.getString("tbl.col_actions") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            int cnt = 0;
            for (BuyerEntity b : buyerList) {
                if (b == null) continue;
                cnt++;
                String safeName    = b.getBuyerName()   != null ? b.getBuyerName().replace("'","\\'")   : "";
                String safeType    = b.getBuyerType()   != null ? b.getBuyerType()                      : "";
                String safeCompany = b.getCompanyName() != null ? b.getCompanyName().replace("'","\\'") : "";
                String safeGst     = b.getGstNumber()   != null ? b.getGstNumber().replace("'","\\'")   : "";
                String safeContact = b.getContactNo()   != null ? b.getContactNo().replace("'","\\'")   : "";
                String safeAddr    = b.getAddress()     != null ? b.getAddress().replace("'","\\'")     : "";
                String safeEmail   = b.getEmail()       != null ? b.getEmail().replace("'","\\'")       : "";
                String safeComment = b.getComment()     != null ? b.getComment().replace("'","\\'")     : "";
                String typeClass   = "B2B".equals(safeType) ? "buyer-b2b" : "buyer-local";
        %>
            <tr id="row-<%=b.getBuyerId()%>">
                <td><%=cnt%></td>
                <td><%=b.getBuyerName()   != null ? b.getBuyerName()   : ""%></td>
                <td style="text-align:center;">
                    <span class="buyer-badge <%=typeClass%>"><%=safeType%></span>
                </td>
                <td class="cell-trunc" title="<%=safeCompany%>"><%=b.getCompanyName() != null ? b.getCompanyName() : ""%></td>
                <td><%=b.getGstNumber()   != null ? b.getGstNumber()   : ""%></td>
                <td><%=b.getContactNo()   != null ? b.getContactNo()   : ""%></td>
                <td class="cell-trunc" title="<%=safeAddr%>"><%=b.getAddress()  != null ? b.getAddress()  : ""%></td>
                <td class="cell-trunc" title="<%=safeEmail%>"><%=b.getEmail()    != null ? b.getEmail()    : ""%></td>
                <td class="cell-trunc" title="<%=safeComment%>"><%=b.getComment()  != null ? b.getComment()  : ""%></td>
                <td style="text-align:center; white-space:nowrap;">
                    <button type="button" class="btn-row-edit"
                        onclick="editRow(<%=b.getBuyerId()%>,'<%=safeName%>','<%=safeType%>','<%=safeCompany%>','<%=safeGst%>','<%=safeContact%>','<%=safeAddr%>','<%=safeEmail%>','<%=safeComment%>')"><%= msg.getString("btn.edit") %></button>
                    <button type="button" class="btn-row-del"
                        onclick="confirmDelete(<%=b.getBuyerId()%>,'<%=safeName%>')"><%= msg.getString("btn.delete") %></button>
                </td>
            </tr>
        <%  } %>
        </tbody>
    </table>

</fieldset>

<%@include file="../../footer.jsp" %>
</body>
</html>
