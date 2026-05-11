<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@page import="com.san.farm.util.FarmUtility"%>

<%
int taskId = 0;
String workStatus = null, empName = null, assignWorkDate = null;

String fromDateParam   = request.getParameter("fromDate");
String empNameParam    = request.getParameter("empName");
String workStatusParam = request.getParameter("workStatus");
String taskIdParam     = request.getParameter("taskId");

if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
    assignWorkDate = FarmUtility.convertfrom_ddmmyyToyymmdd(fromDateParam.trim());
}
if (empNameParam != null && !empNameParam.trim().isEmpty()) {
    empName = empNameParam.trim();
}
if (workStatusParam != null && !workStatusParam.trim().isEmpty() && !workStatusParam.equals("-1")) {
    workStatus = workStatusParam.trim();
}
if (taskIdParam != null && !taskIdParam.trim().isEmpty() && !taskIdParam.equals("-1")) {
    taskId = Integer.parseInt(taskIdParam.trim());
}
%>

<table border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th>Select</th>
        <th>Sr. No.</th>
        <th>Name</th>
        <th>Date</th>
        <th>Site Name</th>
        <th>Crop Name</th>
        <th>Work Type</th>
        <th>Work Status</th>
        <th>Assign Work</th>
        <th>Amount To Pay</th>
        <th>Paid</th>
        <th>Balance</th>
        <th>Action</th>
    </tr>
    </thead>
    <tbody>

<%
AssignResourceEmployeeToFarmService employeeToFarmService = new AssignResourceEmployeeToFarmService();
SalaryProcessingDao salaryProcessingDao = new SalaryProcessingDao();
List<AssignEmployeeToFarmEntity> employeeToFarmEntities = null;
int cnt = 0;

try {
    StringBuilder query = new StringBuilder("from AssignEmployeeToFarmEntity a");
    List<String> conditions = new ArrayList<String>();

    if (assignWorkDate != null) {
        conditions.add("a.assignWorkDate = '" + Date.valueOf(assignWorkDate) + "'");
    }
    if (workStatus != null) {
        conditions.add("a.workStatus = '" + workStatus + "'");
    }
    if (empName != null) {
        conditions.add("(a.employeeInfoEntity.firstName like '%" + empName + "%'" +
                       " or a.employeeInfoEntity.middleName like '%" + empName + "%'" +
                       " or a.employeeInfoEntity.lastName like '%" + empName + "%')");
    }
    if (taskId > 0) {
        conditions.add("a.assignResourceId in (" +
            "select a2.assignResourceId from AssignEmployeeToFarmEntity a2 " +
            "join a2.listFarmTaskEntities t where t.taskId = " + taskId + ")");
    }

    if (!conditions.isEmpty()) {
        query.append(" where ");
        for (int i = 0; i < conditions.size(); i++) {
            if (i > 0) query.append(" and ");
            query.append(conditions.get(i));
        }
        employeeToFarmEntities = employeeToFarmService.getListOFEmployeeToFarmByQry(query.toString());
    } else {
        employeeToFarmEntities = employeeToFarmService.getListOFEmployeeToFarm();
    }

    for (AssignEmployeeToFarmEntity employeeToFarm : employeeToFarmEntities) {
        if (employeeToFarm != null) {
            cnt++;
%>
    <tr id="rowId<%=cnt%>">
        <td><input type="radio" name="radAssignWorkId"
            value="<%=employeeToFarm.getAssignResourceId()%>"></td>
        <td><%=cnt%></td>
        <td>
            <%
            if (employeeToFarm.getEmployeeInfoEntity() != null) {
                if (employeeToFarm.getEmployeeInfoEntity().getFirstName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName() + " ");
                if (employeeToFarm.getEmployeeInfoEntity().getMiddleName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName() + " ");
                if (employeeToFarm.getEmployeeInfoEntity().getLastName() != null)
                    out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
            }
            %>
        </td>
        <td>
            <%
            if (employeeToFarm.getAssignWorkDate() != null) {
                out.println(FarmUtility.convertfrom_yymmddToddmmyy(
                        employeeToFarm.getAssignWorkDate().toString()));
            }
            %>
        </td>
        <td>
            <%
            if (employeeToFarm.getCropToSiteEntity() != null
                    && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null
                    && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() != null) {
                out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
            }
            %>
        </td>
        <td>
            <%
            if (employeeToFarm.getCropEntity() != null
                    && employeeToFarm.getCropEntity().getCropName() != null) {
                out.println(employeeToFarm.getCropEntity().getCropName());
            }
            %>
        </td>
        <td>
            <%
            if (employeeToFarm.getTypeOfWork() != null) {
                out.println(employeeToFarm.getTypeOfWork());
            }
            %>
        </td>
        <td>
            <%
            if (employeeToFarm.getWorkStatus() != null) {
                out.println(employeeToFarm.getWorkStatus());
            }
            %>
        </td>
        <td>
            <%
            int i = 0;
            for (ConfigFarmTaskEntity task : employeeToFarm.getListFarmTaskEntities()) {
                if (i++ > 0) out.print(", ");
                out.print(task.getTaskName());
            }
            %>
        </td>
        <%
        double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByAssignResourceId(employeeToFarm.getAssignResourceId());
        double totalPaid = employeeToFarm.getAdvPayment() + totalSalaryPaid;
        double balanceAmount = employeeToFarm.getAmount() - totalPaid;
        if (balanceAmount < 0) balanceAmount = 0;
        %>
        <td><%=employeeToFarm.getAmount()%></td>
        <td><%=totalSalaryPaid%></td>
        <td><%=balanceAmount%></td>
        <td style="text-align:center; white-space:nowrap;">
            <button type="button" class="btn-row-edit" onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId()%>,'edit')">Edit</button>
            <button type="button" class="btn-delete" onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId()%>,'delete')">Delete</button>
        </td>
    </tr>
<%
        }
    }
} catch (Exception ex) {
    ex.printStackTrace();
}
%>
    </tbody>
</table>
