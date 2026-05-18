<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*,com.san.farm.adminuser.dao.RolePermissionDao,com.san.farm.adminuser.entity.UserTypeEntity"%>
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
		transition: width 0.22s ease;
	}

	/* Desktop — collapsed */
	body.sidebar-collapsed #sidebar {
		width: 0;
		min-width: 0;
	}

	#contentFrame {
		flex: 1;
		min-width: 0;
		border: none;
		height: 100%;
		background: #eaf2ea;
		display: block;
	}

	/* ── Mobile-only topbar toggle ── */
	.topbar-left { display:flex; align-items:center; gap:4px; }
	#topbarToggle {
		display: none; /* hidden on desktop */
		background: none;
		border: none;
		color: #c8e6c9;
		cursor: pointer;
		padding: 5px 9px;
		font-size: 20px;
		line-height: 1;
		border-radius: 4px;
		flex-shrink: 0;
		align-items: center;
		transition: background .15s, color .15s;
	}
	#topbarToggle:hover { background: rgba(255,255,255,.13); color: #fff; }

	/* ── Nav icon / text structure ── */
	.nav-icon { flex-shrink: 0; font-style: normal; }
	.nav-text  { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

	/* ── Sidebar narrow (icon-only) mode ── */
	#sidebar.sidebar-narrow .nav-text          { display: none; }
	#sidebar.sidebar-narrow .nav-link          { justify-content: center; padding: 9px 4px; font-size: 17px; border-left-width: 0; border-left-color: transparent; }
	#sidebar.sidebar-narrow .nav-link-dash     { margin: 4px 2px; }
	#sidebar.sidebar-narrow .nav-group-title   { justify-content: center; padding: 8px 4px; }
	#sidebar.sidebar-narrow .nav-admin-badge   { display: none; }
	#sidebar.sidebar-narrow #sidebarToggle     { transform: rotate(180deg); }

	/* ── Sidebar foot toggle (◀ collapses to ▶) ── */
	.sidebar-foot-toggle {
		border-top: 1px solid rgba(255,255,255,.1);
		padding: 4px 4px 4px 0;
		display: flex;
		justify-content: flex-end;
		flex-shrink: 0;
	}
	#sidebarToggle {
		background: none;
		border: none;
		color: #c8e6c9;
		cursor: pointer;
		padding: 6px 10px;
		font-size: 14px;
		line-height: 1;
		border-radius: 4px;
		transition: background .15s, color .15s, transform .22s;
		display: flex;
		align-items: center;
	}
	#sidebarToggle:hover { background: rgba(255,255,255,.13); color: #fff; }

	/* ── Sidebar drag-resize handle ── */
	#sidebarResizer {
		width: 5px;
		cursor: col-resize;
		background: transparent;
		flex-shrink: 0;
		z-index: 10;
		transition: background .15s;
	}
	#sidebarResizer:hover,
	#sidebarResizer.is-dragging { background: rgba(100,221,130,.4); }
	#sidebar.is-dragging { transition: none !important; }

	/* ── Overlay backdrop (mobile) ── */
	#sidebarOverlay {
		display: none;
		position: fixed;
		top: 44px; left: 0; right: 0; bottom: 0;
		background: rgba(0,0,0,0.45);
		z-index: 299;
	}
	body.sidebar-open #sidebarOverlay { display: block; }

	/* ── Mobile: sidebar as slide-in overlay ── */
	@media (max-width: 767px) {
		#topbarToggle { display: flex; }
		#sidebarResizer { display: none; }
		.sidebar-foot-toggle { justify-content: center; }
		#sidebar {
			position: fixed;
			top: 44px; left: 0; bottom: 0;
			height: auto;
			z-index: 300;
			width: 240px !important;
			min-width: 0;
			transform: translateX(-100%);
			transition: transform 0.22s ease !important;
			will-change: transform;
		}
		body.sidebar-open #sidebar {
			transform: translateX(0);
			box-shadow: 4px 0 24px rgba(0,0,0,0.45);
		}
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

    boolean _isAdminUser = "admin".equalsIgnoreCase(_uname);
    boolean _hasRolePerms = false;
    Set<String> _permPages = new HashSet<String>();
    if (!_isAdminUser && _loggedUser != null && _loggedUser.getUserTypes() != null) {
        Set<Integer> _roleIds = new HashSet<Integer>();
        for (UserTypeEntity _r : _loggedUser.getUserTypes()) {
            if (_r != null) _roleIds.add(_r.getUserTypeId());
        }
        if (!_roleIds.isEmpty()) {
            try {
                Map<Integer, Set<String>> _allPerms = new RolePermissionDao().fetchAllByRole();
                for (Integer _rid : _roleIds) {
                    Set<String> _rp = _allPerms.get(_rid);
                    if (_rp != null && !_rp.isEmpty()) {
                        _hasRolePerms = true;
                        _permPages.addAll(_rp);
                    }
                }
            } catch (Exception _pe) { /* DB not ready — allow all */ }
        }
    }
