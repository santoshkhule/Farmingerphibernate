<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.san.conf.service.SystemConfigService,
                 com.san.farm.license.LicenseClient,
                 com.san.farm.license.LicenseStatus,
                 com.san.farm.util.BuildConfig,
                 com.san.farm.login.entity.LoginUser,
                 java.io.File,
                 java.util.Properties,
                 java.text.SimpleDateFormat,
                 java.util.Date" %>
<%@ include file="../../lang.jsp" %>
<%@ include file="../../userPerms.jsp" %>
<%
    /* Admin-only page */
    if (!_isAdmin) {
        response.sendRedirect(request.getContextPath() + "/shell.jsp");
        return;
    }

    String _webappRoot = application.getRealPath("/");
    SystemConfigService _sc = new SystemConfigService();

    String _rootLevel = _sc.getRootLogLevel();
    String _appLevel  = _sc.getAppLogLevel();
    Properties _dbp   = _sc.getDbProperties(_webappRoot);
    File _logFile     = _sc.getLogFile(_webappRoot);
    boolean _logExists = _logFile != null && _logFile.exists();

    /* License server properties (same application.properties file) */
    String _licUrl     = _dbp.getProperty("license.server.url", "");
    String _licEnabled = _dbp.getProperty("license.server.enabled", "true");

    /* Live status — checked once here so it shows in the tab without a round-trip */
    LicenseStatus _licStatus = LicenseClient.check();

    String _activeTab = request.getParameter("tab");
    if (!"dbProps".equals(_activeTab) && !"downloadLogs".equals(_activeTab)
            && !"licenseServer".equals(_activeTab))
        _activeTab = "logLevel";

    String _msg = request.getParameter("msg");

    /* Helper: format file size */
    String _logSizeFmt = "";
    String _logModFmt  = "";
    if (_logExists) {
        long bytes = _logFile.length();
        if (bytes < 1024)           _logSizeFmt = bytes + " B";
        else if (bytes < 1048576)   _logSizeFmt = String.format("%.1f KB", bytes / 1024.0);
        else                        _logSizeFmt = String.format("%.2f MB", bytes / 1048576.0);
        _logModFmt = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date(_logFile.lastModified()));
    }

    /* Helper: HTML-escape */
    java.util.function.Function<String,String> esc = s -> s == null ? "" :
        s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");

    String _ctxPath = request.getContextPath();

    /* Level badge colour */
    java.util.Map<String,String> _lvlColor = new java.util.HashMap<>();
    _lvlColor.put("TRACE","#7b1fa2"); _lvlColor.put("DEBUG","#1565c0");
    _lvlColor.put("INFO","#2e7d32");  _lvlColor.put("WARN","#e65100");
    _lvlColor.put("ERROR","#c62828"); _lvlColor.put("FATAL","#880e4f");
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<title>System Configuration</title>
<style>
    /* ── tab nav (reused from masterData style) ── */
    .sc-tabs          { display:flex; flex-wrap:wrap; gap:3px;
                        border-bottom:2px solid var(--green-dk,#2e7d32);
                        margin-bottom:20px; }
    .sc-tab-btn       { background:#f5f5f5; border:1px solid #ccc; border-bottom:none;
                        padding:9px 24px; cursor:pointer; font-size:13px; font-weight:600;
                        color:#555; border-radius:4px 4px 0 0;
                        transition:background .15s, color .15s; }
    .sc-tab-btn:hover { background:#e8f5e9; color:var(--green-dk,#2e7d32); border-color:var(--green-bd,#a5d6a7); }
    .sc-tab-btn.active{ background:var(--green-dk,#2e7d32); color:#fff;
                        border-color:var(--green-dk,#2e7d32); }
    .sc-tab-panel     { display:none; }
    .sc-tab-panel.active { display:block; }

    /* ── cards ── */
    .sc-card          { background:#f8fdf8; border:1px solid var(--green-bd,#a5d6a7);
                        border-radius:6px; padding:16px 20px; margin-bottom:16px; }
    .sc-card-title    { font-size:11px; font-weight:700; text-transform:uppercase;
                        letter-spacing:.5px; color:var(--green-dk,#2e7d32); margin-bottom:14px; }
    .sc-row           { display:flex; flex-wrap:wrap; align-items:flex-end; gap:14px 24px; }
    .sc-field         { display:flex; flex-direction:column; gap:4px; }
    .sc-field label   { font-size:11px; font-weight:700; text-transform:uppercase;
                        letter-spacing:.4px; color:var(--text-muted,#666); }
    .sc-field input,
    .sc-field select  { padding:7px 10px; border:1px solid #ccc; border-radius:4px;
                        font-size:13px; box-sizing:border-box; }
    .sc-field input:focus,
    .sc-field select:focus { border-color:var(--green-dk,#2e7d32); outline:none;
                             box-shadow:0 0 0 2px rgba(46,125,50,.15); }
    .sc-wide          { min-width:340px; }
    .sc-med           { min-width:220px; }
    .sc-sm            { min-width:140px; }

    /* ── buttons ── */
    .btn-sc-save      { background:var(--green-dk,#2e7d32); color:#fff; border:none;
                        padding:8px 22px; border-radius:4px; font-size:13px;
                        font-weight:600; cursor:pointer; }
    .btn-sc-save:hover{ background:#1b5e20; }

    /* ── flash alerts ── */
    .sc-alert         { display:flex; align-items:center; gap:8px; border-radius:4px;
                        padding:9px 14px; margin-bottom:14px; font-size:13px; font-weight:600; }
    .sc-alert.ok      { background:#e8f5e9; border:1px solid #a5d6a7; color:#2e7d32; }
    .sc-alert.err     { background:#fdecea; border:1px solid #ef9a9a; color:#c62828; }
    .sc-alert.warn    { background:#fff3e0; border:1px solid #ffcc80; color:#e65100; }

    /* ── level badge ── */
    .lvl-badge        { display:inline-block; padding:2px 10px; border-radius:12px;
                        font-size:12px; font-weight:700; color:#fff; letter-spacing:.5px; }

    /* ── log info table ── */
    .sc-info-table    { width:100%; border-collapse:collapse; font-size:13px; }
    .sc-info-table td { padding:8px 12px; border-bottom:1px solid #e8e8e8; vertical-align:middle; }
    .sc-info-table td:first-child { font-weight:700; color:#555; width:180px; }
    .sc-info-table tr:last-child td { border:none; }

    /* ── divider ── */
    .sc-divider       { border:none; border-top:1px solid #e8e8e8; margin:16px 0; }

    /* ── note box ── */
    .sc-note          { background:#fff8e1; border:1px solid #ffe082; border-radius:4px;
                        padding:9px 14px; margin-bottom:14px; font-size:12px; color:#5d4037; }
    .sc-note strong   { font-weight:700; }

    /* ── download area ── */
    .sc-dl-box        { display:flex; align-items:center; gap:20px; background:#f5f5f5;
                        border:1px solid #e0e0e0; border-radius:6px; padding:14px 18px; }
    .sc-dl-icon       { font-size:32px; line-height:1; }
    .sc-dl-info       { flex:1; }
    .sc-dl-name       { font-size:14px; font-weight:700; color:#222; }
    .sc-dl-meta       { font-size:12px; color:#666; margin-top:2px; }
    .btn-dl           { background:#1565c0; color:#fff; border:none; padding:9px 22px;
                        border-radius:4px; font-size:13px; font-weight:600; cursor:pointer;
                        text-decoration:none; display:inline-block; }
    .btn-dl:hover     { background:#0d47a1; }
</style>
</head>
<body>
<%@include file="../../header.jsp"%>
<fieldset>
<legend>System Configuration</legend>

<!-- ── Tab nav ── -->
<div class="sc-tabs">
    <button class="sc-tab-btn<%="logLevel".equals(_activeTab)?" active":""%>"
            onclick="scTab('logLevel')">&#128195; Log Level</button>
    <button class="sc-tab-btn<%="dbProps".equals(_activeTab)?" active":""%>"
            onclick="scTab('dbProps')">&#128263; Database</button>
    <button class="sc-tab-btn<%="downloadLogs".equals(_activeTab)?" active":""%>"
            onclick="scTab('downloadLogs')">&#128196; Download Logs</button>
    <button class="sc-tab-btn<%="licenseServer".equals(_activeTab)?" active":""%>"
            onclick="scTab('licenseServer')">&#128273; License Server</button>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 1 : Log Level
     ════════════════════════════════════════════════════════ -->
<div id="sc-tab-logLevel" class="sc-tab-panel<%="logLevel".equals(_activeTab)?" active":""%>">

    <% if ("levelSaved".equals(_msg)) { %>
    <div class="sc-alert ok">&#10003; Log levels updated successfully. Changes are effective immediately.</div>
    <% } %>

    <!-- Current levels summary -->
    <div class="sc-card">
        <div class="sc-card-title">Current Effective Levels</div>
        <table class="sc-info-table">
            <tr>
                <td>Root Logger</td>
                <td>
                    <% String _rlc = _lvlColor.getOrDefault(_rootLevel, "#757575"); %>
                    <span class="lvl-badge" style="background:<%=_rlc%>"><%=_rootLevel%></span>
                    <span style="font-size:12px;color:#888;margin-left:8px;">controls all logging unless overridden</span>
                </td>
            </tr>
            <tr>
                <td>App Logger <code style="font-size:11px">com.san.farm</code></td>
                <td>
                    <% String _alc = _lvlColor.getOrDefault(_appLevel, "#757575"); %>
                    <span class="lvl-badge" style="background:<%=_alc%>"><%=_appLevel%></span>
                    <span style="font-size:12px;color:#888;margin-left:8px;">overrides root for application code</span>
                </td>
            </tr>
        </table>
    </div>

    <!-- Change levels form -->
    <div class="sc-card">
        <div class="sc-card-title">Change Log Levels</div>
        <div class="sc-alert warn">
            &#9888;&nbsp;<strong>Note:</strong> Changes take effect immediately and persist only until the server is restarted.
        </div>
        <form method="post" action="<%=_ctxPath%>/SystemConfigController">
            <input type="hidden" name="action" value="setLogLevel">
            <div class="sc-row">
                <div class="sc-field sc-med">
                    <label for="rootLevel">Root Logger Level</label>
                    <select name="rootLevel" id="rootLevel">
                        <% for (String _lv : new String[]{"TRACE","DEBUG","INFO","WARN","ERROR","FATAL"}) { %>
                        <option value="<%=_lv%>" <%=_lv.equals(_rootLevel)?"selected":""%>><%=_lv%></option>
                        <% } %>
                    </select>
                </div>
                <div class="sc-field sc-med">
                    <label for="appLevel">App Logger Level <small style="font-weight:400;">(com.san.farm)</small></label>
                    <select name="appLevel" id="appLevel">
                        <% for (String _lv : new String[]{"TRACE","DEBUG","INFO","WARN","ERROR","FATAL"}) { %>
                        <option value="<%=_lv%>" <%=_lv.equals(_appLevel)?"selected":""%>><%=_lv%></option>
                        <% } %>
                    </select>
                </div>
                <div style="align-self:flex-end;">
                    <button type="submit" class="btn-sc-save">Apply Levels</button>
                </div>
            </div>
        </form>
        <hr class="sc-divider">
        <div style="font-size:12px;color:#666;">
            <strong>Level hierarchy:</strong>&nbsp;
            TRACE &lt; DEBUG &lt; INFO &lt; WARN &lt; ERROR &lt; FATAL<br>
            Setting a level means that level <em>and all levels above it</em> will be logged.
            For example, setting INFO logs INFO, WARN, ERROR, and FATAL — but not DEBUG or TRACE.
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 2 : Database Properties
     ════════════════════════════════════════════════════════ -->
<div id="sc-tab-dbProps" class="sc-tab-panel<%="dbProps".equals(_activeTab)?" active":""%>">

    <% if ("dbSaved".equals(_msg)) { %>
    <div class="sc-alert ok">&#10003; Database properties saved to <code>application.properties</code>. Restart the server for connection changes to take effect.</div>
    <% } else if ("dbError".equals(_msg)) { %>
    <div class="sc-alert err">&#9888; Failed to save properties. Check server logs for details.</div>
    <% } %>

    <div class="sc-note">
        <strong>Note:</strong> Changing the DB Driver, URL, or Credentials requires a <strong>server restart</strong>
        to reconnect Hibernate. Show SQL and Schema Management changes are also applied on restart.
    </div>

    <div class="sc-card">
        <div class="sc-card-title">Connection Settings</div>
        <form method="post" action="<%=_ctxPath%>/SystemConfigController">
            <input type="hidden" name="action" value="saveDbProps">
            <div class="sc-row">
                <div class="sc-field sc-med">
                    <label for="db.driver">Database Driver</label>
                    <input type="text" name="db.driver" id="db.driver"
                           value="<%=esc.apply(_dbp.getProperty("db.driver",""))%>"
                           placeholder="org.h2.Driver">
                </div>
                <div class="sc-field sc-wide">
                    <label for="db.url">Database URL</label>
                    <input type="text" name="db.url" id="db.url"
                           value="<%=esc.apply(_dbp.getProperty("db.url",""))%>"
                           placeholder="jdbc:h2:file:./farmingErpDb;AUTO_SERVER=TRUE">
                </div>
            </div>
            <div class="sc-row" style="margin-top:12px;">
                <div class="sc-field sc-med">
                    <label for="db.username">Username</label>
                    <input type="text" name="db.username" id="db.username"
                           value="<%=esc.apply(_dbp.getProperty("db.username",""))%>"
                           placeholder="sa">
                </div>
                <div class="sc-field sc-med">
                    <label for="db.password">Password</label>
                    <input type="text" name="db.password" id="db.password"
                           value="<%=esc.apply(_dbp.getProperty("db.password",""))%>"
                           placeholder="(blank for H2)">
                </div>
            </div>

            <hr class="sc-divider">
            <div class="sc-card-title">Hibernate Settings</div>
            <div class="sc-row">
                <div class="sc-field sc-wide">
                    <label for="hibernate.dialect">Hibernate Dialect</label>
                    <input type="text" name="hibernate.dialect" id="hibernate.dialect"
                           value="<%=esc.apply(_dbp.getProperty("hibernate.dialect",""))%>"
                           placeholder="org.hibernate.dialect.H2Dialect">
                </div>
                <div class="sc-field sc-sm">
                    <label for="hibernate.hbm2ddl.auto">Schema Management</label>
                    <select name="hibernate.hbm2ddl.auto" id="hibernate.hbm2ddl.auto">
                        <% for (String _opt : new String[]{"update","validate","create","none"}) { %>
                        <option value="<%=_opt%>" <%=_opt.equals(_dbp.getProperty("hibernate.hbm2ddl.auto","update"))?"selected":""%>><%=_opt%></option>
                        <% } %>
                    </select>
                </div>
                <div class="sc-field sc-sm">
                    <label for="hibernate.show_sql">Show SQL</label>
                    <select name="hibernate.show_sql" id="hibernate.show_sql">
                        <% for (String _opt : new String[]{"false","true"}) { %>
                        <option value="<%=_opt%>" <%=_opt.equals(_dbp.getProperty("hibernate.show_sql","false"))?"selected":""%>><%=_opt%></option>
                        <% } %>
                    </select>
                </div>
                <div class="sc-field sc-sm">
                    <label for="hibernate.format_sql">Format SQL</label>
                    <select name="hibernate.format_sql" id="hibernate.format_sql">
                        <% for (String _opt : new String[]{"false","true"}) { %>
                        <option value="<%=_opt%>" <%=_opt.equals(_dbp.getProperty("hibernate.format_sql","false"))?"selected":""%>><%=_opt%></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div style="margin-top:16px;">
                <button type="submit" class="btn-sc-save">Save Properties</button>
            </div>
        </form>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 3 : Download Logs
     ════════════════════════════════════════════════════════ -->
<div id="sc-tab-downloadLogs" class="sc-tab-panel<%="downloadLogs".equals(_activeTab)?" active":""%>">

    <% if (_logExists) { %>
    <div class="sc-card">
        <div class="sc-card-title">Application Log File</div>
        <div class="sc-dl-box">
            <div class="sc-dl-icon">&#128196;</div>
            <div class="sc-dl-info">
                <div class="sc-dl-name">farmingerERP.log</div>
                <div class="sc-dl-meta">
                    Size: <strong><%=_logSizeFmt%></strong>
                    &bull; Last modified: <strong><%=_logModFmt%></strong>
                    &bull; Path: <code style="font-size:11px"><%=esc.apply(_logFile.getAbsolutePath())%></code>
                </div>
            </div>
            <a class="btn-dl" href="<%=_ctxPath%>/SystemConfigController?action=downloadLog">
                &#8675; Download
            </a>
        </div>
        <div style="margin-top:12px; font-size:12px; color:#666;">
            The log file rolls over when it reaches 10 MB. Up to 10 backup files are kept
            (<code>farmingerERP.log.1</code>, <code>farmingerERP.log.2</code>, &hellip;).
        </div>
    </div>
    <% } else { %>
    <div class="sc-alert warn">
        &#9888;&nbsp;Log file <code>farmingerERP.log</code> not found yet.
        It is created when the first log entry is written after server startup.
    </div>
    <% } %>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 4 : License Server
     ════════════════════════════════════════════════════════ -->
<div id="sc-tab-licenseServer" class="sc-tab-panel<%="licenseServer".equals(_activeTab)?" active":""%>">

    <% if ("licSaved".equals(_msg)) { %>
    <div class="sc-alert ok">&#10003; License server settings saved to <code>application.properties</code>. Changes take effect immediately.</div>
    <% } else if ("licError".equals(_msg)) { %>
    <div class="sc-alert err">&#9888; Failed to save license settings. Check server logs for details.</div>
    <% } %>

    <!-- Current configuration + live status -->
    <div class="sc-card">
        <div class="sc-card-title">Current Configuration &amp; Status</div>
        <table class="sc-info-table">
            <tr>
                <td>License Server URL</td>
                <td>
                    <% if (_licUrl == null || _licUrl.isEmpty()) { %>
                    <em style="color:#999;">Not configured</em>
                    <% } else { %>
                    <code><%=esc.apply(_licUrl)%></code>
                    <% } %>
                </td>
            </tr>
            <tr>
                <td>License Checks</td>
                <td>
                    <% if ("false".equalsIgnoreCase(_licEnabled)) { %>
                    <span style="background:#757575;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">DISABLED</span>
                    <span style="font-size:12px;color:#888;margin-left:8px;">All logins are permitted regardless of license</span>
                    <% } else { %>
                    <span style="background:#2e7d32;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">ENABLED</span>
                    <% } %>
                </td>
            </tr>
            <tr>
                <td>Server Reachability</td>
                <td>
                    <% if (_licStatus.noConfig) { %>
                    <span style="background:#757575;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">N/A</span>
                    <span style="font-size:12px;color:#888;margin-left:8px;">No URL configured</span>
                    <% } else if (_licStatus.unreachable) { %>
                    <span style="background:#e65100;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">UNREACHABLE</span>
                    <span style="font-size:12px;color:#888;margin-left:8px;">Could not connect — logins are still allowed (fail-open)</span>
                    <% } else { %>
                    <span style="background:#1565c0;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">CONNECTED</span>
                    <% } %>
                </td>
            </tr>
            <% if (!_licStatus.noConfig && !_licStatus.unreachable) { %>
            <tr>
                <td>License Validity</td>
                <td>
                    <% if (_licStatus.valid) { %>
                    <span style="background:#2e7d32;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">VALID</span>
                    <% } else { %>
                    <span style="background:#c62828;color:#fff;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:700;">INVALID / EXPIRED</span>
                    <% } %>
                    <% if (_licStatus.message != null) { %>
                    <span style="font-size:12px;color:#888;margin-left:8px;"><%=esc.apply(_licStatus.message)%></span>
                    <% } %>
                </td>
            </tr>
            <% if (_licStatus.licensee != null) { %>
            <tr>
                <td>Licensee</td>
                <td><%=esc.apply(_licStatus.licensee)%></td>
            </tr>
            <% } %>
            <% if (_licStatus.licenseType != null) { %>
            <tr>
                <td>License Type</td>
                <td><%=esc.apply(_licStatus.licenseType)%></td>
            </tr>
            <% } %>
            <% if (_licStatus.expiryDate != null) { %>
            <tr>
                <td>Expiry Date</td>
                <td>
                    <%=esc.apply(_licStatus.expiryDate)%>
                    <% if (_licStatus.daysRemaining == -1) { %>
                    <span style="font-size:12px;color:#888;margin-left:6px;">(Perpetual)</span>
                    <% } else if (_licStatus.daysRemaining >= 0) { %>
                    <span style="font-size:12px;color:#2e7d32;margin-left:6px;"><%=_licStatus.daysRemaining%> day(s) remaining</span>
                    <% } else { %>
                    <span style="font-size:12px;color:#c62828;margin-left:6px;">Expired <%=Math.abs(_licStatus.daysRemaining)%> day(s) ago</span>
                    <% } %>
                </td>
            </tr>
            <% } %>
            <% } %>
        </table>
    </div>

    <!-- Edit form -->
    <div class="sc-card">
        <div class="sc-card-title">Update License Server Settings</div>
        <% if (BuildConfig.IS_PROD) { %>
        <div class="sc-alert warn" style="margin-bottom:14px;">
            &#128274;&nbsp;<strong>Production build</strong> — license enforcement is locked and cannot be disabled.
        </div>
        <% } %>
        <form method="post" action="<%=_ctxPath%>/SystemConfigController">
            <input type="hidden" name="action" value="saveLicenseProps">
            <div class="sc-row">
                <div class="sc-field" style="flex:1;min-width:280px;">
                    <label for="license.server.url">License Server URL</label>
                    <input type="text" name="license.server.url" id="license.server.url"
                           value="<%=esc.apply(_licUrl)%>"
                           placeholder="http://localhost:8085">
                </div>
                <div class="sc-field sc-sm">
                    <label>License Checks</label>
                    <% if (BuildConfig.IS_PROD) { %>
                    <%-- PROD: locked to ENABLED — no select rendered, hidden field forces value --%>
                    <input type="hidden" name="license.server.enabled" value="true">
                    <span style="background:#2e7d32;color:#fff;padding:5px 14px;border-radius:4px;
                                 font-size:13px;font-weight:600;display:inline-block;">
                        &#128274; Enforced (PROD)
                    </span>
                    <% } else { %>
                    <select name="license.server.enabled" id="license.server.enabled">
                        <option value="true"  <%="true".equalsIgnoreCase(_licEnabled) ?"selected":""%>>Enabled</option>
                        <option value="false" <%="false".equalsIgnoreCase(_licEnabled)?"selected":""%>>Disabled</option>
                    </select>
                    <% } %>
                </div>
                <div style="align-self:flex-end;">
                    <button type="submit" class="btn-sc-save">Save Settings</button>
                </div>
            </div>
        </form>
        <hr class="sc-divider">
        <div style="font-size:12px;color:#666;">
            <strong>URL</strong> — base URL of the running Sevak License Server, e.g.
            <code>http://localhost:8085</code>. Leave blank to disable checks.<br>
            <% if (BuildConfig.IS_DEV) { %>
            <strong>License Checks Disabled</strong> — all users can log in regardless of license status.
            Use only for local development.<br>
            <% } %>
            Changes are written to <code>application.properties</code> and take effect on the <strong>next login attempt</strong> — no server restart needed.
        </div>
    </div>
</div>

</fieldset>
<%@include file="../../footer.jsp"%>

<script>
function scTab(name) {
    document.querySelectorAll('.sc-tab-panel').forEach(function(p) { p.classList.remove('active'); });
    document.querySelectorAll('.sc-tab-btn').forEach(function(b)   { b.classList.remove('active'); });
    document.getElementById('sc-tab-' + name).classList.add('active');
    document.querySelectorAll('.sc-tab-btn').forEach(function(b) {
        if (b.getAttribute('onclick') === "scTab('" + name + "')") b.classList.add('active');
    });
    history.replaceState(null, '', '?tab=' + name);
}
</script>
</body>
</html>
