<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    /* Prevent browser from caching this page (kills bfcache bypass) */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="lang.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="img/favicon.svg">
<link rel="stylesheet" href="css/style.css">
<title>Sevak ERP</title>
<style>
	html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; }
	body { display: flex; flex-direction: column; }

	/* ── Top menu bar ── */
	#topbar {
		flex-shrink: 0;
		height: 44px;
		background: var(--sidebar-brand);
		border-bottom: 1px solid rgba(255,255,255,.08);
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 0 16px;
		gap: 10px;
		z-index: 100;
	}
	/* Brand (left) */
	.topbar-brand {
		display: flex;
		align-items: center;
		gap: 8px;
		text-decoration: none;
	}
	.topbar-brand-icon {
		font-size: 22px;
		line-height: 1;
	}
	.topbar-brand-text {
		display: flex;
		flex-direction: column;
		line-height: 1.15;
	}
	.topbar-brand-name {
		font-size: 15px;
		font-weight: 700;
		color: #e8f5e9;
		letter-spacing: .3px;
	}
	.topbar-brand-sub {
		font-size: 9px;
		font-weight: 500;
		color: var(--sidebar-muted);
		letter-spacing: .6px;
		text-transform: uppercase;
	}
	/* Actions (right) */
	.topbar-right {
		display: flex;
		align-items: center;
		gap: 10px;
	}
	.topbar-user {
		display: flex;
		align-items: center;
		gap: 6px;
		padding: 3px 10px;
		background: rgba(255,255,255,.07);
		border: 1px solid rgba(255,255,255,.1);
		border-radius: 20px;
		color: #a5d6a7;
		font-size: 11px;
		font-weight: 600;
	}
	.topbar-user-dot {
		width: 7px; height: 7px;
		background: #69f0ae;
		border-radius: 50%;
		flex-shrink: 0;
	}
	.topbar-lang-select {
		background: rgba(255,255,255,.1);
		color: #c8e6c9;
		border: 1px solid rgba(255,255,255,.2);
		border-radius: var(--r-sm);
		padding: 4px 8px;
		font-size: 12px;
		font-family: inherit;
		cursor: pointer;
		outline: none;
		transition: background .15s;
	}
	.topbar-lang-select:hover,
	.topbar-lang-select:focus { background: rgba(255,255,255,.18); }
	.topbar-lang-select option { background: #1a3320; color: #c8e6c9; }
	.topbar-logout {
		display: flex;
		align-items: center;
		gap: 5px;
		padding: 5px 12px;
		background: rgba(239,154,154,.15);
		color: #ef9a9a;
		border: 1px solid rgba(239,154,154,.25);
		border-radius: var(--r-sm);
		text-decoration: none;
		font-size: 12px;
		font-weight: 600;
		transition: background .15s, color .15s;
	}
	.topbar-logout:hover { background: rgba(239,154,154,.28); color: #ffcdd2; text-decoration: none; }

	#appShell {
		display: flex;
		flex: 1;
		min-height: 0;
		width: 100%;
	}

	#sidebar {
		width: 220px;
		min-width: 180px;
		flex-shrink: 0;
		background: var(--sidebar-bg);
		display: flex;
		flex-direction: column;
		height: 100%;
		overflow-y: auto;
		overflow-x: hidden;
	}

	#contentFrame {
		flex: 1;
		min-width: 0;
		border: none;
		height: 100%;
		background: #eaf2ea;
		display: block;
	}
</style>
</head>
<body>
<%
    String _activeLang = (String) session.getAttribute("locale");
    if (_activeLang == null) _activeLang = "en";
    com.san.farm.login.entity.LoginUser _loggedUser =
        (com.san.farm.login.entity.LoginUser) session.getAttribute("loggedInUser");
    String _uname = (_loggedUser != null && _loggedUser.getUname() != null)
                    ? _loggedUser.getUname() : "";
%>

<!-- ── Top menu bar ── -->
<div id="topbar">

	<!-- Brand (left) -->
	<div class="topbar-brand">
		<span class="topbar-brand-icon">&#127807;</span>
		<div class="topbar-brand-text">
			<span class="topbar-brand-name"><%= msg.getString("nav.brand_name") %></span>
			<span class="topbar-brand-sub"><%= msg.getString("nav.brand_sub") %></span>
		</div>
	</div>

	<!-- Actions (right) -->
	<div class="topbar-right">
		<% if (!_uname.isEmpty()) { %>
		<span class="topbar-user">
			<span class="topbar-user-dot"></span>
			<%= _uname %>
		</span>
		<% } %>
		<select class="topbar-lang-select" onchange="switchLang(this)">
			<option value="en" <%="en".equals(_activeLang) ? "selected" : ""%>>EN — English</option>
			<option value="hi" <%="hi".equals(_activeLang) ? "selected" : ""%>>HI — हिंदी</option>
			<option value="mr" <%="mr".equals(_activeLang) ? "selected" : ""%>>MR — मराठी</option>
		</select>
		<a class="topbar-logout" href="logout.jsp" target="_top">&#128682; <%= msg.getString("nav.logout") %></a>
	</div>

</div>

