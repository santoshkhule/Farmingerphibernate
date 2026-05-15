<%@page import="com.san.farm.login.dao.LoginUserService"%>
<%@page import="com.san.farm.login.entity.LoginUser"%>
<%@page import="com.san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="com.san.farm.adminuser.dao.UserTypeService"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%!
    /* Returns inline-style background/border/color for a given role name. */
    private String[] roleColors(String typeName) {
        if (typeName == null) return new String[]{"#e8eaf6","#7986cb","#1a237e"};
        if ("Admin".equalsIgnoreCase(typeName))           return new String[]{"#fff3cd","#ffc107","#856404"};
        if ("Owner".equalsIgnoreCase(typeName))           return new String[]{"#ede7f6","#ce93d8","#4527a0"};
        if ("Farm Manager".equalsIgnoreCase(typeName))    return new String[]{"#e3f2fd","#90caf9","#0d47a1"};
        if ("Site Supervisor".equalsIgnoreCase(typeName)) return new String[]{"#e0f2f1","#80cbc4","#004d40"};
        if ("Accountant".equalsIgnoreCase(typeName))      return new String[]{"#fff8e1","#ffe082","#e65100"};
        if ("Field Worker".equalsIgnoreCase(typeName))    return new String[]{"#e8f5e9","#a5d6a7","#1b5e20"};
        if ("Viewer".equalsIgnoreCase(typeName))          return new String[]{"#f5f5f5","#bdbdbd","#616161"};
        return new String[]{"#e8eaf6","#7986cb","#1a237e"};
    }
