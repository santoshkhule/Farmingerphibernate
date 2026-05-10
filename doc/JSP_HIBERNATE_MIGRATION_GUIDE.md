# JSP to Hibernate ORM Migration Guide

This guide captures the learnings from migrating `assignTaskToEmployeeSingleView.jsp`
from raw JDBC to Hibernate ORM within the FarmingERP project.

---

## Problem Pattern

JSPs written against the old package structure (`farm.*`) and raw JDBC break after
the Maven migration because:

1. The package root changed from `farm.*` to `com.san.farm.*`
2. The `DBfactory` connection helper class no longer exists — the project uses Hibernate
3. Table names and column structures changed (old: `ASSIGNWORK`, new: `AssignEmployeeToFarm`)

---

## Import Fix Cheatsheet

| Old (pre-Maven) | New (post-Maven) |
|---|---|
| `farm.util.FarmUtility` | `com.san.farm.util.FarmUtility` |
| `farm.connection.DBfactory` | _(removed — use Hibernate session)_ |

---

## Entity-to-Table Map (Quick Reference)

| Old SQL Table | Hibernate Entity | Mapped Table |
|---|---|---|
| `ASSIGNWORK` | `AssignEmployeeToFarmEntity` | `AssignEmployeeToFarm` |
| `EMPLOYEEINFORMATION` | `EmployeeInfoEntity` | `authemployeeinfo` |
| `FIELDINFO` | `ConfigSiteInformationEntity` | `SiteInformation` |
| `CROPSINFIELD` | `ConfigCropEntity` | `crops` |
| `WORKTYPE` / `EMPASSIGNWORK` | `ConfigFarmTaskEntity` (ManyToMany) | `FarmTask` / `AssignTaskTOEmployee` |
| `EMPSALTRANSACTION` | `SalaryProcessingEntity` | `salaryTransactions` |
| `EMPASSIGNFIELD` junction | `AssignCropToSiteEntity` (ManyToOne on assignment) | `assigncroptoSite` |

---

## Relationship Navigation

Starting from `AssignEmployeeToFarmEntity`:

```
AssignEmployeeToFarmEntity
 ├── getEmployeeInfoEntity()           → EmployeeInfoEntity
 │     ├── getFirstName()
 │     ├── getMiddleName()
 │     └── getLastName()
 ├── getCropToSiteEntity()             → AssignCropToSiteEntity
 │     └── getSiteInformationEntity()  → ConfigSiteInformationEntity
 │           └── getSiteName()
 ├── getCropEntity()                   → ConfigCropEntity
 │     └── getCropName()
 ├── getListFarmTaskEntities()         → List<ConfigFarmTaskEntity>  ⚠ LAZY
 │     └── getTaskName()
 ├── getAssignWorkDate()               → java.sql.Date
 ├── getTypeOfWork()
 ├── getAmount()
 ├── getAdvPayment()
 ├── getWorkStatus()
 └── getComment()
```

Salary transactions are on the **other side** of the relationship — query separately:
```
SalaryProcessingEntity.getEmployeeToFarm() → AssignEmployeeToFarmEntity
```

---

## Migration Steps

### 1. Fix imports

Replace old JDBC imports with Hibernate entity imports:

```jsp
<%@page import="com.san.farm.util.HibernateUtil"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.SalaryProcessingEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
```

### 2. Load the root entity with SELECT DISTINCT + JOIN FETCH for LAZY collections

`listFarmTaskEntities` is `FetchType.LAZY`. Without `JOIN FETCH` you will get a
`LazyInitializationException` after the session closes. All `ManyToOne` fields are
EAGER by default and do not need special handling.

**Never use `uniqueResult()` with `LEFT JOIN FETCH` on a collection.**
`LEFT JOIN FETCH` produces one SQL row per collection element — if an assignment has
3 tasks, the result set has 3 rows. `uniqueResult()` throws `NonUniqueResultException`
when it sees more than one row. The exception is silently swallowed in a catch block,
so the entity is never set and the page shows a blank/not-found state with no visible error.

Use `SELECT DISTINCT` + `getResultList()` instead. `DISTINCT` deduplicates at the
entity level (not SQL level), so the list always contains one root entity regardless
of how many collection elements it has.

