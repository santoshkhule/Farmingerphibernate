<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.EmployeeInfoService"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%@ include file="../../userPerms.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../../css/style.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<title><%= msg.getString("employee.view_all.fieldset_title") %></title>
<style>
    #bulkBar {
        display: none;
        background: var(--red-lt, #fdecea); border: 1px solid var(--red-bd, #ef9a9a);
        padding: 7px 12px; border-radius: 4px; margin-bottom: 8px; font-size: 12px;
    }
    .btn-view {
        background: var(--green-lt, #e8f5e9); border: 1px solid var(--green-bd, #a5d6a7);
        color: var(--green-dk, #1b5e20); padding: 2px 8px; cursor: pointer;
        border-radius: 3px; font-size: 11px; font-family: inherit;
        transition: background 0.1s;
    }
    .btn-view:hover { background: #c8e6c9; }
    .ps-pill {
        display: inline-block; padding: 2px 8px; border-radius: 8px;
        font-size: 10px; font-weight: 700; white-space: nowrap;
    }
    .ps-Paid    { background: #e8f5e9; color: #1b5e20; }
    .ps-Partial { background: #fff8e1; color: #e65100; }
    .ps-Unpaid  { background: #fdecea; color: #b71c1c; }
    .ps-NoWork  { background: #f5f5f5; color: #757575; }
    .dataTables_wrapper { width: 100%; }
</style>
</head>
<script type="text/javascript">
    function toggleSelectAll(chk) {
        document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = chk.checked; });
        updateBulkBar();
    }

    function updateBulkBar() {
        var checked = document.querySelectorAll('input.rowChk:checked');
        var bar = document.getElementById('bulkBar');
        if (checked.length > 0) {
            bar.style.display = 'block';
            document.getElementById('selCount').innerText = checked.length;
        } else {
            bar.style.display = 'none';
            document.getElementById('chkAll').checked = false;
        }
        var all = document.querySelectorAll('input.rowChk');
        document.getElementById('chkAll').checked = (checked.length === all.length && all.length > 0);
    }

    function deleteSelected() {
        var checked = document.querySelectorAll('input.rowChk:checked');
        if (!checked.length) return;
        if (!confirm('Delete ' + checked.length + ' employee(s)? This cannot be undone.')) return;
        var ids = Array.prototype.map.call(checked, function(c) { return c.value; }).join(',');
        document.getElementById('hdnDeleteIds').value = ids;
        document.getElementById('frmBulkDelete').submit();
    }

    function clearSelection() {
        document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = false; });
        document.getElementById('chkAll').checked = false;
        document.getElementById('bulkBar').style.display = 'none';
    }

    $(document).ready(function() {
        $('#empTable').DataTable({
            columnDefs: [{ orderable: false, targets: [0, 10] }],
            pageLength: 25,
            dom: '<"dt-toolbar"lf>t<"dt-footer"ip>'
        });
    });
</script>
<body>
<%@include file="../../header.jsp" %>
<fieldset><legend><%= msg.getString("employee.view_all.fieldset_title") %></legend>

    <%-- Bulk delete bar --%>
    <div id="bulkBar">
        <span id="selCount">0</span> employee(s) selected &nbsp;
        <% if (_isAdmin || !_hasRolePerms || _perms.contains("employee_view.delete")) { %>
        <button type="button" class="btn-delete" onclick="deleteSelected()"><%= msg.getString("btn.delete") %></button>
        <% } %>
        &nbsp;
        <button type="button" class="btn-cancel" onclick="clearSelection()"><%= msg.getString("btn.clear") %></button>
    </div>

    <%-- Hidden form for bulk delete — multipart to match EmployeeInfoController --%>
    <form id="frmBulkDelete" method="post" enctype="multipart/form-data" action="../../EmployeeInfoController">
        <input type="hidden" name="deleteIds"  id="hdnDeleteIds" value="">
        <input type="hidden" name="deleteBulk" value="1">
    </form>

    <div style="margin-bottom:8px; text-align:right;">
        <% if (_isAdmin || !_hasRolePerms || _perms.contains("employee_add.add")) { %>
        <a href="employeeInfo.jsp" style="text-decoration:none;">
            <button type="button" class="btn-add">+ <%= msg.getString("employee.btn_add_employee") %></button>
        </a>
        <% } %>
    </div>

    <table border="1" width="100%" class="tbl-data" id="empTable" cellspacing="0">
        <thead>
            <tr>
                <th width="3%" title="<%= msg.getString("tbl.col_select_all") %>">
                    <input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)">
                </th>
                <th width="4%"><%= msg.getString("tbl.col_number") %></th>
                <th><%= msg.getString("tbl.col_name") %></th>
                <th width="11%"><%= msg.getString("tbl.col_contact") %></th>
                <th><%= msg.getString("tbl.col_address") %></th>
                <th><%= msg.getString("employee.label_bank_name") %></th>
                <th><%= msg.getString("employee.view_all.tbl_col_acc_no") %></th>
                <th width="9%"><%= msg.getString("employee.view_all.tbl_col_total_amount") %></th>
                <th width="9%"><%= msg.getString("employee.view_all.tbl_col_unpaid") %></th>
                <th width="8%"><%= msg.getString("employee.view_all.tbl_col_pay_status") %></th>
                <th width="13%"><%= msg.getString("tbl.col_actions") %></th>
            </tr>
        </thead>
        <tbody>
        <%
            try {
                EmployeeInfoService employeeInfoService = new EmployeeInfoService();
                PaymentProcessingDao salaryProcessingDao = new PaymentProcessingDao();
                AssignResourceEmployeeToFarmService assignService = new AssignResourceEmployeeToFarmService();
                List<EmployeeInfoEntity> listOfEmployee = employeeInfoService.getListOfEmployee();
                for (EmployeeInfoEntity entity : listOfEmployee) {
                    if (entity == null) continue;
                    int empId = entity.getEmployeeInfoId();
                    double[] amountAdv   = assignService.getTotalAmountAndAdvByEmployeeInfoId(empId);
                    double totalAssigned = amountAdv[0];
                    double totalAdv      = amountAdv[1];
                    double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByEmployeeInfoId(empId);
                    double totalPaid     = totalAdv + totalSalaryPaid;
                    double unpaid        = (totalAssigned - totalPaid) > 0 ? (totalAssigned - totalPaid) : 0;
                    String payStatus, psClass;
                    if (totalAssigned == 0)             { payStatus = msg.getString("employee.view_all.status_no_work"); psClass = "NoWork";  }
                    else if (totalPaid >= totalAssigned) { payStatus = msg.getString("employee.view_all.status_paid");    psClass = "Paid";    }
                    else if (totalPaid > 0)              { payStatus = msg.getString("employee.view_all.status_partial"); psClass = "Partial"; }
                    else                                 { payStatus = msg.getString("employee.view_all.status_unpaid");  psClass = "Unpaid";  }

                    String fullName = "";
                    if (entity.getFirstName()  != null && !entity.getFirstName().isEmpty())  fullName += entity.getFirstName()  + " ";
                    if (entity.getMiddleName() != null && !entity.getMiddleName().isEmpty()) fullName += entity.getMiddleName() + " ";
                    if (entity.getLastName()   != null && !entity.getLastName().isEmpty())   fullName += entity.getLastName();
                    fullName = fullName.trim();
        %>
            <tr>
                <td style="text-align:center;">
                    <input type="checkbox" class="rowChk" value="<%=empId%>" onchange="updateBulkBar()">
                </td>
                <td><%=empId%></td>
                <td><%=fullName%></td>
                <td><%=entity.getContactNo1() != null ? entity.getContactNo1() : ""%></td>
                <td><%=entity.getLocalAddress() != null ? entity.getLocalAddress() : ""%></td>
                <td><%=entity.getBankName() != null ? entity.getBankName() : ""%></td>
                <td><%=entity.getAccountNumber() != null ? entity.getAccountNumber() : ""%></td>
                <td style="text-align:right;"><%=totalAssigned%></td>
                <td style="text-align:right;"><%=unpaid%></td>
                <td style="text-align:center;">
                    <span class="ps-pill ps-<%=psClass%>"><%=payStatus%></span>
                </td>
                <td style="text-align:center; white-space:nowrap;">
                    <% if (_isAdmin || !_hasRolePerms || _perms.contains("employee_view.edit")) { %>
                    <button type="button" class="btn-row-edit"
                        onclick="window.location='employeeInfo.jsp?employeeInfoId=<%=empId%>&mode=edit'"><%= msg.getString("btn.edit") %></button>
                    <% } %>
                    <button type="button" class="btn-view"
                        onclick="window.location='employeeInfo.jsp?employeeInfoId=<%=empId%>&mode=view'">View</button>
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
