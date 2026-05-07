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