```java
Session hibSession = HibernateUtil.opensession();

List<AssignEmployeeToFarmEntity> results = hibSession.createQuery(
    "SELECT DISTINCT a FROM AssignEmployeeToFarmEntity a " +
    "LEFT JOIN FETCH a.listFarmTaskEntities " +
    "WHERE a.assignResourceId = :id",
    AssignEmployeeToFarmEntity.class)
    .setParameter("id", assignWorkId)
    .getResultList();

AssignEmployeeToFarmEntity assignment = results.isEmpty() ? null : results.get(0);
```

### 3. Query related collections via HQL (not joins)

For entities that have a FK pointing back to the root (like salary transactions),
use a separate HQL query rather than navigating a collection:

```java
List<SalaryProcessingEntity> salaryList = hibSession.createQuery(
    "FROM SalaryProcessingEntity s WHERE s.employeeToFarm.assignResourceId = :id",
    SalaryProcessingEntity.class)
    .setParameter("id", assignWorkId)
    .list();
```

### 4. Close session before rendering HTML

Once all LAZY collections are initialized via `JOIN FETCH`, close the session
before the HTML rendering block. This avoids holding a DB connection open
during template rendering.

```java
} finally {
    if (hibSession != null && hibSession.isOpen()) {
        hibSession.close();
    }
}
// safe to render — all data is in memory
```

### 5. Format dates with SimpleDateFormat

Old code passed a raw DB string to `FarmUtility.convertfrom_yymmddToddmmyy(String)`.
Hibernate gives you a `java.sql.Date` directly — format it yourself:

```java
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
out.print(sdf.format(assignment.getAssignWorkDate()));
```

---

## Common Pitfalls

| Pitfall | Cause | Fix |
|---|---|---|
| `LazyInitializationException` | Accessing a LAZY collection after session closes | Add `LEFT JOIN FETCH` to the HQL query |
| Page shows blank/not-found with no error | `uniqueResult()` throws `NonUniqueResultException` (silently caught) when JOIN FETCH returns multiple rows | Use `SELECT DISTINCT` + `getResultList().get(0)` — never `uniqueResult()` with a collection JOIN FETCH |
| `Only a type can be imported` | Import points to a package, not a class | Use the full `com.san.farm.*` package path |
| `DBfactory cannot be resolved` | Class removed in Maven migration | Use `HibernateUtil.opensession()` |
| `NullPointerException` on navigation | ManyToOne FK is null in DB | Null-check before navigating: `if (x != null)` |
| Connection leak | Session not closed on exception | Always close session in a `finally` block |

---

## MVC Pattern — Keep Hibernate Out of JSPs

All Hibernate session handling and data loading belongs in the servlet controller,
not in the JSP. JSPs should only read pre-loaded data from request attributes and
render HTML.

### Controller responsibility

```java
// 1. Open session
Session hibSession = HibernateUtil.opensession();

// 2. Query with SELECT DISTINCT + JOIN FETCH for LAZY collections
List<AssignEmployeeToFarmEntity> results = hibSession.createQuery(
    "SELECT DISTINCT a FROM AssignEmployeeToFarmEntity a " +
    "LEFT JOIN FETCH a.listFarmTaskEntities " +
    "WHERE a.assignResourceId = :id",
    AssignEmployeeToFarmEntity.class)
    .setParameter("id", assignWorkId)
    .getResultList();
AssignEmployeeToFarmEntity assignment = results.isEmpty() ? null : results.get(0);

// 3. Compute derived values (totals, balances, formatted dates)
double ttlTransactionPaid = ...;
double balanceAmount = ...;
String formattedDate = new SimpleDateFormat("dd/MM/yyyy").format(assignment.getAssignWorkDate());

// 4. Set everything as request attributes
request.setAttribute("assignment", assignment);
request.setAttribute("ttlTransactionPaid", ttlTransactionPaid);
request.setAttribute("balanceAmount", balanceAmount);
request.setAttribute("formattedDate", formattedDate);

// 5. Close session BEFORE forwarding — all EAGER and JOIN FETCHed data is in memory
hibSession.close();

// 6. Forward to JSP
request.getRequestDispatcher("/view/user/assignTaskToEmployeeSingleView.jsp").forward(request, response);
```

### JSP responsibility

