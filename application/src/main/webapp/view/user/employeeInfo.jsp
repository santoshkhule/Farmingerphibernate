<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.dao.EmployeeInfoService"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%@ include file="../../userPerms.jsp" %>
<%
    String mode       = request.getParameter("mode");
    String empIdParam = request.getParameter("employeeInfoId");
    EmployeeInfoEntity emp = null;

    if (empIdParam != null && !empIdParam.trim().isEmpty()) {
        EmployeeInfoService empSvc = new EmployeeInfoService();
        emp = empSvc.getEmployeeById(Integer.parseInt(empIdParam.trim()));
    }
    if (mode == null) {
        mode = (emp != null) ? "edit" : "add";
    }

    boolean isView = "view".equals(mode);
    boolean isEdit = "edit".equals(mode);
    boolean isAdd  = "add".equals(mode);
    String  ro     = isView ? "readonly" : "";

    String fEmpId      = emp != null ? String.valueOf(emp.getEmployeeInfoId()) : "";
    String fFirst      = emp != null && emp.getFirstName()     != null ? emp.getFirstName()     : "";
    String fMiddle     = emp != null && emp.getMiddleName()    != null ? emp.getMiddleName()    : "";
    String fLast       = emp != null && emp.getLastName()      != null ? emp.getLastName()      : "";
    String fContact1   = emp != null && emp.getContactNo1()    != null ? emp.getContactNo1()    : "";
    String fContact2   = emp != null && emp.getContactNo2()    != null ? emp.getContactNo2()    : "";
    String fEmail      = emp != null && emp.getEmailId()       != null ? emp.getEmailId()       : "";
    String fBirthDate  = "";
    if (emp != null && emp.getBirthDate() != null) {
        fBirthDate = FarmUtility.convertfrom_yymmddToddmmyy(emp.getBirthDate().toString());
    }
    String fLocal      = emp != null && emp.getLocalAddress()  != null ? emp.getLocalAddress()  : "";
    String fPer        = emp != null && emp.getPerAddress()    != null ? emp.getPerAddress()     : "";
    String fBank       = emp != null && emp.getBankName()      != null ? emp.getBankName()       : "";
    String fAccNo      = emp != null && emp.getAccountNumber() != null ? emp.getAccountNumber()  : "";
    String fPan        = emp != null && emp.getPanCardNo()     != null ? emp.getPanCardNo()      : "";
    String fComment    = emp != null && emp.getComment()       != null ? emp.getComment()        : "";
    String fPhotoData = emp != null && emp.getEmpPic() != null ? emp.getEmpPic() : "";

    String pageTitle = isView ? msg.getString("employee.fieldset_title_edit")
                              : (isEdit ? msg.getString("employee.fieldset_title_edit")
                                        : msg.getString("employee.fieldset_title_add"));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<title><%= isAdd ? msg.getString("employee.page_title_add") : pageTitle %></title>
</head>
<script>
    var MAX_PHOTO_BYTES = 204800; // 200 KB
    function previewPhoto(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            if (file.size > MAX_PHOTO_BYTES) {
                alert('Photo must be 200 KB or smaller. Selected file is ' + Math.round(file.size / 1024) + ' KB.');
                input.value = '';
                return;
            }
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.getElementById('imgPreview');
                var ph  = document.getElementById('photoPlaceholder');
                img.src = e.target.result;
                img.style.display = 'block';
                ph.style.display  = 'none';
            };
            reader.readAsDataURL(file);
        }
    }
</script>
<body>
<%@include file="../../header.jsp" %>
<script src="../../js/jquery-ui.js"></script>
<script>
    $(function() {
        <%if (!isView) {%>
        $("#birthDate").datepicker({
            changeMonth : true,
            changeYear  : true,
            dateFormat  : "dd/mm/yy"
        });
        <%}%>
    });
