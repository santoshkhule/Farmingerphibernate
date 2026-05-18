<%@page import="com.san.farm.adminuser.entity.*"%>
<%@page import="com.san.farm.adminuser.dao.*"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    /* ── resolve cropToSiteId ── */
    int cropToSiteId = 0;
    try {
        String ctSid = request.getParameter("cropToSiteId");
        if (ctSid != null && !ctSid.trim().isEmpty()) cropToSiteId = Integer.parseInt(ctSid.trim());
    } catch (Exception ignore) {}

    /* ── site info ── */
    AssignCropToSiteService cropSvc = new AssignCropToSiteService();
    AssignCropToSiteEntity  cropToSite = cropSvc.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);

    /* ── filter params ── */
    int selVendorId = 0, selCategoryId = 0, selFertilizerId = 0;
    try { if (request.getParameter("vendorId")     != null && !request.getParameter("vendorId").isEmpty())     selVendorId     = Integer.parseInt(request.getParameter("vendorId"));     } catch(Exception ignore){}
    try { if (request.getParameter("categoryId")   != null && !request.getParameter("categoryId").isEmpty())   selCategoryId   = Integer.parseInt(request.getParameter("categoryId"));   } catch(Exception ignore){}
    try { if (request.getParameter("fertilizerId") != null && !request.getParameter("fertilizerId").isEmpty()) selFertilizerId = Integer.parseInt(request.getParameter("fertilizerId")); } catch(Exception ignore){}

    /* ── lookup data for dropdowns ── */
    VendorService     vendorSvc     = new VendorService();
    CategoryService   categorySvc   = new CategoryService();
    FertilizerService fertilizerSvc = new FertilizerService();
    List<VendorEntity>     vendors     = vendorSvc.fetch();
    List<CategoryEntity>   categories  = categorySvc.fetch();
    List<FertilizerEntity> fertilizers = fertilizerSvc.fetch();

    /* ── filtered product list ── */
    AssignVendorToProductService avpSvc = new AssignVendorToProductService();
    List<AssignVendorToProductEntity> products = avpSvc.fetchFiltered(selVendorId, selCategoryId, selFertilizerId);

    /* ── already allocated products for this site ── */
    SiteProductAllocationService allocationSvc = new SiteProductAllocationService();
    List<SiteProductAllocationEntity> allocations = allocationSvc.getByCropToSiteId(cropToSiteId);

    /* ── site display info ── */
    String siteName  = (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                     ? cropToSite.getSiteInformationEntity().getSiteName() : "Unknown Site";
    String siteDate  = (cropToSite != null && cropToSite.getCropAssignDate() != null)
                     ? FarmUtility.convertfrom_yymmddToddmmyy(cropToSite.getCropAssignDate().toString()) : "";

    /* ── pre-compute summary totals ── */
    double summaryTotal = 0;
    for (SiteProductAllocationEntity spa : allocations) {
        double p = spa.getVendorProduct() != null ? spa.getVendorProduct().getPrice() : 0;
        summaryTotal += p * spa.getQuantity();
    }
    java.text.SimpleDateFormat todayFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
    String todayStr = todayFmt.format(new java.util.Date());
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title><%= msg.getString("fert_alloc.page_title") %> — <%=siteName%></title>
<style>
    .site-banner { background:#e8f5e9; border:1px solid var(--green-bd); border-radius:var(--r-md);
                   padding:8px 16px; margin-bottom:12px; display:flex; align-items:center; gap:18px; }
    .site-banner .sb-label { font-size:0.78em; color:var(--text-muted); text-transform:uppercase; }
    .site-banner .sb-val   { font-weight:700; color:var(--green-dk); }
    .filter-bar  { background:#fff; border:1px solid var(--gray-200); border-radius:var(--r-md);
                   padding:8px 14px; margin-bottom:10px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
    .filter-bar label { font-size:12px; font-weight:600; color:var(--green-dk); }
    .filter-bar select { font-size:12px; padding:3px 6px; }
    .qty-inp    { width:70px; font-size:12px; padding:3px 5px; text-align:right; }
    .date-inp   { width:95px; font-size:12px; padding:3px 5px; }
    .btn-alloc  { background:var(--green-dk); color:#fff; border:none; padding:3px 12px;
                  cursor:pointer; border-radius:var(--r-sm); font-size:12px; font-weight:600; }
    .btn-alloc:hover { background:#2e7d32; }
    .section-title { font-weight:700; color:var(--green-dk); font-size:0.95em;
                     border-bottom:2px solid var(--green-bd); padding-bottom:4px; margin:14px 0 8px; }
    .back-link { font-size:12px; color:var(--green-dk); text-decoration:none; }
    .back-link:hover { text-decoration:underline; }
    .stats-bar  { display:flex; gap:12px; flex-wrap:wrap; margin-bottom:12px; }
    .stat-card  { background:#fff; border:1px solid var(--gray-200); border-radius:var(--r-md);
                  padding:8px 18px; min-width:130px; text-align:center; }
    .stat-card .sc-val   { font-size:1.25em; font-weight:700; color:var(--green-dk); }
    .stat-card .sc-label { font-size:0.72em; color:var(--text-muted); text-transform:uppercase; margin-top:2px; }
    .stat-card.highlight { background:#e8f5e9; border-color:var(--green-bd); }
</style>
</head>
<body>
<%@include file="../../header.jsp" %>
<script src="../../js/jquery-ui.js"></script>
<script>
$(function() {
    $(".date-inp").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
});
</script>

<fieldset>
<legend><%= msg.getString("fert_alloc.fieldset_title") %></legend>

<!-- Back link -->
<a class="back-link" href="assignCropToSite.jsp">&#8592; <%= msg.getString("btn.back") %></a>

<!-- Site banner -->
<div class="site-banner" style="margin-top:8px;">
    <div><div class="sb-label"><%= msg.getString("tbl.col_site") %></div><div class="sb-val"><%=siteName%></div></div>
    <% if (!siteDate.isEmpty()) { %>
    <div><div class="sb-label">Assignment Date</div><div class="sb-val"><%=siteDate%></div></div>
    <% } %>
    <%
    if (cropToSite != null && cropToSite.getCropToSiteRefEntity() != null) {
        StringBuilder crops = new StringBuilder();
        for (AssignCropToSiteRefEntity ref : cropToSite.getCropToSiteRefEntity()) {
            if (crops.length() > 0) crops.append(", ");
            crops.append(ref.getConfigCropEntity().getCropName());
        }
        if (crops.length() > 0) { %>
    <div><div class="sb-label"><%= msg.getString("tbl.col_crop") %></div><div class="sb-val"><%=crops.toString()%></div></div>
    <% } } %>
</div>

<!-- Summary stats -->
<div class="stats-bar">
    <div class="stat-card highlight">
        <div class="sc-val"><%=allocations.size()%></div>
        <div class="sc-label"><%= msg.getString("fert_alloc.section_already_allocated") %></div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val">&#8377; <%=String.format("%.2f", summaryTotal)%></div>
        <div class="sc-label"><%= msg.getString("fert_alloc.tbl_col_total_rs") %></div>
    </div>
    <div class="stat-card">
        <div class="sc-val"><%=products.size()%></div>
        <div class="sc-label"><%= msg.getString("fert_alloc.section_available_products") %></div>
    </div>
</div>

<!-- Filter bar -->
<form method="get" action="allocateFertilizersToSite.jsp">
    <input type="hidden" name="cropToSiteId" value="<%=cropToSiteId%>">
    <div class="filter-bar">
        <label><%= msg.getString("fert_alloc.filter_label_vendor") %>:</label>
        <select name="vendorId" onchange="this.form.submit()">
            <option value=""><%= msg.getString("fert_alloc.filter_all_vendors") %></option>
            <% for (VendorEntity v : vendors) { %>
            <option value="<%=v.getVendorId()%>" <%=v.getVendorId()==selVendorId?"selected":""%>><%=v.getVendorName()%></option>
            <% } %>
        </select>
        <label><%= msg.getString("fert_alloc.filter_label_category") %>:</label>
        <select name="categoryId" onchange="this.form.submit()">
            <option value=""><%= msg.getString("fert_alloc.filter_all_categories") %></option>
            <% for (CategoryEntity c : categories) { %>
            <option value="<%=c.getCategoryId()%>" <%=c.getCategoryId()==selCategoryId?"selected":""%>><%=c.getCategoryName()%></option>
            <% } %>
        </select>
        <label><%= msg.getString("fert_alloc.filter_label_fertilizer") %>:</label>
        <select name="fertilizerId" onchange="this.form.submit()">
            <option value=""><%= msg.getString("fert_alloc.filter_all_products") %></option>
            <% for (FertilizerEntity f : fertilizers) { %>
            <option value="<%=f.getFertilizerId()%>" <%=f.getFertilizerId()==selFertilizerId?"selected":""%>><%=f.getFertilizerName()%></option>
            <% } %>
        </select>
        <% if (selVendorId > 0 || selCategoryId > 0 || selFertilizerId > 0) { %>
        <a href="allocateFertilizersToSite.jsp?cropToSiteId=<%=cropToSiteId%>"
           style="font-size:12px; color:var(--red-md); text-decoration:none;">&#10005; <%= msg.getString("btn.clear") %></a>
        <% } %>
    </div>
</form>

<!-- Product list -->
<div class="section-title"><%= msg.getString("fert_alloc.section_available_products") %> <span style="font-size:0.8em; font-weight:normal; color:var(--text-muted);">(<%=products.size()%> found)</span></div>
<% if (products.isEmpty()) { %>
<p style="color:var(--text-muted); font-size:13px;"><%= msg.getString("fert_alloc.no_products") %></p>
<% } else { %>
<table border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th><%= msg.getString("tbl.col_vendor") %></th>
        <th><%= msg.getString("tbl.col_category") %></th>
        <th><%= msg.getString("tbl.col_product") %></th>
        <th><%= msg.getString("tbl.col_brand") %></th>
        <th><%= msg.getString("tbl.col_unit") %></th>
        <th><%= msg.getString("fert_alloc.tbl_col_price_rs") %></th>
        <th><%= msg.getString("fert_alloc.tbl_col_allocate") %></th>
    </tr>
    </thead>
    <tbody>
    <% for (AssignVendorToProductEntity avp : products) {
        String venName  = avp.getVendorEntity()     != null ? avp.getVendorEntity().getVendorName()           : "";
        String catName  = avp.getCategoryEntity()   != null ? avp.getCategoryEntity().getCategoryName()       : "";
        String ferName  = avp.getFertilizerEntity() != null ? avp.getFertilizerEntity().getFertilizerName()   : "";
        String briName  = avp.getBrandEntity()      != null ? avp.getBrandEntity().getBrandName()             : "";
        String uniName  = avp.getUnitEntity()       != null ? avp.getUnitEntity().getUnitName()               : "";
    %>
    <tr>
        <td><%=venName%></td>
        <td><%=catName%></td>
        <td><%=ferName%></td>
        <td><%=briName%></td>
        <td><%=uniName%></td>
        <td style="text-align:right;"><%=String.format("%.2f", avp.getPrice())%></td>
        <td colspan="4" style="white-space:nowrap;">
            <form method="post" action="<%=request.getContextPath()%>/SiteProductAllocationController" style="display:inline;">
                <input type="hidden" name="action"               value="allocate">
                <input type="hidden" name="cropToSiteId"         value="<%=cropToSiteId%>">
                <input type="hidden" name="assignVendorProductId" value="<%=avp.getAssignVendorProductId()%>">
                <label style="font-size:11px;"><%= msg.getString("fert_alloc.label_qty") %>:</label>
                <input type="number" name="quantity" class="qty-inp" value="1" min="0.01" step="0.01" required>
                <label style="font-size:11px; margin-left:6px;"><%= msg.getString("tbl.col_date") %>:</label>
                <input type="text" name="allocationDate" class="date-inp" value="<%=todayStr%>" placeholder="dd/mm/yyyy">
                <label style="font-size:11px; margin-left:6px;"><%= msg.getString("fert_alloc.label_note") %>:</label>
                <input type="text" name="comment" style="width:90px;font-size:12px;padding:3px;" placeholder="optional">
                <button type="submit" class="btn-alloc" style="margin-left:6px;"><%= msg.getString("fert_alloc.tbl_col_allocate") %></button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>
<% } %>

<!-- Already allocated section -->
<div class="section-title" style="margin-top:18px;">
    <%= msg.getString("fert_alloc.section_already_allocated") %>
    <span style="font-size:0.8em; font-weight:normal; color:var(--text-muted);">(<%=allocations.size()%> record(s))</span>
</div>
<% if (allocations.isEmpty()) { %>
<p style="color:var(--text-muted); font-size:13px;"><%= msg.getString("fert_alloc.no_products_allocated") %></p>
<% } else { %>
<table border="1" width="100%" class="tbl-data" cellspacing="0">
    <thead>
    <tr>
        <th><%= msg.getString("tbl.col_date") %></th>
        <th><%= msg.getString("tbl.col_vendor") %></th>
        <th><%= msg.getString("tbl.col_product") %></th>
        <th><%= msg.getString("tbl.col_brand") %></th>
        <th><%= msg.getString("tbl.col_unit") %></th>
        <th><%= msg.getString("fert_alloc.tbl_col_unit_price_rs") %></th>
        <th><%= msg.getString("fert_alloc.tbl_col_qty") %></th>
        <th><%= msg.getString("fert_alloc.tbl_col_total_rs") %></th>
        <th><%= msg.getString("tbl.col_comment") %></th>
        <th><%= msg.getString("tbl.col_actions") %></th>
    </tr>
    </thead>
    <tbody>
    <%
        double grandTotal = 0;
        for (SiteProductAllocationEntity spa : allocations) {
            AssignVendorToProductEntity avp = spa.getVendorProduct();
            String venName = avp != null && avp.getVendorEntity()     != null ? avp.getVendorEntity().getVendorName()         : "";
            String ferName = avp != null && avp.getFertilizerEntity() != null ? avp.getFertilizerEntity().getFertilizerName() : "";
            String briName = avp != null && avp.getBrandEntity()      != null ? avp.getBrandEntity().getBrandName()           : "";
            String uniName = avp != null && avp.getUnitEntity()       != null ? avp.getUnitEntity().getUnitName()             : "";
            double price   = avp != null ? avp.getPrice() : 0;
            double total   = price * spa.getQuantity();
            grandTotal    += total;
            String aDate   = spa.getAllocationDate() != null
                           ? FarmUtility.convertfrom_yymmddToddmmyy(spa.getAllocationDate().toString()) : "";
    %>
    <tr>
        <td><%=aDate%></td>
        <td><%=venName%></td>
        <td><%=ferName%></td>
        <td><%=briName%></td>
        <td><%=uniName%></td>
        <td style="text-align:right;"><%=String.format("%.2f", price)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", spa.getQuantity())%></td>
        <td style="text-align:right; font-weight:600;"><%=String.format("%.2f", total)%></td>
        <td><%=spa.getComment() != null ? spa.getComment() : ""%></td>
        <td style="text-align:center;">
            <form method="post" action="<%=request.getContextPath()%>/SiteProductAllocationController" style="display:inline;">
                <input type="hidden" name="action"       value="delete">
                <input type="hidden" name="allocationId" value="<%=spa.getAllocationId()%>">
                <input type="hidden" name="cropToSiteId" value="<%=cropToSiteId%>">
                <button type="submit" class="btn-delete"
                    onclick="return (window.top||window).confirm('Remove this allocation?')"><%= msg.getString("btn.remove") %></button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="7" style="text-align:right;"><%= msg.getString("fert_alloc.tbl_footer_grand_total") %></td>
        <td style="text-align:right;"><%=String.format("%.2f", grandTotal)%></td>
        <td colspan="2"></td>
    </tr>
    </tfoot>
</table>
<% } %>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