%>

<!-- ── Top menu bar ── -->
<div id="topbar">

	<!-- Brand + hamburger (left — hamburger visible on mobile only) -->
	<div class="topbar-left">
		<button id="topbarToggle" title="Toggle navigation" aria-label="Toggle navigation">&#9776;</button>
		<div class="topbar-brand">
			<span class="topbar-brand-icon">&#127807;</span>
			<div class="topbar-brand-text">
				<span class="topbar-brand-name"><%= msg.getString("nav.brand_name") %></span>
				<span class="topbar-brand-sub"><%= msg.getString("nav.brand_sub") %></span>
			</div>
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

<div id="sidebarOverlay"></div>

<div id="appShell">

	<!-- ── Sidebar ── -->
	<aside id="sidebar">

		<nav id="sideNav">

			<div class="nav-group">
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("dashboard")) { %>
				<a class="nav-link nav-link-dash" href="view/user/dashboard.jsp" target="contentFrame" title="<%= msg.getString("nav.dashboard") %>"><em class="nav-icon">&#128202;</em><span class="nav-text"><%= msg.getString("nav.dashboard") %></span></a>
				<% } %>
			</div>

			<% if (_isAdminUser) { %>
			<div class="nav-group nav-group-admin">
				<div class="nav-group-title"><em class="nav-icon">&#9881;</em><span class="nav-text">Administration<span class="nav-admin-badge">Admin</span></span></div>
				<a class="nav-link" href="view/user/masterData.jsp" target="contentFrame" title="<%= msg.getString("nav.master_configuration") %>"><em class="nav-icon">&#128218;</em><span class="nav-text"><%= msg.getString("nav.master_configuration") %></span></a>
				<a class="nav-link" href="view/user/registerUser.jsp" target="contentFrame" title="<%= msg.getString("nav.master_register_user") %>"><em class="nav-icon">&#128101;</em><span class="nav-text"><%= msg.getString("nav.master_register_user") %></span></a>
				<a class="nav-link" href="view/configuration/systemConfig.jsp" target="contentFrame" title="System Configuration"><em class="nav-icon">&#128295;</em><span class="nav-text">System Configuration</span></a>
			</div>
			<% } %>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#128100;</em><span class="nav-text"><%= msg.getString("nav.group_employee") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("employee_view")) { %>
				<a class="nav-link" href="view/user/employeeViewAll.jsp" target="contentFrame" title="<%= msg.getString("nav.employee_view_all") %>"><em class="nav-icon">&#128196;</em><span class="nav-text"><%= msg.getString("nav.employee_view_all") %></span></a>
				<% } %>
			</div>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#127806;</em><span class="nav-text"><%= msg.getString("nav.group_farm_setup") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("farm_site_alloc")) { %>
				<a class="nav-link" href="view/user/assignCropToSite.jsp" target="contentFrame" title="<%= msg.getString("nav.farm_site_resource_allocation") %>"><em class="nav-icon">&#127757;</em><span class="nav-text"><%= msg.getString("nav.farm_site_resource_allocation") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("farm_view_tasks")) { %>
				<a class="nav-link" href="view/user/01assignTaskToEmployeeViewAll.jsp" target="contentFrame" title="<%= msg.getString("nav.farm_view_assign_tasks") %>"><em class="nav-icon">&#128203;</em><span class="nav-text"><%= msg.getString("nav.farm_view_assign_tasks") %></span></a>
				<% } %>
			</div>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#128176;</em><span class="nav-text"><%= msg.getString("nav.group_account") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("process_payment")) { %>
				<a class="nav-link" href="view/user/02employeePaymentProcess.jsp" target="contentFrame" title="<%= msg.getString("nav.account_process_payment") %>"><em class="nav-icon">&#128180;</em><span class="nav-text"><%= msg.getString("nav.account_process_payment") %></span></a>
				<% } %>
			</div>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#127978;</em><span class="nav-text"><%= msg.getString("nav.group_vendor") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("vendor_add")) { %>
				<a class="nav-link" href="view/user/addVendor.jsp" target="contentFrame" title="<%= msg.getString("nav.vendor_add") %>"><em class="nav-icon">&#10133;</em><span class="nav-text"><%= msg.getString("nav.vendor_add") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("vendor_assign")) { %>
				<a class="nav-link" href="view/user/assignVendorToProduct.jsp" target="contentFrame" title="<%= msg.getString("nav.vendor_assign_products") %>"><em class="nav-icon">&#128230;</em><span class="nav-text"><%= msg.getString("nav.vendor_assign_products") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("vendor_view")) { %>
				<a class="nav-link" href="view/user/assignVendorToProductView.jsp" target="contentFrame" title="<%= msg.getString("nav.vendor_view_products") %>"><em class="nav-icon">&#128203;</em><span class="nav-text"><%= msg.getString("nav.vendor_view_products") %></span></a>
				<% } %>
			</div>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#128200;</em><span class="nav-text"><%= msg.getString("nav.group_sales") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("sales_buyers")) { %>
				<a class="nav-link" href="view/user/addBuyer.jsp" target="contentFrame" title="<%= msg.getString("nav.sales_manage_buyers") %>"><em class="nav-icon">&#128101;</em><span class="nav-text"><%= msg.getString("nav.sales_manage_buyers") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("sales_crop")) { %>
				<a class="nav-link" href="view/user/saleProcess.jsp" target="contentFrame" title="<%= msg.getString("nav.sales_crop_sales") %>"><em class="nav-icon">&#127806;</em><span class="nav-text"><%= msg.getString("nav.sales_crop_sales") %></span></a>
				<% } %>
			</div>

			<div class="nav-group">
				<div class="nav-group-title"><em class="nav-icon">&#128202;</em><span class="nav-text"><%= msg.getString("nav.group_reports") %></span></div>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("report_site")) { %>
				<a class="nav-link" href="view/user/reportSite.jsp" target="contentFrame" title="<%= msg.getString("nav.report_site_expenditure") %>"><em class="nav-icon">&#127981;</em><span class="nav-text"><%= msg.getString("nav.report_site_expenditure") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("report_employee")) { %>
				<a class="nav-link" href="view/user/reportEmployee.jsp" target="contentFrame" title="<%= msg.getString("nav.report_employee_payments") %>"><em class="nav-icon">&#128196;</em><span class="nav-text"><%= msg.getString("nav.report_employee_payments") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("report_income")) { %>
				<a class="nav-link" href="view/user/reportIncome.jsp" target="contentFrame" title="<%= msg.getString("nav.report_income") %>"><em class="nav-icon">&#128201;</em><span class="nav-text"><%= msg.getString("nav.report_income") %></span></a>
				<% } %>
				<% if (_isAdminUser || !_hasRolePerms || _permPages.contains("report_pl")) { %>
				<a class="nav-link" href="view/user/reportProfitLoss.jsp" target="contentFrame" title="<%= msg.getString("nav.report_profit_loss") %>"><em class="nav-icon">&#128200;</em><span class="nav-text"><%= msg.getString("nav.report_profit_loss") %></span></a>
				<% } %>
			</div>

		</nav>
		<script>
		document.querySelectorAll('#sideNav .nav-group').forEach(function(g) {
		    if (!g.querySelector('.nav-link')) g.style.display = 'none';
		});
		</script>

		<!-- ── Sidebar foot: collapse toggle ── -->
		<div class="sidebar-foot-toggle">
			<button id="sidebarToggle" title="Collapse / expand sidebar" aria-label="Collapse sidebar">&#9664;</button>
		</div>

	</aside>

	<!-- ── Drag resize handle ── -->
	<div id="sidebarResizer"></div>

	<!-- ── Content iframe ── -->
	<iframe id="contentFrame" name="contentFrame"
		src="about:blank"
		frameborder="0">
	</iframe>