```jsp
<%-- Only cast and render — zero Hibernate, zero business logic --%>
<%
AssignEmployeeToFarmEntity assignment = (AssignEmployeeToFarmEntity) request.getAttribute("assignment");
double balanceAmount = (Double) request.getAttribute("balanceAmount");
String formattedDate = (String) request.getAttribute("formattedDate");
%>
<%= assignment.getEmployeeInfoEntity().getFirstName() %>
<%= formattedDate %>
<%= balanceAmount %>
```

### Routing in the servlet

Route by detecting the action parameter before delegating:

```java
protected void doPost(HttpServletRequest request, HttpServletResponse response) {
    if (request.getParameter("sbtView") != null) {
        doView(request, response);   // load + forward to view JSP
    } else {
        doProcess(request, response); // insert / delete + redirect
    }
}
```

### Form action wiring

The form in the listing JSP must point to the controller, not the view JSP directly:

```html
<%-- Wrong: bypasses controller, JSP has no data --%>
<input type="submit" name="sbtView" value="View"
    onclick="this.form.action='assignTaskToEmployeeSingleView.jsp'">

<%-- Correct: controller loads data, forwards to JSP --%>
<input type="submit" name="sbtView" value="View"
    onclick="this.form.action='../../AssignResourcesController'">
```

---

## Fetch Type Reference for This Project

| Relationship | Field | Fetch Type | Action needed |
|---|---|---|---|
| `AssignEmployeeToFarmEntity → EmployeeInfoEntity` | `employeeInfoEntity` | EAGER (default ManyToOne) | None |
| `AssignEmployeeToFarmEntity → AssignCropToSiteEntity` | `cropToSiteEntity` | EAGER (default ManyToOne) | None |
| `AssignCropToSiteEntity → ConfigSiteInformationEntity` | `siteInformationEntity` | EAGER (default ManyToOne) | None |
| `AssignEmployeeToFarmEntity → ConfigCropEntity` | `cropEntity` | EAGER (default ManyToOne) | None |
| `AssignEmployeeToFarmEntity → ConfigFarmTaskEntity` | `listFarmTaskEntities` | **LAZY** (explicit) | `LEFT JOIN FETCH` |
| `AssignCropToSiteEntity → AssignCropToSiteRefEntity` | `cropToSiteRefEntity` | EAGER (explicit) | None |
| `SalaryProcessingEntity → AssignEmployeeToFarmEntity` | `employeeToFarm` | EAGER (default ManyToOne) | None |

---

## Salary Processing — Known Bugs and Fixes

### 1. Parameter name mismatch causes amount saved as 0

The form field is named `txtAmount` but the servlet was reading `request.getParameter("amount")`.
Since the parameter is never found, `amount` stays `0.0` and is silently saved.

```java
// Wrong — parameter name doesn't match form field name="txtAmount"
if (request.getParameter("amount") != null) {
    amount = Double.parseDouble(request.getParameter("amount"));
}

// Correct
if (request.getParameter("txtAmount") != null && !request.getParameter("txtAmount").isEmpty()) {
    amount = Double.parseDouble(request.getParameter("txtAmount"));
}
```

### 2. Use `getEmployeeToFarmById` (PK lookup) when loading FK entity in servlet

The old code built a raw HQL string and called `getEmployeeToFarmInfoByEmployeeInfoIdDate(qry)`.
That method calls `uniqueResult()` — if it returns `null`, the assignment is `employeeToFarm = null`,
the FK is null in the saved `SalaryProcessingEntity`, and the filter query
`WHERE sp.employeeToFarm.assignResourceId = X` returns 0 records.

Always use the safe PK loader:

```java
// Wrong — string-built HQL, null FK risk
String qry = "from AssignEmployeeToFarmEntity where assignResourceId=" + assignResourceId;
AssignEmployeeToFarmEntity employeeToFarm = service.getEmployeeToFarmInfoByEmployeeInfoIdDate(qry);

// Correct — session.get() by PK, guaranteed non-null when record exists
AssignEmployeeToFarmEntity employeeToFarm = service.getEmployeeToFarmById(assignResourceId);
```

### 3. Always redirect after save/update in servlets

Without a redirect the browser stays on the servlet URL. Navigating back to the JSP
shows a stale page (0 records) because the JSP re-executes the fetch query fresh.

```java
// After all save/update operations, redirect back to the JSP with the same ID
response.sendRedirect(request.getContextPath()
    + "/view/user/02SalaryProcessing.jsp?assignResourceId=" + assignResourceId);
```

---

