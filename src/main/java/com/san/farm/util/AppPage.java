package com.san.farm.util;

public final class AppPage {
    public final String key;    // used as DB value and JS identifier
    public final String label;  // human-readable page name
    public final String group;  // nav group heading

    private AppPage(String key, String label, String group) {
        this.key = key; this.label = label; this.group = group;
    }

    public static final AppPage[] ALL = {
        new AppPage("dashboard",       "Dashboard",               "Dashboard"),
        new AppPage("configuration",   "Configuration",           "Master Data"),
        new AppPage("users_roles",     "Users & Roles",           "Master Data"),
        new AppPage("employee_add",    "Add Employee",            "Employee"),
        new AppPage("employee_view",   "View All Employees",      "Employee"),
        new AppPage("farm_site_alloc", "Site Resource Allocation","Farm Setup"),
        new AppPage("farm_view_tasks", "View Assign Tasks",       "Farm Setup"),
        new AppPage("process_payment", "Process Payment",         "Account"),
        new AppPage("vendor_add",      "Add Vendor",              "Vendor"),
        new AppPage("vendor_assign",   "Assign Products",         "Vendor"),
        new AppPage("vendor_view",     "View Products",           "Vendor"),
        new AppPage("sales_buyers",    "Manage Buyers",           "Sales"),
        new AppPage("sales_crop",      "Crop Sales",              "Sales"),
        new AppPage("report_site",     "Site Report",             "Reports"),
        new AppPage("report_employee", "Employee Report",         "Reports"),
        new AppPage("report_income",   "Income Report",           "Reports"),
        new AppPage("report_pl",       "P&L Report",              "Reports"),
    };
}
