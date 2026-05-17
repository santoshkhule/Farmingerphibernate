# Sevak ERP — Technical Architecture Document
**Prepared for:** Patent Agent Consultation  
**Author:** Santosh Khule  
**Contact:** khulesantosh77@gmail.com  
**Date:** May 2026  
**Version:** 1.0

---

## 1. Executive Summary

Sevak ERP is a web-based Enterprise Resource Planning (ERP) system designed specifically for small-to-medium agricultural operations in India. It provides an integrated platform for managing the complete lifecycle of farm operations — from site and crop configuration through employee assignment, input procurement, payroll processing, crop sales, and multi-dimensional financial reporting — with native multilingual support for English, Hindi (हिंदी), and Marathi (मराठी).

The system is built on the Java EE stack using a JSP-Servlet-Hibernate MVC architecture and is deployable on any standard servlet container (Apache Tomcat) against H2, MySQL, or PostgreSQL databases.

---

## 2. System Context

| Attribute | Value |
|-----------|-------|
| Application Type | Web-based ERP (WAR deployment) |
| Target Domain | Agricultural farm management (India) |
| Build System | Apache Maven |
| Group ID | `com.san.farm` |
| Artifact ID | `FarmingERP` |
| Java Version | JDK 11 |
| Primary Runtime | Apache Tomcat 8.0+ |
| Default Database | H2 embedded (file-based) |
| Supported Databases | H2, MySQL 5.x/8.x, PostgreSQL |
| Languages Supported | English, Hindi, Marathi |

---

## 3. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser (Client)                      │
│          HTML / CSS / JavaScript / jQuery / AJAX            │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP
┌───────────────────────────▼─────────────────────────────────┐
│                     Apache Tomcat                            │
│  ┌─────────────┐  ┌───────────────┐  ┌──────────────────┐  │
│  │SessionFilter│  │  JSP Views    │  │Servlet Controllers│  │
│  │(Auth Guard) │  │  (46 pages)   │  │  (23 servlets)   │  │
│  └─────────────┘  └───────────────┘  └────────┬─────────┘  │
│                                                │             │
│  ┌─────────────────────────────────────────────▼──────────┐ │
│  │              DAO / Service Layer (18+ classes)          │ │
│  └─────────────────────────────────────────────┬──────────┘ │
│                                                │             │
│  ┌─────────────────────────────────────────────▼──────────┐ │
│  │           Hibernate ORM (SessionFactory)                │ │
│  │                  HibernateUtil                          │ │
│  └─────────────────────────────────────────────┬──────────┘ │
└────────────────────────────────────────────────┼────────────┘
                                                 │ JDBC
┌────────────────────────────────────────────────▼────────────┐
│              Database (H2 / MySQL / PostgreSQL)              │
│                     20 managed tables                        │
└─────────────────────────────────────────────────────────────┘
```

**Architecture Pattern:** Three-tier MVC (Model-View-Controller)
- **View Layer:** JSP pages with embedded scriptlets, AJAX partials
- **Controller Layer:** Java Servlets (one servlet per business domain)
- **Model Layer:** Hibernate entity classes + DAO/Service classes

---

## 4. Module Breakdown

### 4.1 Authentication & Security Module

**Classes:**
- `com.san.farm.login.entity.LoginUser` — User entity with role assignments
- `com.san.farm.login.dao.LoginUserService` — Authentication logic
- `com.san.farm.login.controller.LoginServlet` — Login/logout handling
- `com.san.farm.filter.SessionFilter` — Request-level authentication enforcement

**Flow:**
```
Browser → login.jsp → LoginServlet → LoginUserService.authenticate()
       → session["loggedInUser"] set → redirect to dashboard
