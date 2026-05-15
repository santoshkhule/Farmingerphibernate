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
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="img/favicon.svg">
<link rel="stylesheet" href="css/style.css">
<title>Santosh Farming ERP</title>
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
				<span class="brand-name">Santosh Farming</span>
				<span class="brand-sub">Farm ERP</span>
			</div>
		</div>

		<nav id="sideNav">

			<div class="nav-group">
				<a class="nav-link nav-link-dash" href="view/user/dashboard.jsp" target="contentFrame">&#128202; Dashboard</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#9881; Master Data</div>
				<a class="nav-link" href="view/user/configuration.jsp" target="contentFrame">Configuration</a>
				<a class="nav-link" href="view/user/registerUser.jsp" target="contentFrame">Register User</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128100; Employee</div>
				<a class="nav-link" href="view/user/employeeInfo.jsp" target="contentFrame">Add Employee</a>
				<a class="nav-link" href="view/user/employeeViewAll.jsp" target="contentFrame">View All Employee</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128203; Farm Setup</div>
				<a class="nav-link" href="view/user/assignCropToSite.jsp" target="contentFrame">Site Resource Allocation</a>
				<a class="nav-link" href="view/user/01assignTaskToEmployeeViewAll.jsp" target="contentFrame">View Assign Tasks</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128176; Account</div>
				<a class="nav-link" href="view/user/02employeePaymentProcess.jsp" target="contentFrame">Process Payment</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#127978; Vendor</div>
				<a class="nav-link" href="view/user/addVendor.jsp" target="contentFrame">Add Vendor</a>
				<a class="nav-link" href="view/user/assignVendorToProduct.jsp" target="contentFrame">Assign Products</a>
				<a class="nav-link" href="view/user/assignVendorToProductView.jsp" target="contentFrame">View Products</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128176; Sales</div>
				<a class="nav-link" href="view/user/addBuyer.jsp" target="contentFrame">Manage Buyers</a>
				<a class="nav-link" href="view/user/cropSaleProcess.jsp" target="contentFrame">Crop Sales</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128202; Reports</div>
				<a class="nav-link" href="view/user/reportSite.jsp" target="contentFrame">Site Expenditure</a>
				<a class="nav-link" href="view/user/reportEmployee.jsp" target="contentFrame">Employee Payments</a>
				<a class="nav-link" href="view/user/reportIncome.jsp" target="contentFrame">Income Report</a>
				<a class="nav-link" href="view/user/reportProfitLoss.jsp" target="contentFrame">Profit &amp; Loss</a>
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
			<a class="nav-logout" href="logout.jsp" target="_top">&#128682; Logout</a>
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
