<%@page import="com.san.farm.login.dao.LoginUserService"%>
<%@page import="com.san.farm.login.entity.LoginUser"%>
<%@page import="com.san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.UserTypeService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Register User</title>
<style>
    #msgBanner {
        display: none;
        padding: 7px 14px;
        border-radius: 4px;
        margin-bottom: 10px;
        font-size: 12px;
        font-weight: 600;
    }
    #msgBanner.success {
        background: #e8f5e9; border: 1px solid #a5d6a7; color: #1b5e20;
    }
    #msgBanner.error {
        background: #fdecea; border: 1px solid #ef9a9a; color: #b71c1c;
    }
    #editBanner {
        display: none;
        background: #fff3cd;
        border: 1px solid #ffc107;
        color: #856404;
        padding: 5px 12px;
        border-radius: 3px;
        margin-bottom: 8px;
        font-weight: bold;
        font-size: 12px;
    }
    .form-grid { display: grid; grid-template-columns: 140px 1fr; gap: 6px 8px; align-items: center; }
    .form-grid label { text-align: right; font-weight: 600; color: #424242; font-size: 12px; }
    .form-grid input[type=text],
    .form-grid input[type=password],
    .form-grid select {
        padding: 5px 8px; border: 1px solid #bdbdbd; border-radius: 3px;
        font-size: 12px; font-family: inherit; outline: none;
        transition: border-color 0.15s, box-shadow 0.15s;
        width: 220px;
    }
    .form-grid input:focus, .form-grid select:focus {
        border-color: #1976d2; box-shadow: 0 0 0 2px rgba(25,118,210,0.15);
    }
    .form-btns { grid-column: 1 / -1; text-align: center; margin-top: 6px; }
    .tbl-data td.action-cell { text-align: center; white-space: nowrap; }
    #adminNote {
        display: none;
        grid-column: 1 / -1;
        background: #fff3cd; border: 1px solid #ffc107; color: #856404;
        padding: 5px 10px; border-radius: 3px; font-size: 11px; margin-bottom: 4px;
    }
    .admin-badge {
        display: inline-block; background: #fff3cd; border: 1px solid #ffc107;
        color: #856404; font-size: 10px; font-weight: 700;
        padding: 1px 6px; border-radius: 8px; margin-left: 5px; vertical-align: middle;
    }
    .btn-row-del {
        background: #fdecea; border: 1px solid #ef9a9a;
        color: #b71c1c; padding: 2px 8px; cursor: pointer;
        border-radius: 3px; font-size: 11px; font-family: inherit;
        transition: background 0.1s; margin-left: 4px;
    }
    .btn-row-del:hover { background: #ffcdd2; }
</style>
</head>
<script type="text/javascript">
    var editingRowEl = null;

    function editRow(id, usernameVal, userTypeIdVal) {
        if (editingRowEl) editingRowEl.classList.remove('selected-row');
        editingRowEl = document.getElementById('row-' + id);
        if (editingRowEl) editingRowEl.classList.add('selected-row');

        document.getElementById('loginUserId').value  = id;
        document.getElementById('username').value      = usernameVal;
        document.getElementById('selUserTypeId').value = userTypeIdVal;
        document.getElementById('passwrd').value       = '';
        document.getElementById('confirmPasswrd').value = '';
        document.getElementById('curPasswrd').value    = '';

        document.getElementById('rowCurPwdLabel').style.display = '';
        document.getElementById('curPasswrd').style.display      = '';
        document.getElementById('editBanner').style.display = 'block';
        document.getElementById('editBanner').innerText = 'Editing: ' + usernameVal;

        var row = document.getElementById('row-' + id);
        var isAdmin = row && row.getAttribute('data-is-admin') === 'true';
        document.getElementById('username').readOnly           = isAdmin;
        document.getElementById('username').style.background  = isAdmin ? '#f5f5f5' : '';
        document.getElementById('selUserTypeId').disabled    = isAdmin;
        document.getElementById('adminNote').style.display   = isAdmin ? '' : 'none';

        document.getElementById('btnAdd').style.display    = 'none';
        document.getElementById('btnUpdate').style.display = 'inline-block';
        document.getElementById('btnCancel').style.display = 'inline-block';

        document.getElementById('formPanel').scrollIntoView({behavior: 'smooth'});
        document.getElementById('curPasswrd').focus();
    }

    function resetForm() {
        if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
        document.getElementById('loginUserId').value     = '';
        document.getElementById('username').value         = '';
        document.getElementById('selUserTypeId').value   = '';
        document.getElementById('passwrd').value         = '';
        document.getElementById('confirmPasswrd').value  = '';
        document.getElementById('curPasswrd').value      = '';
        document.getElementById('rowCurPwdLabel').style.display = 'none';
        document.getElementById('curPasswrd').style.display     = 'none';
        document.getElementById('editBanner').style.display    = 'none';
        document.getElementById('username').readOnly           = false;
        document.getElementById('username').style.background  = '';
        document.getElementById('selUserTypeId').disabled    = false;
        document.getElementById('adminNote').style.display   = 'none';
        document.getElementById('btnAdd').style.display    = 'inline-block';
        document.getElementById('btnUpdate').style.display = 'none';
        document.getElementById('btnCancel').style.display = 'none';
    }

    function confirmDelete(id, username) {
        if (!confirm('Delete user "' + username + '"? This cannot be undone.')) return;
        document.getElementById('delLoginUserId').value = id;
        document.getElementById('frmDelete').submit();
    }

    function validateForm() {
        var username   = document.getElementById('username').value;
        var pass    = document.getElementById('passwrd').value;
        var cPass   = document.getElementById('confirmPasswrd').value;
        if (pass !== cPass) {
            alert('Password does not match.');
            document.getElementById('confirmPasswrd').value = '';
            document.getElementById('confirmPasswrd').focus();
            return false;
        }
        return true;
    }


</script>
<body>
<%@include file="../../header.jsp" %>

<%
    String msgParam = request.getParameter("msg");
    String errParam = request.getParameter("err");
    String bannerMsg   = null;
    String bannerClass = null;
    if ("registered".equals(msgParam)) { bannerMsg = "User registered successfully."; bannerClass = "success"; }
    else if ("updated".equals(msgParam)) { bannerMsg = "User updated successfully.";  bannerClass = "success"; }
    else if ("deleted".equals(msgParam)) { bannerMsg = "User deleted successfully.";  bannerClass = "success"; }
    else if ("username_exists".equals(errParam))    { bannerMsg = "username ID already exists. Please use a different username."; bannerClass = "error"; }
    else if ("wrong_pwd".equals(errParam))       { bannerMsg = "Current password is incorrect. Update cancelled.";       bannerClass = "error"; }
    else if ("admin_protected".equals(errParam)) { bannerMsg = "Admin user cannot be deleted.";                          bannerClass = "error"; }
%>

<fieldset>
    <legend>Register User</legend>

    <%-- Feedback banner --%>
    <% if (bannerMsg != null) { %>
    <div id="msgBanner" class="<%=bannerClass%>" style="display:block;"><%=bannerMsg%></div>
    <% } else { %>
    <div id="msgBanner"></div>
    <% } %>

    <%-- Main add/edit form --%>
    <form method="post" id="frmRegUser" onsubmit="return validateForm()">
        <input type="hidden" name="loginUserId" id="loginUserId">
        <div id="formPanel" class="form-panel" style="display:block; min-width:400px;">
            <div id="editBanner"></div>
            <div class="form-grid">
                <label for="selUserTypeId">User Type:</label>
                <select name="selUserTypeId" id="selUserTypeId" required>
                    <option value="">--- Select ---</option>
                    <%
                        try {
                            UserTypeService utsvc = new UserTypeService();
                            List<UserTypeEntity> utList = utsvc.fetch();
                            for (UserTypeEntity ute : utList) {
                                if (ute != null) {
                    %>
                    <option value="<%=ute.getUserTypeId()%>"><%=ute.getUserType()%></option>
                    <%      }
                        }
                        } catch (Exception ex) { ex.printStackTrace(); }
                    %>
                </select>

                <label for="username">Username</label>
                <input type="text" name="username" id="username" required
                    pattern="[a-zA-Z0-9._-]+\@[a-zA-Z]+\.[a-z]+"
                    oninvalid="setCustomValidity('Enter a valid Username')"
                    onchange="setCustomValidity('')">

                <label id="rowCurPwdLabel" for="curPasswrd" style="display:none;">Current Password:</label>
                <input type="password" name="curPasswrd" id="curPasswrd" style="display:none;">

                <label for="passwrd">Password:</label>
                <input type="password" name="passwrd" id="passwrd" required>

                <label for="confirmPasswrd">Confirm Password:</label>
                <input type="password" name="confirmPasswrd" id="confirmPasswrd" required>

                <div id="adminNote">Admin account: username and user type are locked. Only password can be changed.</div>

                <div class="form-btns">
                    <input type="submit" class="btn-add"    id="btnAdd"    name="add"    value="Register"
                           onclick="this.form.action='../../RegisterUserController'">
                    <input type="submit" class="btn-update" id="btnUpdate" name="edit"   value="Update"
                           style="display:none" onclick="this.form.action='../../RegisterUserController'">
                    <input type="button" class="btn-cancel" id="btnCancel" value="Cancel"
                           style="display:none" onclick="resetForm()">
                </div>
            </div>
        </div>
    </form>

    <%-- Hidden form for per-row delete button --%>
    <form method="post" id="frmDelete" action="../../RegisterUserController">
        <input type="hidden" name="delete"      value="1">
        <input type="hidden" name="loginUserId" id="delLoginUserId" value="">
    </form>

    <%-- Registered users table --%>
    <table border="1" width="100%" class="tbl-data" cellspacing="0" style="margin-top:14px;">
        <thead>
            <tr>
                <th width="8%">Id</th>
                <th width="25%">User Type</th>
                <th>username / Username</th>
                <th width="18%">Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            try {
                LoginUserService loginUserService = new LoginUserService();
                List<LoginUser> luList = loginUserService.fetch();
                for (LoginUser lu : luList) {
                    if (lu == null) continue;
                    long   luId      = lu.getLoginUserId();
                    String luusername   = lu.getUname()   != null ? lu.getUname() : "";
                    String luType    = (lu.getUserTypeEntity() != null && lu.getUserTypeEntity().getUserType() != null)
                                       ? lu.getUserTypeEntity().getUserType() : "";
                    int    luTypeId  = (lu.getUserTypeEntity() != null) ? lu.getUserTypeEntity().getUserTypeId() : 0;
                    String safeusername = luusername.replace("'", "\\'");
                    boolean isAdminUser = "admin".equalsIgnoreCase(luType);
        %>
            <tr id="row-<%=luId%>" data-is-admin="<%=isAdminUser%>">
                <td><%=luId%></td>
                <td>
                    <%=luType%>
                    <% if (isAdminUser) { %><span class="admin-badge">Admin</span><% } %>
                </td>
                <td><%=luusername%></td>
                <td class="action-cell">
                    <button type="button" class="btn-row-edit"
                        onclick="editRow(<%=luId%>, '<%=safeusername%>', <%=luTypeId%>)">Edit</button>
                    <% if (!isAdminUser) { %>
                    <button type="button" class="btn-row-del"
                        onclick="confirmDelete(<%=luId%>, '<%=safeusername%>')">Delete</button>
                    <% } %>
                </td>
            </tr>
        <%
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        %>
        </tbody>
    </table>

</fieldset>


<%@include file="../../footer.jsp" %>
</body>
</html>