```

**Security Mechanism:**
- Every HTTP request passes through `SessionFilter`
- Filter checks for `session.getAttribute("loggedInUser")`
- Public paths whitelisted: `/login.jsp`, `/index.jsp`, `/logout.jsp`, `/error.jsp`, `/LoginServlet`, `/css/*`, `/js/*`, `/img/*`, `/h2-console/*`
- All other paths redirect to `/login.jsp` if session is absent

**Entity Fields — LoginUser:**
```
loginUserId   (PK, long)
uname         (String)
password      (String)
List<UserTypeEntity>  (ManyToMany)
```

---

### 4.2 Master Data Configuration Module

Manages the reference data that all operational modules depend on.

**Domains and Controllers:**

| Domain | Controller | Service |
|--------|-----------|---------|
| Site Information | ConfigSiteInformationController | ConfigSiteInformationService |
| Crop Types | ConfigCropController | ConfigCropService |
| Farm Tasks | ConfigFarmTaskController | ConfigFarmTaskService |
| User Types / Roles | UserTypeController | UserTypeService |
| Product Brands | BrandController | BrandService |
| Product Categories | CategoryController | CategoryService |
| Measurement Units | UnitController | UnitService |

**All master data services expose:** `save()`, `update()`, `delete()`, `fetch()`, `getById()`

**Entity Fields — ConfigSiteInformationEntity:**
```
siteInfoId    (PK, int)
siteName      (String)
siteArea      (double, in acres)
siteLocation  (String)
→ OneToMany: AssignCropToSiteEntity
```

**Entity Fields — ConfigCropEntity:**
```
cropId        (PK, int)
cropName      (String)
→ OneToMany: AssignEmployeeToFarmEntity
→ OneToMany: AssignCropToSiteRefEntity
```

**Entity Fields — ConfigFarmTaskEntity:**
```
taskId        (PK, int)
taskName      (String)
→ ManyToMany: AssignEmployeeToFarmEntity
```

---

### 4.3 Employee Management Module

**Classes:**
- `EmployeeInfoEntity` — Complete employee profile
- `EmployeeInfoService` — CRUD operations
- `EmployeeInfoController` — Servlet handler
- Views: `employeeInfo.jsp`, `employeeViewAll.jsp`

**Entity Fields — EmployeeInfoEntity:**
```
employeeInfoId  (PK, int)
firstName       (String)
middleName      (String)
lastName        (String)
contactNo1      (String)
contactNo2      (String)
emailId         (String)
birthDate       (String)
perAddress      (String)
localAddress    (String)
bankName        (String)
accountNumber   (String)
panCardNo       (String)
empPicPath      (String)   ← file system path to photo
comment         (String)
```

**Bank details** (`bankName`, `accountNumber`) are pre-filled into payment forms when processing employee salary — creating a data reuse flow from registration to payroll.

---

### 4.4 Farm Operations Module

This is the operational core of the system. It models the hierarchical relationship: **Site → Crop Assignment → Employee Assignment → Task Assignment**.

#### 4.4.1 Crop-to-Site Assignment

**Entities:**
- `AssignCropToSiteEntity` — One assignment record per site per season
- `AssignCropToSiteRefEntity` — Junction table allowing multiple crops per assignment

```
AssignCropToSiteEntity:
  assignCroptoSiteId  (PK, int)
  cropAssignDate      (Date)
  readyToDispatch     (boolean)
  → ManyToOne: ConfigSiteInformationEntity
  → OneToMany: AssignCropToSiteRefEntity

AssignCropToSiteRefEntity:
  AssignCropToSiteRefId  (PK, int)
  → ManyToOne: AssignCropToSiteEntity
  → ManyToOne: ConfigCropEntity
```

#### 4.4.2 Employee-to-Farm Assignment

The central operational entity that links an employee, a site, a crop, multiple tasks, wage, advance payment, and work status into one record.

**Entity Fields — AssignEmployeeToFarmEntity:**
```
assignResourceId    (PK, int)
assignWorkDate      (Date)
typeOfWork          (String)
amount              (double)       ← agreed wage amount
advPayment          (double)       ← advance paid at assignment time
workStatus          (String)       ← Completed / Pending / Reject
comment             (String)
→ ManyToOne: EmployeeInfoEntity
→ ManyToOne: AssignCropToSiteEntity
→ ManyToOne: ConfigCropEntity
→ ManyToMany: ConfigFarmTaskEntity  (via join table)
```

**Significance:** The ManyToMany relationship between a single work assignment and multiple farm tasks is architecturally notable — it allows a single assignment to cover multiple concurrent tasks (e.g., an employee assigned to both "plowing" and "irrigation" in one work period).

---

### 4.5 Vendor & Supply Chain Module

**Entities:**
- `VendorEntity` — Vendor/supplier master data
- `AssignVendorToProductEntity` — Vendor-product catalogue with pricing
- `SiteProductAllocationEntity` — Records usage/allocation of inputs per site

**Entity Fields — VendorEntity:**
```
vendorId      (PK, int)
vendorName    (String)
shopName      (String)
perContactNo  (String)
ofcContactNo  (String)
address       (String)
emailId       (String)
```

**Entity Fields — AssignVendorToProductEntity:**
```
assignVendorProductId  (PK, int)
price                  (double)
prodDesc               (String)
comment                (String)
→ ManyToOne: VendorEntity
→ ManyToOne: CategoryEntity
→ ManyToOne: FertilizerEntity
→ ManyToOne: BrandEntity
→ ManyToOne: UnitEntity
```

**Entity Fields — SiteProductAllocationEntity:**
```
allocationId    (PK, int)
quantity        (double)
allocationDate  (Date)
comment         (String)
→ ManyToOne: AssignCropToSiteEntity
→ ManyToOne: AssignVendorToProductEntity
```

This three-way linkage (Site ↔ Vendor Product ↔ Quantity) enables per-site input cost tracking, which feeds directly into the profit/loss reporting module.

---

### 4.6 Sales & Revenue Module

Tracks crop harvest sales from farm to buyer, with multi-payment support per sale.

**Entities:**
- `BuyerEntity` — Buyer/customer master data
- `CropSaleEntity` — Individual crop sale transaction
- `SalePaymentEntity` — Partial/installment payments against a sale

**Entity Fields — CropSaleEntity:**
```
saleId          (PK, int)
saleDate        (Date)
quantity        (double)
unit            (String)
pricePerUnit    (double)
totalAmount     (double)
comment         (String)
→ ManyToOne: AssignCropToSiteEntity
→ ManyToOne: ConfigCropEntity
→ ManyToOne: BuyerEntity
```

**Entity Fields — SalePaymentEntity:**
```
salePaymentId   (PK, int)
paymentDate     (Date)
amountReceived  (double)
paymentMode     (String)
referenceNo     (String)
comment         (String)
→ ManyToOne: CropSaleEntity
```

**Financial Year Tracking:** The system calculates and reports sales within Indian financial years (April–March), allowing year-over-year comparison.

---

### 4.7 Payroll & Payment Processing Module

Manages employee wage disbursement with multi-payment tracking per work assignment.

**Entity Fields — PaymentProcessingEntity:**
```
salaryProcessId   (PK, int)
amount            (double)
date              (Date)
paymentType       (String)   ← Cash / Check / Other
bankName          (String)
accountNumber     (String)
comment           (String)
→ ManyToOne: AssignEmployeeToFarmEntity
```

**Balance Calculation Logic (in `02employeePaymentProcess.jsp`):**
```
balance = assignedAmount − (advancePayment + sumOfAllSalaryTransactions)
if (balance < 0) balance = 0
```

**Payment Service Methods (`PaymentProcessingDao`):**
- `saveSalaryTransaction(PaymentProcessingEntity)`
- `updateSalaryTransaction(PaymentProcessingEntity)`
- `deleteSalaryTransaction(int)`
- `getAllSalaryTransactionByAssignResourceId(int)` — retrieves all transactions for one assignment
- `getTotalSalaryPaidByAssignResourceId(int)` — aggregate for balance calculation

---

### 4.8 Dashboard & Analytics Module

**Class:** `DashboardServlet` — JSON endpoint consumed by `dashboard.jsp` via AJAX + Chart.js

**KPIs computed and served:**

| KPI | Type |
|-----|------|
| Total active sites | Count |
| Total registered employees | Count |
| Total crop types | Count |
| Total work assignments | Count |
| Total wages assigned | Sum (₹) |
| Total wages paid | Sum (₹) |
| Total balance outstanding | Sum (₹) |
| Crops per site distribution | Series |
| Work status breakdown | Pie (Completed / Pending / Reject) |
| Salary paid per site | Bar chart series |
| Monthly payment trends (18 months) | Time series |
| Top employees by assignment value | Ranked list |

---

### 4.9 Reporting Module

Three dedicated reporting views:

| Report | File | Key Feature |
|--------|------|-------------|
| Site Report | `reportSite.jsp` | Summary + detail per site; FY filter; CSV & PDF export |
| Income Report | `reportIncome.jsp` | Sale income by crop/site/buyer |
| Profit & Loss | `reportProfitLoss.jsp` | Revenue vs. input costs vs. payroll per site |
| Employee Report | `reportEmployee.jsp` | Per-employee assignment and payment history |

**Export formats:** CSV (summary + detail), PDF (print layout)

---

### 4.10 Internationalization (i18n) Module

**Classes:**
- `com.san.farm.util.UTF8Control` — Custom `ResourceBundle.Control` that reads `.properties` files as UTF-8 (required for Devanagari script)
- `com.san.farm.adminuser.controller.LanguageController` — Servlet that sets `session["locale"]`
- `lang.jsp` — Static include in every view; resolves locale from session and loads `ResourceBundle msg`

**Properties files:**
- `src/main/resources/i18n/messages_en.properties` — English (~640 keys)
- `src/main/resources/i18n/messages_hi.properties` — Hindi / हिंदी (~640 keys)
- `src/main/resources/i18n/messages_mr.properties` — Marathi / मराठी (~640 keys)

**Usage pattern in every JSP:**
```jsp
<%@ include file="../../lang.jsp" %>
...
<%= msg.getString("btn.save") %>
```

**Coverage:** Every user-visible string — page titles, table column headers, button labels, filter options, placeholder text, error messages, status labels, report headings — is externalized into the properties files. The language can be switched at runtime without restarting the server.

---

## 5. Database Schema

### 5.1 Entity-Relationship Overview

```
LoginUser ──────────────────────── UserType
    (ManyToMany via join table)

ConfigSiteInformation
    │
    └─ AssignCropToSite ──────────── AssignCropToSiteRef ── ConfigCrop
            │
            ├─ AssignEmployeeToFarm ── EmployeeInfo
            │       │
            │       ├── ConfigCrop
            │       ├── ConfigFarmTask  (ManyToMany)
            │       └── PaymentProcessing (salary transactions)
            │
            ├─ SiteProductAllocation ── AssignVendorToProduct
            │                               │
            │                       Vendor, Category, Fertilizer,
            │                       Brand, Unit
            │
            └─ CropSale ─────────── Buyer
                    │
                    └─ SalePayment
```

### 5.2 Table List (20 Hibernate-managed tables)

| Table | Primary Key | Notes |
|-------|-------------|-------|
| loginuser | loginUserId | User accounts |
| usertype | userTypeId | Role definitions |
| loginuser_usertype | (join) | ManyToMany junction |
| authemployeeinfo | employeeInfoId | Employee master |
| SiteInformation | siteInfoId | Farm sites |
| crops | cropId | Crop types |
| FarmTask | taskId | Task definitions |
| assigncroptoSite | assignCroptoSiteId | Site-season records |
| AssignCropToSiteRef | AssignCropToSiteRefId | Crop refs per site-season |
| AssignEmployeeToFarm | assignResourceId | Work assignments |
| assign_task_junction | (join) | Employee↔Task ManyToMany |
| salaryTransactions | salaryProcessId | Salary payments |
| Brand | brandId | Product brands |
| Category | categoryId | Product categories |
| Fertilizer | fertilizerId | Input products |
| Units | unitId | Measurement units |
| Vendor | vendorId | Supplier master |
| Buyer | buyerId | Customer master |
| AssignVendorToProduct | assignVendorProductId | Vendor catalogue |
| siteProductAllocation | allocationId | Site input usage |
| CropSale | saleId | Harvest sales |
| SalePayment | salePaymentId | Sale receipts |

---

## 6. Key Business Workflows

### 6.1 End-to-End Farm Operations Workflow

```
1. CONFIGURE
   Admin → Configuration page
   → Define: Sites, Crops, Tasks, Brands, Categories, Units

2. SETUP SUPPLY CHAIN
   Admin → Add Vendors → Assign products to vendors (with price)
   Admin → Allocate inputs (fertilizer/pesticides) to specific sites

3. ASSIGN WORK
   Admin → Select Site + Crop assignment
   Admin → Assign Employee with: Date, Work Type, Tasks (multi-select),
           Agreed Amount, Advance Payment, Work Status

4. PROCESS PAYROLL
   Admin → Select assignment from filterable list
   System shows: Amount Due, Advance Paid, Salary Paid, Balance
   Admin → Record payment: Type (Cash/Check/Other), Amount, Date, Bank details
   System → Updates balance in real time

5. RECORD SALES
   Admin → Select Site + Crop + Date
   Admin → Enter: Buyer, Quantity, Unit, Price/Unit
   System → Calculates total; records CropSale
   Admin → Record incoming payments (may be multiple installments)

6. REVIEW REPORTS
   Admin → Dashboard (live KPIs + charts)
   Admin → Site Report (per-site P&L summary + detail, CSV/PDF)
   Admin → Income Report (revenue by crop/buyer)
   Admin → Profit/Loss Report (revenue minus costs)
   Admin → Employee Report (assignments + payments per employee)
```

### 6.2 Payment Balance Calculation

For each employee work assignment:
```
Gross Wage       = AssignEmployeeToFarmEntity.amount
Advance Paid     = AssignEmployeeToFarmEntity.advPayment
Salary Paid      = SUM(PaymentProcessingEntity.amount) WHERE assignResourceId = X
Balance Due      = Gross Wage − (Advance Paid + Salary Paid)
                   [clamped to 0 if negative]
```

This multi-step deduction model (advance + incremental salary payments) is the core payroll logic.

---

## 7. Technical Implementation Highlights

### 7.1 Hibernate Session Management

All data access uses a shared `SessionFactory` initialized once at startup via `HibernateUtil`. Each DAO method opens a session, begins a transaction, performs the operation, commits, and closes in a `try-finally` block.

```java
Session session = HibernateUtil.opensession();
Transaction t = session.beginTransaction();
try {
    // operation
    t.commit();
} catch (HibernateException e) {
    t.rollback();
    throw e;
} finally {
    session.close();
}
```

### 7.2 AJAX Architecture for Filterable Tables

Several views use a two-file pattern:
- **Parent JSP** — renders the page shell, filter bar, and an empty `<div id="showTable">`
- **Ajax JSP** — renders only the HTML `<table>` fragment

On page load and on every filter change, JavaScript calls the Ajax JSP with filter parameters via `XMLHttpRequest`, and the response HTML replaces `div#showTable`. The table is then initialized as a DataTable for client-side sort/search/pagination.

Files using this pattern:
- `02employeePaymentProcess.jsp` + `001ViewEmployeeForPaymentProcessAjax.jsp`
- `cropSaleProcess.jsp` + `01cropSaleViewAllAjax.jsp`
- `assignTaskToEmployeeViewAll.jsp` + AJAX partial

### 7.3 Dynamic Dashboard (JSON API)

`DashboardServlet` acts as a JSON API endpoint. It aggregates data across all entities and returns a single JSON object containing all KPI values and chart series. `dashboard.jsp` consumes this via AJAX on page load and renders charts using Chart.js.

This separates computation from presentation — the dashboard page itself contains no Java scriptlets, only JavaScript that draws from the JSON response.

### 7.4 UTF-8 Devanagari Internationalization

Java's default `ResourceBundle` loader reads `.properties` files as ISO-8859-1, which cannot represent Devanagari Unicode characters. The custom `UTF8Control` class overrides `newBundle()` to load the properties file as a UTF-8 `InputStreamReader`, enabling native Hindi and Marathi text in all property values without escape sequences.

```java
public ResourceBundle newBundle(String baseName, Locale locale,
        String format, ClassLoader loader, boolean reload)
        throws IllegalAccessException, InstantiationException, IOException {
    InputStream stream = loader.getResourceAsStream(resourceName);
    if (stream == null) return null;
    return new PropertyResourceBundle(new InputStreamReader(stream, "UTF-8"));
}
```

### 7.5 Startup Data Seeding

`DataSeeder` implements `ServletContextListener` and runs `contextInitialized()` on application startup. It checks whether the database tables are empty and inserts default reference data (user types, sample sites, default admin user) if needed. This enables a zero-configuration first-run experience.

### 7.6 File Upload Management

The system uses the `com.oreilly.servlet.MultipartRequest` library for handling file uploads (employee photos, documents). A custom `MyFileRenamePolicy` renames uploaded files to avoid collisions. `FarmUtility` provides helper methods to build comma-separated lists of uploaded file paths and to delete individual files from those lists.

---

## 8. External Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| Hibernate Core | 5.0.12 / 5.6.15 | ORM framework |
| H2 Database | 2.2.224 | Embedded database |
| MySQL Connector/J | 5.1.23 | MySQL JDBC driver |
| Servlet API | 3.0.1 | Java EE servlet spec |
| Apache Commons FileUpload | — | File upload handling |
| Apache Commons IO | — | I/O utilities |
| Apache Commons Lang3 | — | String utilities |
| Log4j | 1.2.15 | Application logging |
| SLF4J | 1.7.25 | Logging façade |
| JavaMail | 1.5.6 | Email support |
| ANTLR | 2.7.6 | HQL parsing (Hibernate) |
| DOM4J | 1.6.1 | XML processing (Hibernate) |
| jQuery | 1.9.1 | Frontend AJAX & DOM |
| jQuery UI | — | Datepicker widgets |
| DataTables | — | Client-side table features |
| Chart.js | — | Dashboard charts |

---

## 9. Potentially Novel Aspects (For Patent Agent Review)

The following aspects may warrant specific investigation by a patent agent to determine whether they represent novel technical implementations not found in prior art:

### 9.1 Integrated Multi-Level Agricultural Assignment Model
The data model links a single employee work assignment record to: a specific site, a specific crop on that site, multiple concurrent tasks (ManyToMany), agreed wage, advance payment, and work status — creating a single atomic "work order" entity. The balance calculation then flows from this single entity through multiple payment transaction records. This tight linkage between agri-operational and payroll data may differ from generic ERP models.

### 9.2 Dual-Track Payment System
The system maintains two separate but related payment streams for the same work assignment:
- Advance payment (recorded at assignment time, part of the assignment entity itself)
- Salary payment transactions (separate `PaymentProcessingEntity` records)
Both are deducted from the agreed wage to compute the real-time balance. This dual-track deduction is domain-specific to Indian agricultural labour practices.

### 9.3 Real-Time Agricultural Dashboard with Multi-Dimensional Aggregation
`DashboardServlet` computes 10+ KPIs in a single request — including 18-month payment trend series, per-site salary aggregates, and top-employee rankings — across a fully normalized relational schema without a separate analytics layer. The approach of pre-computing all dashboard metrics server-side and delivering them as a single JSON payload to a chart-rendering frontend may be a specific implementation choice worth noting.

### 9.4 UTF-8 ResourceBundle for Indic Script ERP
The `UTF8Control` mechanism enabling runtime language switching (English / Hindi / Marathi) without server restart, covering all user-facing strings in an agricultural ERP context, may have limited prior art specifically in the Indian agricultural software domain.

### 9.5 Site-Level Input Cost Allocation Linking to P&L
The `SiteProductAllocationEntity` creates a traceable link from a vendor's product (with price) to a specific site-season assignment. Combined with crop sale revenue from the same site-season, this enables site-level and crop-level profit/loss computation — a specific data model pattern for agricultural cost accounting.

---

## 10. What This Document Does NOT Claim

- This document does not assert that any aspect of this software is patentable
- Prior art search has not been conducted; the "novel aspects" section lists candidates for investigation only
- Generic ERP concepts (CRUD, MVC, Hibernate ORM, i18n) are standard industry practice and are not novel
- A registered patent agent should conduct a formal prior art search before any filing

---

## 11. Source Code Location

```
Repository: /Users/santoshkhule/Farmingerphibernate
Branch:     after-dispatch-track
Build:      mvn clean package  →  target/FarmingERP.war
```

**Contact for code review / walkthrough:** khulesantosh77@gmail.com

---

*Document generated: May 2026*  
*Sevak ERP — Agricultural Farm Management System*
