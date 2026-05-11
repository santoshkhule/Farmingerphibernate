<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.dao.EmployeeInfoService"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
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
    String fPhotoPath  = emp != null && emp.getEmpPicPath()   != null && !emp.getEmpPicPath().isEmpty()
                         ? emp.getEmpPicPath() : "";
    // empPicPath stores the full absolute path — extract just the filename for URL use
    String fPhotoFileName = "";
    if (!fPhotoPath.isEmpty()) {
        String normalized = fPhotoPath.replace('\\', '/');
        int lastSlash = normalized.lastIndexOf('/');
        fPhotoFileName = lastSlash >= 0 ? normalized.substring(lastSlash + 1) : normalized;
    }

    String pageTitle = isView ? "View Employee" : (isEdit ? "Edit Employee" : "Add Employee");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<title><%=pageTitle%></title>
</head>
<script>
    $(function() {
        <%if (!isView) {%>
        $("#birthDate").datepicker({
            changeMonth : true,
            changeYear  : true,
            dateFormat  : "dd/mm/yy"
        }).val();
        <%}%>
    });
</script>
<script>
    function previewPhoto(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.getElementById('imgPreview');
                var ph  = document.getElementById('photoPlaceholder');
                img.src = e.target.result;
                img.style.display = 'block';
                ph.style.display  = 'none';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>
<body>
<%@include file="../../header.jsp" %>
    <h2><%=pageTitle%></h2>
    <hr>

    <form name="frmAddEmp" action="../../EmployeeInfoController" enctype="multipart/form-data" method="post">
        <input type="hidden" name="employeeInfoId" id="employeeInfoId" value="<%=fEmpId%>">
        <table border=0 style="width: 100%" cellSpacing=0>
            <tr>
                <td rowspan="4" colspan="2" style="text-align:center; vertical-align:top; padding:10px; width:180px;">
                    <%-- Photo preview --%>
                    <img id="imgPreview"
                         src="<%=fPhotoFileName.isEmpty() ? "" : "../../uploads/" + fPhotoFileName%>"
                         style="width:130px; height:155px; object-fit:cover; border:1px solid #aaa; display:<%=fPhotoFileName.isEmpty() ? "none" : "block"%>; margin:0 auto;">
                    <div id="photoPlaceholder"
                         style="width:130px; height:155px; background:#e8e8e8; border:1px solid #aaa;
                                display:<%=fPhotoFileName.isEmpty() ? "flex" : "none"%>;
                                align-items:center; justify-content:center;
                                color:#999; font-size:13px; margin:0 auto;">
                        No Photo
                    </div>
                    <%if (!isView) {%>
                    <div style="margin-top:6px; font-size:12px; color:#555;">Upload Photo:</div>
                    <input type="file" name="fileEmpPhoto" id="fileEmpPhoto" accept="image/*"
                           style="width:140px; font-size:11px; margin-top:3px;"
                           onchange="previewPhoto(this)">
                    <%}%>
                </td>
            </tr>
            <tr>
                <td style="text-align: right; width: 20%; height: 2.0em">First Name:</td>
                <td style="text-align: left;">
                    <input type="text" name="firstName" id="firstName" <%=isAdd?"required":""%> value="<%=fFirst%>" <%=ro%>>
                </td>
            </tr>
            <tr>
                <td style="text-align: right; height: 2.0em">Middle Name:</td>
                <td style="text-align: left;">
                    <input type="text" name="middleName" id="middleName" value="<%=fMiddle%>" <%=ro%>>
                </td>
            </tr>
            <tr>
                <td style="text-align: right; height: 2.0em">Last Name:</td>
                <td style="text-align: left;">
                    <input type="text" name="lastName" id="lastName" <%=isAdd?"required":""%> value="<%=fLast%>" <%=ro%>>
                </td>
            </tr>
            <tr><td colspan="4"><hr></td></tr>
            <tr>
                <td style="text-align: right;">Contact Number1:</td>
                <td style="text-align: left;">
                    <input type="text" name="contactNo1" id="contactNo1" <%=isAdd?"required":""%> value="<%=fContact1%>" <%=ro%>>
                </td>
                <td style="text-align: right;">Contact Number2:</td>
                <td style="text-align: left;">
                    <input type="text" name="contactNo2" id="contactNo2" value="<%=fContact2%>" <%=ro%>>
                </td>
            </tr>
            <tr>
                <td style="text-align: right;">Email Id:</td>
                <td style="text-align: left;">
                    <input type="text" name="emailId" id="emailId" readonly value="<%=fEmail%>">
                </td>
                <td style="text-align: right;">Birth Date:</td>
                <td style="text-align: left;">
                    <input type="text" name="birthDate" id="birthDate" placeholder="dd/mm/yyyy"
                        pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                        oninvalid="setCustomValidity('Select Date From Calendar')"
                        value="<%=fBirthDate%>" <%=ro%>>
                </td>
            </tr>
            <tr>
                <td style="text-align: right; width: 25%">Local Address:</td>
                <td style="text-align: left; width: 10%">
                    <textarea name="localAddress" id="localAddress" <%=isAdd?"required":""%> rows="" cols="20" <%=ro%>><%=fLocal%></textarea>
                </td>
                <td style="text-align: right;">Permanent Address:</td>
                <td style="text-align: left; width: 30%">
                    <textarea name="permanantAddress" id="permanantAddress" <%=isAdd?"required":""%> rows="" cols="20" <%=ro%>><%=fPer%></textarea>
                </td>
            </tr>
            <tr>
                <td style="text-align: right;">Bank Name:</td>
                <td style="text-align: left;">
                    <input type="text" name="bankName" id="bankName" <%=isAdd?"required":""%> value="<%=fBank%>" <%=ro%>>
                </td>
                <td style="text-align: right;">Account Number:</td>
                <td style="text-align: left;">
                    <input type="text" name="accountNumber" id="accountNumber" <%=isAdd?"required":""%> value="<%=fAccNo%>" <%=ro%>>
                </td>
            </tr>
            <tr>
                <td style="text-align: right;">Pan Card No:</td>
                <td style="text-align: left;">
                    <input type="text" name="panCardNo" id="panCardNo" value="<%=fPan%>" <%=ro%>>
                </td>
                <td style="text-align: right;">Comment:</td>
                <td style="text-align: left;">
                    <textarea name="comment" rows="" cols="20" <%=ro%>><%=fComment%></textarea>
                </td>
            </tr>
            <tr>
                <td colspan="5" style="text-align: center;"><br>
                    <%if (isAdd) {%>
                        <input type="submit" name="add" value="Add">
                    <%} else if (isEdit) {%>
                        <input type="submit" name="edit" value="Save">
                        &nbsp;
                        <a href="employeeViewAll.jsp"><button type="button">Cancel</button></a>
                    <%} else {%>
                        <a href="employeeViewAll.jsp"><button type="button">Back to List</button></a>
                    <%}%>
                </td>
            </tr>
        </table>
    </form>
<%@include file="../../footer.jsp" %>
</body>
</html>