</div>

<script>
    /* Safety net: if shell somehow loads inside the iframe, break it out. */
    if (window !== window.top) {
        window.top.location.replace(window.location.href);
    }
</script>
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

<script>
(function () {
    var sidebar     = document.getElementById('sidebar');
    var resizer     = document.getElementById('sidebarResizer');
    var sideBtn     = document.getElementById('sidebarToggle');   // in sidebar foot
    var mobileBtn   = document.getElementById('topbarToggle');    // in topbar (mobile only)
    var overlay     = document.getElementById('sidebarOverlay');
    var KEY_W       = 'sevak_sidebar_w';
    var KEY_NARROW  = 'sevak_sidebar_narrow';
    var NARROW_THRESHOLD = 80;   // px — below this width → icon-only mode
    var DEFAULT_W   = 220;

    function isMobile() { return window.innerWidth < 768; }

    function setNarrow(narrow) {
        if (narrow) {
            sidebar.classList.add('sidebar-narrow');
        } else {
            sidebar.classList.remove('sidebar-narrow');
        }
    }

    function applyWidth(w) {
        sidebar.style.width = w + 'px';
        setNarrow(w < NARROW_THRESHOLD);
    }

    /* ── Restore saved desktop width / narrow state ── */
    if (!isMobile()) {
        var savedW = parseInt(localStorage.getItem(KEY_W), 10);
        if (savedW && savedW >= 32) {
            applyWidth(savedW);
        } else if (localStorage.getItem(KEY_NARROW) === '1') {
            applyWidth(40);
        }
    }

    /* ── Sidebar foot toggle (◀ / ▶) ── */
    sideBtn.addEventListener('click', function () {
        if (isMobile()) {
            document.body.classList.toggle('sidebar-open');
            return;
        }
        var isNarrow = sidebar.classList.contains('sidebar-narrow');
        if (isNarrow) {
            /* Expand back to last saved full width or default */
            var target = parseInt(localStorage.getItem(KEY_W), 10) || DEFAULT_W;
            if (target < NARROW_THRESHOLD) target = DEFAULT_W;
            applyWidth(target);
            localStorage.setItem(KEY_NARROW, '0');
        } else {
            /* Collapse to icon-only */
            localStorage.setItem(KEY_W, parseInt(sidebar.offsetWidth, 10));
            applyWidth(40);
            localStorage.setItem(KEY_NARROW, '1');
        }
    });

    /* ── Mobile topbar hamburger ── */
    if (mobileBtn) {
        mobileBtn.addEventListener('click', function () {
            document.body.classList.toggle('sidebar-open');
        });
    }

    overlay.addEventListener('click', function () {
        document.body.classList.remove('sidebar-open');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') document.body.classList.remove('sidebar-open');
    });

    window.addEventListener('resize', function () {
        if (!isMobile()) document.body.classList.remove('sidebar-open');
    });

    /* ── Drag-resize ── */
    resizer.addEventListener('mousedown', function (e) {
        e.preventDefault();
        var startX  = e.clientX;
        var startW  = sidebar.offsetWidth;
        sidebar.classList.add('is-dragging');
        resizer.classList.add('is-dragging');

        function onMove(e) {
            var newW = Math.max(32, startW + (e.clientX - startX));
            sidebar.style.width = newW + 'px';
            setNarrow(newW < NARROW_THRESHOLD);
        }

        function onUp() {
            sidebar.classList.remove('is-dragging');
            resizer.classList.remove('is-dragging');
            var finalW = sidebar.offsetWidth;
            if (finalW >= NARROW_THRESHOLD) {
                localStorage.setItem(KEY_W, finalW);
                localStorage.setItem(KEY_NARROW, '0');
            } else {
                localStorage.setItem(KEY_NARROW, '1');
            }
            document.removeEventListener('mousemove', onMove);
            document.removeEventListener('mouseup', onUp);
        }

        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
    });
})();
</script>
</body>
</html>