%>
<%
    String msgParam = request.getParameter("msg");
    String errParam = request.getParameter("err");
    String bannerMsg   = null;
    String bannerClass = null;
    if ("registered".equals(msgParam))         { bannerMsg = "User registered successfully.";                                       bannerClass = "banner-ok"; }
    else if ("updated".equals(msgParam))        { bannerMsg = "User updated successfully.";                                          bannerClass = "banner-ok"; }
    else if ("deleted".equals(msgParam))        { bannerMsg = "User deleted successfully.";                                          bannerClass = "banner-ok"; }
    else if ("username_exists".equals(errParam)){ bannerMsg = "Username already exists. Please choose a different username.";        bannerClass = "banner-err"; }
    else if ("admin_protected".equals(errParam)){ bannerMsg = "Admin user cannot be deleted.";                                      bannerClass = "banner-err"; }

    List<UserTypeEntity> utList = new ArrayList<UserTypeEntity>();
    try { utList = new UserTypeService().fetch(); } catch (Exception ex) { ex.printStackTrace(); }

    List<LoginUser> luList = new ArrayList<LoginUser>();
    try { luList = new LoginUserService().fetch(); } catch (Exception ex) { ex.printStackTrace(); }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Register User</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<style>
    /* ── Banners ───────────────────────────────────────────────── */
    .banner-ok  { background:#e8f5e9; border:1px solid #a5d6a7; color:#1b5e20; padding:7px 14px; border-radius:4px; margin-bottom:12px; font-size:12px; font-weight:600; }
    .banner-err { background:#fdecea; border:1px solid #ef9a9a; color:#b71c1c; padding:7px 14px; border-radius:4px; margin-bottom:12px; font-size:12px; font-weight:600; }

    /* ── Form card (matches addBuyer.jsp) ──────────────────────── */
    .form-card {
        background:#f9fbe7; border:1px solid #a5d6a7;
        border-radius:6px; padding:16px 20px; margin-bottom:18px;
    }
    .form-card-title {
        font-size:12px; font-weight:700; color:#1b5e20;
        text-transform:uppercase; letter-spacing:.5px; margin-bottom:12px;
        padding-bottom:6px; border-bottom:1px solid #a5d6a7;
    }
    .edit-notice {
        background:#fff8e1; border:1px solid #ffe082; color:#5d4037;
        padding:4px 10px; border-radius:3px; margin-bottom:10px;
        font-size:11px; font-weight:700; display:none;
    }
    .field-grid {
        display:grid; grid-template-columns:repeat(2, 1fr); gap:10px 24px; align-items:end;
    }
    .field-group { display:flex; flex-direction:column; gap:3px; }
    .field-group label { font-size:11px; font-weight:600; color:#424242; }
    .field-group input[type=text],
    .field-group input[type=password] {
        padding:5px 9px; border:1px solid #bdbdbd; border-radius:3px;
        font-size:12px; font-family:inherit; outline:none; width:100%;
        box-sizing:border-box; transition:border-color .15s, box-shadow .15s;
    }
    .field-group input:focus {
        border-color:#1976d2; box-shadow:0 0 0 2px rgba(25,118,210,.12);
    }
    .field-group input[readonly] { background:#f5f5f5; color:#757575; cursor:not-allowed; }
    .field-full  { grid-column:1 / -1; }
    .form-btns   { grid-column:1 / -1; display:flex; gap:8px; margin-top:6px; }

    /* ── Admin notice banner inside form ───────────────────────── */
    #adminNotice {
        display:none; grid-column:1 / -1;
        background:#fff3cd; border:1px solid #ffc107; color:#856404;
        padding:6px 12px; border-radius:4px; font-size:11px; font-weight:600;
    }

    /* ── Roles section ─────────────────────────────────────────── */
    .roles-section { grid-column:1 / -1; }
    .roles-label { font-size:11px; font-weight:600; color:#424242; margin-bottom:6px; display:block; }
    .roles-row { display:flex; flex-wrap:wrap; gap:8px; }
    .role-item label {
        display:flex; align-items:center; gap:5px;
        padding:5px 12px; border-radius:16px; border:1.5px solid #bdbdbd;
        background:#f5f5f5; color:#757575; cursor:pointer; font-size:11px; font-weight:600;
        transition:background .15s, border-color .15s, color .15s, box-shadow .15s;
        user-select:none;
    }
    .role-item label:hover { box-shadow:0 2px 6px rgba(0,0,0,.18); filter:brightness(.97); }
    .role-item input[type=checkbox] { display:none; }
    .role-item label.chk-active { box-shadow:0 2px 8px rgba(0,0,0,.22); }
    .role-item label.chk-disabled { opacity:.5; cursor:not-allowed; pointer-events:none; }
    /* checkmark shown only when active */
    .role-chk-mark { display:none; font-weight:900; font-size:12px; line-height:1; }
    .chk-active .role-chk-mark { display:inline; }

    /* ── Users table ────────────────────────────────────────────── */
    .tbl-data td, .tbl-data th { vertical-align:middle; }
    .tbl-data td.action-cell { text-align:center; white-space:nowrap; }
    .role-pill {
        display:inline-block; font-size:10px; font-weight:700;
        padding:2px 9px; border-radius:10px; border:1px solid #bdbdbd;
        margin:1px 2px;
    }
    .admin-badge {
        display:inline-block; background:#fff3cd; border:1px solid #ffc107;
        color:#856404; font-size:10px; font-weight:700;
        padding:1px 7px; border-radius:8px; margin-left:4px; vertical-align:middle;
    }
    .btn-row-del {
        background:#fdecea; border:1px solid #ef9a9a; color:#b71c1c;
        padding:2px 9px; cursor:pointer; border-radius:3px;
        font-size:11px; font-family:inherit; transition:background .1s; margin-left:4px;
    }
    .btn-row-del:hover { background:#ffcdd2; }
</style>
<script type="text/javascript">
    var editingRowEl = null;
    var currentEditIsAdmin = false;

    /* Toggle role pill color: apply data-* colors when checked, grey when unchecked. */
    function updateChkStyles() {
        var chks = document.querySelectorAll('.type-chk');
        for (var i = 0; i < chks.length; i++) {
            var lbl = chks[i].parentElement;
            if (chks[i].checked) {
                lbl.classList.add('chk-active');
                lbl.style.background   = lbl.getAttribute('data-bg');
                lbl.style.borderColor  = lbl.getAttribute('data-border');
                lbl.style.color        = lbl.getAttribute('data-color');
            } else {
                lbl.classList.remove('chk-active');
                lbl.style.background  = '';
                lbl.style.borderColor = '';
                lbl.style.color       = '';
            }
        }
    }

    /* Populate and show the edit form. */
    function editRow(id, usernameVal, typeIdsStr, isAdm) {
        currentEditIsAdmin = isAdm;
        if (editingRowEl) editingRowEl.classList.remove('selected-row');
        editingRowEl = document.getElementById('row-' + id);
        if (editingRowEl) editingRowEl.classList.add('selected-row');

        document.getElementById('loginUserId').value = id;
        document.getElementById('username').value    = usernameVal;
        document.getElementById('passwrd').value     = '';
        document.getElementById('confirmPasswrd').value = '';

        /* Uncheck all, then check matching IDs. */
        var chks = document.querySelectorAll('.type-chk');
        for (var i = 0; i < chks.length; i++) {
            chks[i].checked = false;
            chks[i].disabled = false;
            chks[i].parentElement.classList.remove('chk-disabled');
        }
        if (typeIdsStr && typeIdsStr.length > 0) {
            var ids = typeIdsStr.split(',');
            for (var j = 0; j < ids.length; j++) {
                var el = document.getElementById('typeChk_' + ids[j].trim());
                if (el) el.checked = true;
            }
        }

        /* Lock roles and username if admin. */
        if (isAdm) {
            document.getElementById('username').readOnly = true;
            for (var k = 0; k < chks.length; k++) {
                chks[k].disabled = true;
                chks[k].parentElement.classList.add('chk-disabled');
            }
            document.getElementById('adminNotice').style.display = '';
        } else {
            document.getElementById('username').readOnly = false;
            document.getElementById('adminNotice').style.display = 'none';
        }
        updateChkStyles();

        /* Swap buttons. */
        document.getElementById('btnAdd').style.display    = 'none';
        document.getElementById('btnUpdate').style.display = '';
        document.getElementById('btnCancel').style.display = '';

        /* Edit notice. */
        var notice = document.getElementById('editNotice');
        notice.innerText = 'Editing: ' + usernameVal;
        notice.style.display = 'block';

        document.getElementById('formCard').scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        document.getElementById('passwrd').focus();
    }

    /* Reset form to add-mode defaults. */
    function resetForm() {
        currentEditIsAdmin = false;
        if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
        document.getElementById('loginUserId').value    = '';
        document.getElementById('username').value        = '';
        document.getElementById('passwrd').value         = '';
        document.getElementById('confirmPasswrd').value  = '';
        document.getElementById('username').readOnly     = false;

        var chks = document.querySelectorAll('.type-chk');
        for (var i = 0; i < chks.length; i++) {
            chks[i].checked  = false;
            chks[i].disabled = false;
            chks[i].parentElement.classList.remove('chk-disabled');
        }
        updateChkStyles();

        document.getElementById('adminNotice').style.display   = 'none';
        document.getElementById('editNotice').style.display    = 'none';
        document.getElementById('btnAdd').style.display        = '';
        document.getElementById('btnUpdate').style.display     = 'none';
        document.getElementById('btnCancel').style.display     = 'none';
        document.getElementById('formCard').scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    /* Validate before submit. */
    function validateForm() {
        var pass  = document.getElementById('passwrd').value;
        var cPass = document.getElementById('confirmPasswrd').value;
        if (pass !== cPass) {
            alert('New password and Confirm password do not match.');
            document.getElementById('confirmPasswrd').value = '';
            document.getElementById('confirmPasswrd').focus();
            return false;
        }
        /* If not editing the admin, at least one role must be selected. */
        if (!currentEditIsAdmin) {
            var chks = document.querySelectorAll('.type-chk');
            var anyChecked = false;
            for (var i = 0; i < chks.length; i++) {
                if (chks[i].checked) { anyChecked = true; break; }
            }
            if (!anyChecked) {
                alert('Please select at least one role.');
                return false;
            }
        }
        return true;
    }

    function confirmDelete(id, username) {
        if (!confirm('Delete user "' + username + '"? This cannot be undone.')) return;
        document.getElementById('delLoginUserId').value = id;
        document.getElementById('frmDelete').submit();
    }

    window.onload = function() { updateChkStyles(); };
</script>
</head>
<body>
<%@include file="../../header.jsp" %>

<% if (bannerMsg != null) { %>
<div class="<%=bannerClass%>"><%=bannerMsg%></div>
<% } %>

<fieldset>
<legend>Register User</legend>

<!-- ── Add / Edit form ── -->
<div class="form-card" id="formCard">
    <div class="form-card-title" id="formCardTitle">Add New User</div>
    <div class="edit-notice" id="editNotice"></div>

    <form method="post" id="frmRegUser" onsubmit="return validateForm()">
        <input type="hidden" name="loginUserId" id="loginUserId">
        <div class="field-grid">

            <!-- Username -->
            <div class="field-group">
                <label for="username">Username *</label>
                <input type="text" name="username" id="username" required maxlength="100">
            </div>

            <!-- Spacer to keep grid aligned -->
            <div class="field-group"></div>

            <!-- Roles: full-width checkbox pills -->
            <div class="roles-section field-full">
                <span class="roles-label">Roles *</span>
                <div class="roles-row">
                <%
                    for (UserTypeEntity ute : utList) {
                        if (ute == null) continue;
                        String tName = ute.getUserType() != null ? ute.getUserType() : "";
                        int    tId   = ute.getUserTypeId();
                        String[] clr = roleColors(tName);
                %>
                    <span class="role-item">
                        <label for="typeChk_<%=tId%>"
                               data-bg="<%=clr[0]%>" data-border="<%=clr[1]%>" data-color="<%=clr[2]%>">
                            <span class="role-chk-mark">&#10003;</span>
                            <input type="checkbox" class="type-chk"
                                   name="userTypeIds" value="<%=tId%>"
                                   id="typeChk_<%=tId%>"
                                   onchange="updateChkStyles()">
                            <%=tName%>
                        </label>
                    </span>
                <%  } %>
                </div>
            </div>

            <!-- Admin notice (shown only when editing admin) -->
            <div id="adminNotice" class="field-full">
                Admin account: username and roles are locked &mdash; only password can be changed.
            </div>

            <!-- New Password -->
            <div class="field-group">
                <label for="passwrd">New Password *</label>
                <input type="password" name="passwrd" id="passwrd" required>
            </div>

            <!-- Confirm Password -->
            <div class="field-group">
                <label for="confirmPasswrd">Confirm Password *</label>
                <input type="password" name="confirmPasswrd" id="confirmPasswrd" required>
            </div>

            <!-- Buttons -->
            <div class="form-btns">
                <input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="Register"
                       onclick="this.form.action='../../RegisterUserController'">
                <input type="submit" class="btn-update" id="btnUpdate" name="edit" value="Update"
                       style="display:none" onclick="this.form.action='../../RegisterUserController'">
                <input type="button" class="btn-cancel" id="btnCancel" value="Cancel"
                       style="display:none" onclick="resetForm()">
            </div>

        </div><!-- /.field-grid -->
    </form>
</div><!-- /.form-card -->

<!-- Hidden delete form -->
<form method="post" id="frmDelete" action="../../RegisterUserController">
    <input type="hidden" name="delete"      value="1">
    <input type="hidden" name="loginUserId" id="delLoginUserId" value="">
</form>

<!-- ── Users table ── -->
<table border="1" width="100%" class="tbl-data" cellspacing="0" style="margin-top:8px;">
    <thead>
        <tr>
            <th width="4%">#</th>
            <th width="22%">Username</th>
            <th>Roles</th>
            <th width="14%">Actions</th>
        </tr>
    </thead>
    <tbody>
    <%
        int cnt = 0;
        for (LoginUser lu : luList) {
            if (lu == null) continue;
            cnt++;
            long   luId     = lu.getLoginUserId();
            String luUname  = lu.getUname() != null ? lu.getUname() : "";
            boolean isAdm   = "admin".equalsIgnoreCase(luUname);
            String safeUname = luUname.replace("'", "\\'");

            /* Build comma-separated typeIds string for JS. */
            StringBuilder typeIdsSb = new StringBuilder();
            StringBuilder rolesHtml = new StringBuilder();
            List<UserTypeEntity> luTypes = lu.getUserTypes();
            if (luTypes != null) {
                for (int ti = 0; ti < luTypes.size(); ti++) {
                    UserTypeEntity lt = luTypes.get(ti);
                    if (lt == null) continue;
                    if (typeIdsSb.length() > 0) typeIdsSb.append(',');
                    typeIdsSb.append(lt.getUserTypeId());

                    String ltName = lt.getUserType() != null ? lt.getUserType() : "";
                    String[] lc = roleColors(ltName);
                    rolesHtml.append("<span class=\"role-pill\" style=\"background:")
                             .append(lc[0]).append(";border-color:").append(lc[1])
                             .append(";color:").append(lc[2]).append(";\">")
                             .append(ltName).append("</span>");
                }
            }
    %>
        <tr id="row-<%=luId%>" data-is-admin="<%=isAdm%>">
            <td><%=cnt%></td>
            <td>
                <%=luUname%>
                <% if (isAdm) { %><span class="admin-badge">&#128274; Admin</span><% } %>
            </td>
            <td><%=rolesHtml.toString()%></td>
            <td class="action-cell">
                <button type="button" class="btn-row-edit"
                    onclick="editRow(<%=luId%>, '<%=safeUname%>', '<%=typeIdsSb.toString()%>', <%=isAdm%>)">Edit</button>
                <% if (!isAdm) { %>
                <button type="button" class="btn-row-del"
                    onclick="confirmDelete(<%=luId%>, '<%=safeUname%>')">Delete</button>
                <% } %>
            </td>
        </tr>
    <%  } %>
    </tbody>
</table>

</fieldset>

<%@include file="../../footer.jsp" %>
</body>
</html>