<div id="appShell">

	<!-- ── Sidebar ── -->
	<aside id="sidebar">

		<div id="sidebar-brand">
			<span class="brand-icon">&#127807;</span>
			<div class="brand-text">
				<span class="brand-name"><%= msg.getString("nav.brand_name") %></span>
				<span class="brand-sub"><%= msg.getString("nav.brand_sub") %></span>
			</div>
		</div>

		<nav id="sideNav">

			<div class="nav-group">
				<a class="nav-link nav-link-dash" href="view/user/dashboard.jsp" target="contentFrame">&#128202; <%= msg.getString("nav.dashboard") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#9881; <%= msg.getString("nav.group_master_data") %></div>
				<a class="nav-link" href="view/user/configuration.jsp" target="contentFrame"><%= msg.getString("nav.master_configuration") %></a>
				<a class="nav-link" href="view/user/registerUser.jsp" target="contentFrame"><%= msg.getString("nav.master_register_user") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128100; <%= msg.getString("nav.group_employee") %></div>
				<a class="nav-link" href="view/user/employeeInfo.jsp" target="contentFrame"><%= msg.getString("nav.employee_add") %></a>
				<a class="nav-link" href="view/user/employeeViewAll.jsp" target="contentFrame"><%= msg.getString("nav.employee_view_all") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128203; <%= msg.getString("nav.group_farm_setup") %></div>
				<a class="nav-link" href="view/user/assignCropToSite.jsp" target="contentFrame"><%= msg.getString("nav.farm_site_resource_allocation") %></a>
				<a class="nav-link" href="view/user/01assignTaskToEmployeeViewAll.jsp" target="contentFrame"><%= msg.getString("nav.farm_view_assign_tasks") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128176; <%= msg.getString("nav.group_account") %></div>
				<a class="nav-link" href="view/user/02employeePaymentProcess.jsp" target="contentFrame"><%= msg.getString("nav.account_process_payment") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#127978; <%= msg.getString("nav.group_vendor") %></div>
				<a class="nav-link" href="view/user/addVendor.jsp" target="contentFrame"><%= msg.getString("nav.vendor_add") %></a>
				<a class="nav-link" href="view/user/assignVendorToProduct.jsp" target="contentFrame"><%= msg.getString("nav.vendor_assign_products") %></a>
				<a class="nav-link" href="view/user/assignVendorToProductView.jsp" target="contentFrame"><%= msg.getString("nav.vendor_view_products") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128176; <%= msg.getString("nav.group_sales") %></div>
				<a class="nav-link" href="view/user/addBuyer.jsp" target="contentFrame"><%= msg.getString("nav.sales_manage_buyers") %></a>
				<a class="nav-link" href="view/user/cropSaleProcess.jsp" target="contentFrame"><%= msg.getString("nav.sales_crop_sales") %></a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128202; <%= msg.getString("nav.group_reports") %></div>
				<a class="nav-link" href="view/user/reportSite.jsp" target="contentFrame"><%= msg.getString("nav.report_site_expenditure") %></a>
				<a class="nav-link" href="view/user/reportEmployee.jsp" target="contentFrame"><%= msg.getString("nav.report_employee_payments") %></a>
				<a class="nav-link" href="view/user/reportIncome.jsp" target="contentFrame"><%= msg.getString("nav.report_income") %></a>
				<a class="nav-link" href="view/user/reportProfitLoss.jsp" target="contentFrame"><%= msg.getString("nav.report_profit_loss") %></a>
			</div>

		</nav>


	</aside>

	<!-- ── Content iframe ── -->
	<iframe id="contentFrame" name="contentFrame"
		src="about:blank"
		frameborder="0">
	</iframe>

</div>

<script>
function switchLang(sel) {
    window.location.href = '<%=request.getContextPath()%>/LanguageController?lang=' + sel.value;
}

(function() {
    var frame   = document.getElementById('contentFrame');
    var ctxPath = '<%=request.getContextPath()%>';
    var base    = window.location.origin + (ctxPath ? ctxPath + '/' : '/');

    function safeRelPage(raw) {
        if (!raw) return '';
        if (raw.indexOf('://') !== -1) return '';   // no absolute URLs
        if (raw.charAt(0) === '/') return '';        // no root-relative paths
        if (raw.indexOf('..') !== -1) return '';     // no path traversal
        return raw;
    }

    // Restore last-viewed page from hash, or fall back to dashboard
    var initial = safeRelPage(decodeURIComponent((window.location.hash || '').slice(1)))
                  || 'view/user/dashboard.jsp';
    frame.src = initial;

    // After every iframe navigation: update hash (strip query params — avoids
    // replaying stale ?msg=... banners on reload)
    frame.addEventListener('load', function() {
        try {
            var href = frame.contentWindow.location.href;
            if (!href || href === 'about:blank') return;
            if (href.indexOf(base) === 0) {
                var rel = href.slice(base.length);
                var q = rel.indexOf('?');
                if (q !== -1) rel = rel.substring(0, q);
                if (rel && rel.indexOf('login.jsp') === -1) {
                    history.replaceState(null, '', '#' + rel);
                }
            }
        } catch (e) { /* cross-origin safety */ }
    });
})();
</script>

</body>
</html>