## Pre-filling Form Fields from EAGER-Loaded Entities

When a form should default to values from a related entity (e.g. bank name / account
number from `EmployeeInfoEntity`), read them from the already-loaded EAGER relation —
no extra query needed.

Pattern in JSP (inside the scriptlet that loads the root entity):

```jsp
<%
    String defaultBankName  = "";
    String defaultAccountNo = "";
    if (employeeToFarm != null && employeeToFarm.getEmployeeInfoEntity() != null) {
        EmployeeInfoEntity empInfo = employeeToFarm.getEmployeeInfoEntity();
        if (empInfo.getBankName()      != null) defaultBankName  = empInfo.getBankName();
        if (empInfo.getAccountNumber() != null) defaultAccountNo = empInfo.getAccountNumber();
    }
%>
<input type="text" name="bankName"  id="bankName"  value="<%=defaultBankName%>">
<input type="text" name="accountNO" id="accountNO"  value="<%=defaultAccountNo%>">
```

The `resetPayForm()` JS function must explicitly clear these fields back to `''`
so the pre-filled defaults don't persist after the user clicks Reset.

---

## HQL Aggregation — Pay Status per Employee

To compute totals across related entities, use HQL `SUM` aggregate queries.
These are added as dedicated DAO methods — one per aggregate, called per row in the JSP loop.

### SalaryProcessingDao — total salary transactions paid for one employee

```java
public double getTotalSalaryPaidByEmployeeInfoId(int employeeInfoId) {
    double total = 0;
    Session session = HibernateUtil.opensession();
    try {
        Object result = session.createQuery(
            "SELECT SUM(sp.amount) FROM SalaryProcessingEntity sp " +
            "WHERE sp.employeeToFarm.employeeInfoEntity.employeeInfoId = " + employeeInfoId)
            .uniqueResult();
        if (result != null) total = ((Number) result).doubleValue();
    } catch (HibernateException e) { ... } finally { session.close(); }
    return total;
}
```

`SUM` returns `null` (not 0) when there are no matching rows — always null-check before casting.

### AssignResourceEmployeeToFarmService — total assigned amount + advance for one employee

A single HQL query can return two aggregates as `Object[]`:

```java
public double[] getTotalAmountAndAdvByEmployeeInfoId(int employeeInfoId) {
    double[] result = {0, 0};
    Session session = HibernateUtil.opensession();
    try {
        Object[] row = (Object[]) session.createQuery(
            "SELECT SUM(aef.amount), SUM(aef.advPayment) " +
            "FROM AssignEmployeeToFarmEntity aef " +
            "WHERE aef.employeeInfoEntity.employeeInfoId = " + employeeInfoId)
            .uniqueResult();
        if (row != null) {
            if (row[0] != null) result[0] = ((Number) row[0]).doubleValue();
            if (row[1] != null) result[1] = ((Number) row[1]).doubleValue();
        }
    } catch (HibernateException e) { ... } finally { session.close(); }
    return result;
}
```

### JSP — compute pay status in the row loop

```jsp
<%
    int empId = entity.getEmployeeInfoId();
    double[] amountAdv    = assignService.getTotalAmountAndAdvByEmployeeInfoId(empId);
    double totalAssigned  = amountAdv[0];
    double totalAdv       = amountAdv[1];
    double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByEmployeeInfoId(empId);
    double totalPaid      = totalAdv + totalSalaryPaid;

    String payStatus, payStatusColor;
    if      (totalAssigned == 0)          { payStatus = "No Work"; payStatusColor = "#888888"; }
    else if (totalPaid >= totalAssigned)  { payStatus = "Paid";    payStatusColor = "#007700"; }
    else if (totalPaid > 0)              { payStatus = "Partial";  payStatusColor = "#cc7700"; }
    else                                 { payStatus = "Unpaid";   payStatusColor = "#cc0000"; }
%>
<td style="font-weight:bold; color:<%=payStatusColor%>;"><%=payStatus%></td>
```

**Note:** This is an N+1 query pattern (2 queries per employee row). Acceptable for
this application's scale. For large datasets, replace with a single aggregation query
that returns all employees at once using `GROUP BY`.

---

## JSP List Page — Edit / Bulk Delete Pattern

Pattern used in `userType.jsp` — applicable to any simple config list page.

### Design decisions

