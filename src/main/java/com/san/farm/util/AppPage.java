package com.san.farm.util;

public final class AppPage {
    public final String key;
    public final String label;
    public final String group;
    public final String[] actions;

    private AppPage(String key, String label, String group, String... actions) {
        this.key = key; this.label = label; this.group = group; this.actions = actions;
    }

    public static final AppPage[] ALL = {
        new AppPage("dashboard",       "Dashboard",                "Dashboard"),
        new AppPage("configuration",   "Configuration",            "Master Data",  "add","edit","delete"),
        new AppPage("users_roles",     "Users & Roles",            "Master Data",  "add","edit","delete"),
        new AppPage("employee_add",    "Add / Edit Employee",      "Employee",     "add","edit"),
        new AppPage("employee_view",   "View All Employees",       "Employee",     "edit","delete"),
        new AppPage("farm_site_alloc", "Site Resource Allocation", "Farm Setup",   "add","edit","delete"),
        new AppPage("farm_view_tasks", "View Assign Tasks",        "Farm Setup",   "edit","delete"),
        new AppPage("process_payment", "Process Payment",          "Account",      "add","edit","delete"),
        new AppPage("vendor_add",      "Add Vendor",               "Vendor",       "add","edit","delete"),
        new AppPage("vendor_assign",   "Assign Products",          "Vendor",       "add","edit","delete"),
        new AppPage("vendor_view",     "View Products",            "Vendor"),
        new AppPage("sales_buyers",    "Manage Buyers",            "Sales",        "add","edit","delete"),
        new AppPage("sales_crop",      "Crop Sales",               "Sales",        "add","edit","delete"),
        new AppPage("report_site",     "Site Report",              "Reports"),
        new AppPage("report_employee", "Employee Report",          "Reports"),
        new AppPage("report_income",   "Income Report",            "Reports"),
        new AppPage("report_pl",       "P&L Report",               "Reports"),
    };
}