</script>
<fieldset><legend><%=pageTitle%></legend>
    <form name="frmAddEmp" action="../../EmployeeInfoController" enctype="multipart/form-data" method="post">
        <input type="hidden" name="employeeInfoId" id="employeeInfoId" value="<%=fEmpId%>">

        <div style="display:flex; gap:16px; align-items:flex-start; flex-wrap:wrap;">

            <!-- Photo column -->
            <div style="flex-shrink:0; text-align:center; padding:8px;">
                <img id="imgPreview"
                     src="<%=fPhotoData.isEmpty() ? "" : fPhotoData%>"
                     style="width:130px; height:155px; object-fit:cover; border:2px solid var(--green-bd); border-radius:4px; display:<%=fPhotoData.isEmpty() ? "none" : "block"%>; margin:0 auto;">
                <div id="photoPlaceholder"
                     style="width:130px; height:155px; background:var(--green-lt); border:2px solid var(--green-bd); border-radius:4px;
                            display:<%=fPhotoData.isEmpty() ? "flex" : "none"%>;
                            align-items:center; justify-content:center;
                            color:var(--green-md); font-size:13px; margin:0 auto; flex-direction:column; gap:6px;">
                    <span style="font-size:32px;">&#128100;</span>
                    <span>No Photo</span>
                </div>
                <%if (!isView) {%>
                <div style="margin-top:8px; font-size:11px; color:var(--text-muted); font-weight:600;">Upload Photo</div>
                <input type="file" name="fileEmpPhoto" id="fileEmpPhoto" accept="image/*"
                       style="width:140px; font-size:11px; margin-top:4px;"
                       onchange="previewPhoto(this)">
                <div style="font-size:10px; color:var(--text-muted); margin-top:3px;">Max 200 KB</div>
                <%}%>
            </div>

            <!-- Form fields -->
            <div id="formPanel" style="flex:1; min-width:340px; display:inline-block;">

                <div style="display:flex; gap:12px; flex-wrap:wrap;">
                    <!-- Left column -->
                    <div style="flex:1; min-width:260px;">
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_first_name") %>:</label>
                            <input type="text" name="firstName" id="firstName" <%=isAdd?"required":""%> value="<%=fFirst%>" <%=ro%> placeholder="<%= msg.getString("employee.label_first_name") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_middle_name") %>:</label>
                            <input type="text" name="middleName" id="middleName" value="<%=fMiddle%>" <%=ro%> placeholder="<%= msg.getString("employee.label_middle_name") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_last_name") %>:</label>
                            <input type="text" name="lastName" id="lastName" <%=isAdd?"required":""%> value="<%=fLast%>" <%=ro%> placeholder="<%= msg.getString("employee.label_last_name") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_contact1") %>:</label>
                            <input type="text" name="contactNo1" id="contactNo1" <%=isAdd?"required":""%> value="<%=fContact1%>" <%=ro%> placeholder="<%= msg.getString("employee.label_contact1") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_contact2") %>:</label>
                            <input type="text" name="contactNo2" id="contactNo2" value="<%=fContact2%>" <%=ro%> placeholder="<%= msg.getString("employee.label_contact2") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_email") %>:</label>
                            <input type="email" name="emailId" id="emailId" <%=ro%> maxlength="100" value="<%=fEmail%>" placeholder="user@example.com">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_birth_date") %>:</label>
                            <input type="text" name="birthDate" id="birthDate" placeholder="dd/mm/yyyy"
                                pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                                oninvalid="setCustomValidity('Select Date From Calendar')"
                                value="<%=fBirthDate%>" <%=ro%>>
                        </div>
                    </div>
                    <!-- Right column -->
                    <div style="flex:1; min-width:260px;">
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_local_address") %>:</label>
                            <textarea name="localAddress" id="localAddress" <%=isAdd?"required":""%> rows="3" style="width:210px; resize:vertical;" <%=ro%>><%=fLocal%></textarea>
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_permanent_address") %>:</label>
                            <textarea name="permanantAddress" id="permanantAddress" <%=isAdd?"required":""%> rows="3" style="width:210px; resize:vertical;" <%=ro%>><%=fPer%></textarea>
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_bank_name") %>:</label>
                            <input type="text" name="bankName" id="bankName" <%=isAdd?"required":""%> value="<%=fBank%>" <%=ro%> placeholder="<%= msg.getString("employee.label_bank_name") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_account_number") %>:</label>
                            <input type="text" name="accountNumber" id="accountNumber" <%=isAdd?"required":""%> value="<%=fAccNo%>" <%=ro%> placeholder="<%= msg.getString("employee.label_account_number") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_pan_card") %>:</label>
                            <input type="text" name="panCardNo" id="panCardNo" value="<%=fPan%>" <%=ro%> placeholder="<%= msg.getString("employee.label_pan_card") %>">
                        </div>
                        <div class="form-row">
                            <label><%= msg.getString("employee.label_comment") %>:</label>
                            <textarea name="comment" rows="3" style="width:210px; resize:vertical;" <%=ro%>><%=fComment%></textarea>
                        </div>
                    </div>
                </div>

                <div class="form-btns" style="margin-top:14px;">
                    <%if (isAdd) {%>
                        <% if (_isAdmin || !_hasRolePerms || _perms.contains("employee_add.add")) { %>
                        <input type="submit" class="btn-add" name="add" value="<%= msg.getString("employee.btn_add_employee") %>">
                        <% } %>
                    <%} else if (isEdit) {%>
                        <% if (_isAdmin || !_hasRolePerms || _perms.contains("employee_add.edit")) { %>
                        <input type="submit" class="btn-update" name="edit" value="<%= msg.getString("employee.btn_save_changes") %>">
                        <% } %>
                        &nbsp;
                        <a href="employeeViewAll.jsp"><button type="button" class="btn-cancel"><%= msg.getString("btn.cancel") %></button></a>
                    <%} else {%>
                        <a href="employeeViewAll.jsp"><button type="button" class="btn-action">&#8592; <%= msg.getString("btn.back") %></button></a>
                    <%}%>
                </div>

            </div><!-- end formPanel -->
        </div><!-- end flex row -->
    </form>
</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