- **Edit** is per-row (inline Edit button) — fills the form above, highlights the row, shows Update/Cancel.
- **Delete** is checkbox-based only — no inline Delete button per row. Users tick one or many rows, then click Delete Selected.
- This keeps the two actions visually separate and prevents accidental single-record deletion.

---

### 1. Inline Edit button per row

```html
<button type="button" class="btn-row-edit"
    onclick="editRow(<%=entity.getId()%>, '<%=escapedName%>')">Edit</button>
```

```javascript
function editRow(id, name) {
    if (editingRowEl) editingRowEl.classList.remove('selected-row');
    editingRowEl = document.getElementById('row-' + id);
    if (editingRowEl) editingRowEl.classList.add('selected-row');

    document.getElementById('entityId').value = id;
    document.getElementById('entityName').value = name;

    document.getElementById('btnAdd').style.display    = 'none';
    document.getElementById('btnUpdate').style.display = 'inline-block';
    document.getElementById('btnCancel').style.display = 'inline-block';

    // show yellow "Editing: <name>" banner
    var banner = document.getElementById('editBanner');
    banner.style.display = 'block';
    banner.innerText = 'Editing: ' + name;

    document.getElementById('formPanel').scrollIntoView({behavior:'smooth'});
    document.getElementById('entityName').focus();
}

function resetForm() {
    if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
    document.getElementById('entityId').value          = '';
    document.getElementById('entityName').value        = '';
    document.getElementById('editBanner').style.display = 'none';
    document.getElementById('btnAdd').style.display    = 'inline-block';
    document.getElementById('btnUpdate').style.display = 'none';
    document.getElementById('btnCancel').style.display = 'none';
}
```

---

### 2. Checkbox column — select single or all

Header checkbox toggles all rows. Any row checkbox change updates the bulk-delete bar.

```html
<!-- Header -->
<th><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)"></th>

<!-- Each row -->
<td><input type="checkbox" class="rowChk" value="<%=entity.getId()%>" onchange="updateBulkBar()"></td>
```

```javascript
function toggleSelectAll(chk) {
    document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = chk.checked; });
    updateBulkBar();
}

function updateBulkBar() {
    var checked = document.querySelectorAll('input.rowChk:checked');
    var all     = document.querySelectorAll('input.rowChk');
    document.getElementById('bulkBar').style.display = checked.length > 0 ? 'block' : 'none';
    document.getElementById('selCount').innerText    = checked.length;
    document.getElementById('chkAll').checked        = (checked.length === all.length && all.length > 0);
}
```

---

### 3. Bulk-delete bar and submission

The bar appears automatically when any checkbox is ticked. Uses a **separate hidden form** so it doesn't interfere with the Add/Edit form.

```html
<!-- Visible bar -->
<div id="bulkBar" style="display:none;">
    <span id="selCount">0</span> record(s) selected
    <button type="button" onclick="deleteSelected()">Delete Selected</button>
    <button type="button" onclick="clearSelection()">Clear Selection</button>
</div>

<!-- Separate form — populated by JS before submit -->
<form method="post" id="frmBulkDelete" action="../../UserTypeController"></form>
```

```javascript
function deleteSelected() {
    var checked = document.querySelectorAll('input.rowChk:checked');
    if (checked.length === 0) return;
    if (!confirm('Delete ' + checked.length + ' selected record(s)?')) return;

    var form = document.getElementById('frmBulkDelete');
    form.innerHTML = '';   // clear previous inputs
    checked.forEach(function(b) {
        var inp = document.createElement('input');
        inp.type = 'hidden'; inp.name = 'deleteIds'; inp.value = b.value;
        form.appendChild(inp);
    });
    var flag = document.createElement('input');
    flag.type = 'hidden'; flag.name = 'deleteSelected'; flag.value = '1';
    form.appendChild(flag);
    form.submit();
}
```

---

### 4. Controller — bulk delete branch

`request.getParameterValues("deleteIds")` returns all checked IDs as a `String[]`.

```java
if (request.getParameter("deleteSelected") != null) {
    String[] ids = request.getParameterValues("deleteIds");
    if (ids != null) {
        for (String id : ids) {
            service.deleteById(Integer.parseInt(id));
        }
    }
}
response.sendRedirect("view/user/userType.jsp");
```

---

### 5. CSS reference

