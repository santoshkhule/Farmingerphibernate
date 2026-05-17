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

	#appShell {
		display: flex;
		height: 100vh;
		width: 100%;
	}

	#sidebar {
		width: 220px;
		min-width: 180px;
		flex-shrink: 0;
		background: var(--sidebar-bg);
		display: flex;
		flex-direction: column;
		height: 100vh;
		overflow-y: auto;
		overflow-x: hidden;
	}

	/* ── Language switcher ── */
	.lang-switcher {
		display: flex; gap: 4px; padding: 6px 12px 8px;
		border-top: 1px solid rgba(255,255,255,.1);
	}
	.lang-btn {
		flex: 1; text-align: center; padding: 4px 2px;
		font-size: 11px; font-weight: 700; border-radius: 4px; cursor: pointer;
		text-decoration: none; color: rgba(255,255,255,.65);
		border: 1px solid rgba(255,255,255,.15);
		transition: background .15s, color .15s;
	}
	.lang-btn:hover  { background: rgba(255,255,255,.12); color: #fff; }
	.lang-btn.active { background: rgba(255,255,255,.2);  color: #fff; border-color: rgba(255,255,255,.35); }

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

		<div id="sidebar-foot">
			<%
			    String _activeLang = (String) session.getAttribute("locale");
			    if (_activeLang == null) _activeLang = "en";
			%>
			<div class="lang-switcher">
				<a class="lang-btn <%="en".equals(_activeLang) ? "active" : ""%>"
				   href="LanguageController?lang=en">EN</a>
				<a class="lang-btn <%="hi".equals(_activeLang) ? "active" : ""%>"
				   href="LanguageController?lang=hi">हिंदी</a>
				<a class="lang-btn <%="mr".equals(_activeLang) ? "active" : ""%>"
				   href="LanguageController?lang=mr">मराठी</a>
			</div>
			<a class="nav-logout" href="logout.jsp" target="_top">&#128682; <%= msg.getString("nav.logout") %></a>
		</div>

	</aside>

	<!-- ── Content iframe ── -->
	<iframe id="contentFrame" name="contentFrame"
		src="about:blank"
		frameborder="0">
	</iframe>

</div>

<script>
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
