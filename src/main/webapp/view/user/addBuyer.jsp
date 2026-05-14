<%@page import="com.san.farm.adminuser.dao.BuyerService"%>
<%@page import="com.san.farm.adminuser.entity.BuyerEntity"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    String msgParam = request.getParameter("msg");
    String errParam = request.getParameter("err");
    String bannerMsg   = null;
    String bannerClass = null;
    if ("saved".equals(msgParam))        { bannerMsg = "Buyer saved successfully.";   bannerClass = "success"; }
    else if ("updated".equals(msgParam)) { bannerMsg = "Buyer updated successfully."; bannerClass = "success"; }
    else if ("deleted".equals(msgParam)) { bannerMsg = "Buyer deleted successfully."; bannerClass = "success"; }
    else if ("failed".equals(errParam))  { bannerMsg = "Operation failed. Please try again."; bannerClass = "error"; }

    List<BuyerEntity> buyerList = new ArrayList<BuyerEntity>();
    try {
        BuyerService buyerService = new BuyerService();
        buyerList = buyerService.getAll();
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manage Buyers</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="../../css/datatables.min.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<style>
    #msgBanner {
        display: none;
        padding: 7px 14px; border-radius: 4px; margin-bottom: 10px;
        font-size: 12px; font-weight: 600;
    }
    #msgBanner.success { background: #e8f5e9; border: 1px solid #a5d6a7; color: #1b5e20; }
    #msgBanner.error   { background: #fdecea; border: 1px solid #ef9a9a; color: #b71c1c; }
    #editBanner {
        display: none; background: #fff3cd; border: 1px solid #ffc107; color: #856404;
        padding: 5px 12px; border-radius: 3px; margin-bottom: 8px;
        font-weight: bold; font-size: 12px;
    }
    .form-grid { display: grid; grid-template-columns: 130px 1fr; gap: 6px 8px; align-items: center; }
    .form-grid label { text-align: right; font-weight: 600; color: #424242; font-size: 12px; }
    .form-grid input[type=text], .form-grid select, .form-grid textarea {
        padding: 5px 8px; border: 1px solid #bdbdbd; border-radius: 3px;
        font-size: 12px; font-family: inherit; outline: none;
        transition: border-color 0.15s, box-shadow 0.15s; width: 240px;
    }
    .form-grid input:focus, .form-grid select:focus, .form-grid textarea:focus {
        border-color: #1976d2; box-shadow: 0 0 0 2px rgba(25,118,210,0.15);
    }
    .form-btns { grid-column: 1 / -1; text-align: center; margin-top: 6px; }
    .tbl-data td.action-cell { text-align: center; white-space: nowrap; }
    .buyer-badge {
        display: inline-block; font-size: 10px; font-weight: 700;
        padding: 1px 7px; border-radius: 8px; vertical-align: middle;
    }
    .buyer-local { background: #e8f5e9; color: #1b5e20; border: 1px solid #a5d6a7; }
    .buyer-b2b   { background: #e3f2fd; color: #0d47a1; border: 1px solid #90caf9; }
</style>
<script type="text/javascript">
    var editingRowEl = null;

    function editRow(id, nameVal, typeVal, companyVal, contactVal, addressVal, emailVal, commentVal) {
        if (editingRowEl) editingRowEl.classList.remove('selected-row');
        editingRowEl = document.getElementById('row-' + id);
        if (editingRowEl) editingRowEl.classList.add('selected-row');

        document.getElementById('buyerId').value      = id;
        document.getElementById('buyerName').value    = nameVal;
        document.getElementById('buyerType').value    = typeVal;
        document.getElementById('companyName').value  = companyVal;
        document.getElementById('contactNo').value    = contactVal;
        document.getElementById('address').value      = addressVal;
        document.getElementById('email').value        = emailVal;
        document.getElementById('comment').value      = commentVal;

        document.getElementById('editBanner').style.display = 'block';
        document.getElementById('editBanner').innerText = 'Editing: ' + nameVal;
        document.getElementById('btnAdd').style.display    = 'none';
        document.getElementById('btnUpdate').style.display = 'inline-block';
        document.getElementById('btnCancel').style.display = 'inline-block';
        document.getElementById('formPanel').scrollIntoView({ behavior: 'smooth' });
    }

    function resetForm() {
        if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
        document.getElementById('buyerId').value      = '';
        document.getElementById('buyerName').value    = '';
        document.getElementById('buyerType').value    = '';
        document.getElementById('companyName').value  = '';
        document.getElementById('contactNo').value    = '';
        document.getElementById('address').value      = '';
        document.getElementById('email').value        = '';
        document.getElementById('comment').value      = '';
        document.getElementById('editBanner').style.display = 'none';
        document.getElementById('btnAdd').style.display    = 'inline-block';
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

<%
    if (bannerMsg != null) {
%>
<div id="msgBanner" class="<%=bannerClass%>" style="display:block;"><%=bannerMsg%></div>
<% } else { %>
<div id="msgBanner"></div>
<% } %>

<fieldset>
    <legend>Manage Buyers</legend>

    <form method="post" id="frmBuyer">
        <input type="hidden" name="buyerId" id="buyerId">
        <div id="formPanel" class="form-panel" style="display:block; min-width:420px;">
            <div id="editBanner"></div>
            <div class="form-grid">
                <label for="buyerName">Buyer Name *</label>
                <input type="text" name="buyerName" id="buyerName" required maxlength="100">

                <label for="buyerType">Buyer Type *</label>
                <select name="buyerType" id="buyerType" required style="width:240px;">
                    <option value="">--- Select ---</option>
                    <option value="Local">Local</option>
                    <option value="B2B">B2B</option>
                </select>

                <label for="companyName">Company Name</label>
                <input type="text" name="companyName" id="companyName" maxlength="150">

                <label for="contactNo">Contact No</label>
                <input type="text" name="contactNo" id="contactNo" maxlength="20">

                <label for="address">Address</label>
                <input type="text" name="address" id="address" maxlength="255">

                <label for="email">Email</label>
                <input type="text" name="email" id="email" maxlength="100">

                <label for="comment">Comment</label>
                <input type="text" name="comment" id="comment" maxlength="255" placeholder="Optional">

                <div class="form-btns">
                    <input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="Add Buyer"
                           onclick="this.form.action='../../BuyerController'">
                    <input type="submit" class="btn-update" id="btnUpdate" name="edit" value="Update"
                           style="display:none" onclick="this.form.action='../../BuyerController'">
                    <input type="button" class="btn-cancel" id="btnCancel" value="Cancel"
                           style="display:none" onclick="resetForm()">
                </div>
            </div>
        </div>
    </form>

    <form method="post" id="frmDelete" action="../../BuyerController">
        <input type="hidden" name="delete"  value="1">
        <input type="hidden" name="buyerId" id="delBuyerId" value="">
    </form>

    <table id="buyerTable" border="1" width="100%" class="tbl-data" cellspacing="0" style="margin-top:14px;">
        <thead>
            <tr>
                <th width="5%">#</th>
                <th>Buyer Name</th>
                <th width="9%">Type</th>
                <th>Company</th>
                <th>Contact</th>
                <th>Address</th>
                <th>Email</th>
                <th>Comment</th>
                <th width="12%">Actions</th>
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
                String safeContact = b.getContactNo()   != null ? b.getContactNo().replace("'","\\'")   : "";
                String safeAddr    = b.getAddress()     != null ? b.getAddress().replace("'","\\'")     : "";
                String safeEmail   = b.getEmail()       != null ? b.getEmail().replace("'","\\'")       : "";
                String safeComment = b.getComment()     != null ? b.getComment().replace("'","\\'")     : "";
                String typeClass   = "B2B".equals(safeType) ? "buyer-b2b" : "buyer-local";
        %>
            <tr id="row-<%=b.getBuyerId()%>">
                <td><%=cnt%></td>
                <td><%=b.getBuyerName() != null ? b.getBuyerName() : ""%></td>
                <td style="text-align:center;">
                    <span class="buyer-badge <%=typeClass%>"><%=safeType%></span>
                </td>
                <td><%=b.getCompanyName() != null ? b.getCompanyName() : ""%></td>
                <td><%=b.getContactNo()   != null ? b.getContactNo()   : ""%></td>
                <td><%=b.getAddress()     != null ? b.getAddress()     : ""%></td>
                <td><%=b.getEmail()       != null ? b.getEmail()       : ""%></td>
                <td><%=b.getComment()     != null ? b.getComment()     : ""%></td>
                <td class="action-cell">
                    <button type="button" class="btn-row-edit"
                        onclick="editRow(<%=b.getBuyerId()%>,'<%=safeName%>','<%=safeType%>','<%=safeCompany%>','<%=safeContact%>','<%=safeAddr%>','<%=safeEmail%>','<%=safeComment%>')">Edit</button>
                    <button type="button" class="btn-row-del"
                        onclick="confirmDelete(<%=b.getBuyerId()%>,'<%=safeName%>')">Delete</button>
                </td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

</fieldset>

<%@include file="../../footer.jsp" %>
</body>
</html>