```css
.btn-row-edit       { background:#e8f0fe; border:1px solid #4a80d4; color:#1a56c4; padding:2px 8px; cursor:pointer; border-radius:2px; font-size:12px; }
.btn-row-edit:hover { background:#c2d5f9; }
.tbl-data tr.selected-row { background:#c2d7f9 !important; font-weight:bold; }
#editBanner { display:none; background:#fff3cd; border:1px solid #ffc107; color:#856404; padding:4px 10px; border-radius:3px; margin-bottom:6px; font-weight:bold; }
#bulkBar    { display:none; background:#fdecea; border:1px solid #e06060; padding:6px 12px; border-radius:3px; margin-bottom:8px; }
```

---

## Updated Common Pitfalls

| Pitfall | Cause | Fix |
|---|---|---|
| Amount saved as 0 | `getParameter("amount")` but form field is `name="txtAmount"` | Match parameter name exactly to the form field `name` attribute |
| 0 salary records fetched after save | FK saved as null because entity fetched via HQL string returned null | Use `getEmployeeToFarmById(id)` (session.get by PK) |
| Page shows old data after save | Servlet has no redirect — browser re-renders stale cached JSP | Add `response.sendRedirect(...)` at end of save/update block |
| `SUM` returns null instead of 0 | HQL `SUM` on empty result set returns null, not 0 | Null-check: `if (result != null) total = ((Number) result).doubleValue()` |
| Edit form fields blank after row click | JS reads wrong column index from `<td>` | Check `eq(N)` index — 0-based, account for any leading Select/Id columns |
| `Connection/Statement cannot be resolved to a type` in JSP | Old JDBC imports removed but dead variable declarations remain in the scriptlet body | Remove both the `import` lines **and** the `Connection con = null; Statement st = null;` variable declarations in the body scriptlet |

---

## Migrating a New JDBC-Based Feature to Hibernate

Use this checklist when an existing page uses raw JDBC (`DBfactory`, `Connection`, `Statement`, `ResultSet`) and needs to be converted to Hibernate.

### Step 1 — Create the Entity

```java
package com.san.farm.adminuser.entity;

import javax.persistence.*;

@Entity
@Table(name = "Brand")          // matches the actual DB table name
public class BrandEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int brandId;

    private String brandName;

    // standard getters / setters
}
```

Rules:
- `@Entity` + `@Table(name = "...")` — use the **exact** existing table name (case-sensitive on some DBs)
- `@Id` + `@GeneratedValue` for auto-increment PK
- Field names follow camelCase; Hibernate maps them to UPPERCASE column names by default (H2 is case-insensitive)

### Step 2 — Register the entity in `hibernate.cfg.xml`

```xml
<mapping class="com.san.farm.adminuser.entity.BrandEntity" />
```

Add alongside the other `<mapping>` lines inside `<session-factory>`. Hibernate won't know about the entity (or auto-create the table) until it is registered here. Requires **Tomcat restart** to take effect.

### Step 3 — Create the Service (DAO)

```java
public class BrandService {

    public void saveBrand(BrandEntity brand) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        session.save(brand);
        tx.commit();
        session.close();
    }

    public void updateBrand(BrandEntity brand) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        session.update(brand);
        tx.commit();
        session.close();
    }

    public void deleteBrand(int brandId) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        BrandEntity brand = session.get(BrandEntity.class, brandId);
        if (brand != null) session.delete(brand);
        tx.commit();
        session.close();
    }

    public List<BrandEntity> fetch() {
        Session session = HibernateUtil.opensession();
        List<BrandEntity> list = session.createQuery(
            "FROM BrandEntity ORDER BY brandName", BrandEntity.class).list();
        session.close();
        return list;
    }
}
```

Key points:
- Always open a fresh session per operation (this project does not use session-per-request or connection pooling)
- `session.get(Class, PK)` for delete — safe (returns null if not found, no exception)
- Always commit before closing on write operations

### Step 4 — Create the Controller (Servlet)

```java
public class BrandController extends HttpServlet {

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BrandService brandService = new BrandService();
        BrandEntity brand = new BrandEntity();

        if (request.getParameter("add") != null) {
            brand.setBrandName(request.getParameter("brandName"));
            brandService.saveBrand(brand);
        }
        if (request.getParameter("edit") != null) {
            brand.setBrandId(Integer.parseInt(request.getParameter("brandId")));
            brand.setBrandName(request.getParameter("brandName"));
            brandService.updateBrand(brand);
        }
        if (request.getParameter("delete") != null) {
            brandService.deleteBrand(Integer.parseInt(request.getParameter("brandId")));
        }
        if (request.getParameter("deleteSelected") != null) {
            String[] ids = request.getParameterValues("deleteIds");
            if (ids != null) {
                for (String id : ids) brandService.deleteBrand(Integer.parseInt(id));
            }
        }

        response.sendRedirect("view/user/addBrand.jsp");
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException { doProcess(req, res); }
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException { doProcess(req, res); }
}
```

`response.sendRedirect("view/user/addBrand.jsp")` is placed in `finally` (or unconditionally after all branches) so the JSP always re-renders fresh data after any operation.

### Step 5 — Register the Servlet in `web.xml`

```xml
<servlet>
    <servlet-name>BrandController</servlet-name>
    <servlet-class>com.san.farm.adminuser.controller.BrandController</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>BrandController</servlet-name>
    <url-pattern>/BrandController</url-pattern>
</servlet-mapping>
```

Requires **Tomcat restart** to take effect.

### Step 6 — Rewrite the JSP

Replace all JDBC code with the Service call. The JSP only needs to open the service, fetch the list, and render it:

```jsp
<%@page import="com.san.farm.adminuser.entity.BrandEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.BrandService"%>
...
<%
    BrandService brandService = new BrandService();
    List<BrandEntity> brandList = brandService.fetch();
    for (BrandEntity brand : brandList) {
        String eName = brand.getBrandName() != null ? brand.getBrandName().replace("'", "\\'") : "";
%>
    <tr id="row-<%=brand.getBrandId()%>">
        <td><%=brand.getBrandId()%></td>
        <td><%=brand.getBrandName()%></td>
        ...
    </tr>
<%} %>
```

Remove: all `import java.sql.*`, `DBfactory`, `Connection`, `Statement`, `ResultSet`, and any reference to old action JSPs (`action/addBrandAction.jsp`).

Form action must point to the new servlet (path relative to context root):

```html
<!-- From a JSP at view/user/addBrand.jsp, go up two levels to reach context root -->
<form method="post" action="../../BrandController">
```

### Step 7 — Embed in an existing iframe page

If the new JSP is displayed inside an iframe on a configuration page (`configuration.jsp`), add a `<th>` + `<td><iframe>` pair:

```html
<th>Brand</th>
...
<td><iframe width="100%" height="550px" src="addBrand.jsp"></iframe></td>
```

---

## Photo Upload — Extracting Filename from Full Absolute Path

`MyFileRenamePolicy.rename()` stores the **full absolute path** in the rename map, not just the filename. This path ends up in `EmployeeInfoEntity.empPicPath` in the database.

Using the full path directly as an `<img src="">` attribute breaks (the URL would be `/view/user//Users/...`). Extract just the filename:

```java
// In JSP scriptlet (edit mode)
String fPhotoPath = emp != null && emp.getEmpPicPath() != null && !emp.getEmpPicPath().isEmpty()
                    ? emp.getEmpPicPath() : "";
String fPhotoFileName = "";
if (!fPhotoPath.isEmpty()) {
    String normalized = fPhotoPath.replace('\\', '/');
    int lastSlash = normalized.lastIndexOf('/');
    fPhotoFileName = lastSlash >= 0 ? normalized.substring(lastSlash + 1) : normalized;
}
```

Then use only `fPhotoFileName` in the `<img>` tag:

```html
<img id="imgPreview"
     src="../../uploads/<%=fPhotoFileName%>"
     style="<%=fPhotoFileName.isEmpty() ? "display:none;" : "max-width:120px;max-height:120px;"%>">
<div id="photoPlaceholder" style="<%=fPhotoFileName.isEmpty() ? "" : "display:none;"%>">No Photo</div>
```

### Instant preview for new uploads (FileReader API)

```html
<input type="file" name="empPhoto" accept="image/*" onchange="previewPhoto(this)">

<script>
function previewPhoto(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('imgPreview').src = e.target.result;
            document.getElementById('imgPreview').style.display = 'block';
            var ph = document.getElementById('photoPlaceholder');
            if (ph) ph.style.display = 'none';
        };
        reader.readAsDataURL(input.files[0]);
    }
}
</script>
```

This shows the selected image immediately without a server round-trip, both in add and edit modes.
