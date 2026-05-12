<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../../css/style.css">
<title>Dashboard</title>
<style>
.dash-wrap   { padding: 14px; }
.dash-header { display:flex; align-items:center; gap:8px; margin-bottom:14px; }
.dash-header h2 { margin:0; font-size:1.1em; }
.dash-ts     { margin-left:auto; font-size:11px; color:var(--text-muted); }
.btn-refresh { padding:3px 10px; font-size:11px; cursor:pointer;
               background:var(--green-lt); border:1px solid var(--green-bd);
               border-radius:var(--r-sm); color:var(--green-dk); }
.btn-refresh:hover { background:var(--green-bd); }

/* KPI grid */
.kpi-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(140px,1fr)); gap:10px; margin-bottom:14px; }
.kpi-card  { background:#fff; border-radius:var(--r-lg); padding:12px 14px;
             box-shadow:var(--sh-sm); border-left:4px solid var(--green-md); }
.kpi-card.blue   { border-left-color:var(--blue-md); }
.kpi-card.amber  { border-left-color:#e65100; }
.kpi-icon  { font-size:1.6em; line-height:1; }
.kpi-label { font-size:10px; color:var(--text-muted); text-transform:uppercase; letter-spacing:.5px; margin-top:6px; }
.kpi-val   { font-size:1.55em; font-weight:700; color:var(--green-dk); line-height:1.1; margin-top:2px; }
.kpi-card.blue  .kpi-val  { color:var(--blue-dk); }
.kpi-card.amber .kpi-val  { color:#e65100; }

/* Chart grid */
.chart-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px; }
@media (max-width:720px) { .chart-grid { grid-template-columns:1fr; } }

.chart-card  { background:#fff; border-radius:var(--r-lg); padding:14px; box-shadow:var(--sh-sm); }
.chart-title { font-size:12px; font-weight:600; color:var(--green-dk); margin-bottom:10px;
               display:flex; align-items:center; gap:5px; }
.chart-box   { position:relative; height:210px; }

/* Employee table */
.emp-table      { width:100%; border-collapse:collapse; font-size:12px; }
.emp-table th   { background:var(--green-lt); color:var(--green-dk); font-weight:600;
                  padding:6px 10px; text-align:left; border-bottom:2px solid var(--green-bd); }
.emp-table td   { padding:5px 10px; border-bottom:1px solid var(--gray-200); }
.emp-table tr:hover td { background:var(--gray-100); }
.bar-cell       { display:flex; align-items:center; gap:6px; }
.bar-bg         { flex:1; background:var(--gray-200); border-radius:3px; height:6px; }
.bar-fill       { height:6px; border-radius:3px; background:var(--green-md); min-width:2px; }

/* Loading / error */
.dash-loading { text-align:center; padding:48px; color:var(--text-muted); font-size:13px; }
.dash-error   { text-align:center; padding:48px; color:var(--red-md);  font-size:13px; }
</style>
</head>
<body>
<div class="dash-wrap">

    <div class="dash-header">
        <span style="font-size:1.5em;">&#128202;</span>
        <h2>Farm Dashboard</h2>
        <span class="dash-ts" id="dashTs"></span>
        <button class="btn-refresh" onclick="loadDashboard()">&#8635; Refresh</button>
    </div>

    <div id="dashContent">
        <div class="dash-loading">Loading dashboard&#8230;</div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
var _charts = {};

function fmtCur(n) {
    var v = parseFloat(n) || 0;
    if (v >= 10000000) return '₹' + (v/10000000).toFixed(1) + 'Cr';
    if (v >= 100000)   return '₹' + (v/100000).toFixed(1)  + 'L';
    if (v >= 1000)     return '₹' + (v/1000).toFixed(1)    + 'K';
    return '₹' + v.toFixed(0);
}

function killChart(id) { if (_charts[id]) { _charts[id].destroy(); delete _charts[id]; } }

function loadDashboard() {
    document.getElementById('dashContent').innerHTML = '<div class="dash-loading">Loading dashboard…</div>';
    fetch('<%= request.getContextPath() %>/DashboardServlet')
        .then(function(r){ return r.json(); })
        .then(function(d){ renderDashboard(d); })
        .catch(function(){
            document.getElementById('dashContent').innerHTML =
                '<div class="dash-error">&#9888; Could not load dashboard data. Check server logs or try refreshing.</div>';
        });
}

function renderDashboard(d) {
    var k = d.kpi || {};

    var html = '<div class="kpi-grid">'
        + kpiCard('&#127759;','','Total Sites',      k.totalSites || 0)
        + kpiCard('&#128100;','blue','Employees',    k.totalEmployees || 0)
        + kpiCard('&#127807;','','Crops Registered', k.totalCrops || 0)
        + kpiCard('&#128203;','blue','Work Orders',  k.totalAssignments || 0)
        + kpiCard('&#128176;','','Salary Paid',      fmtCur(k.totalPaid))
        + kpiCard('&#9888;', 'amber','Balance Due',  fmtCur(k.totalBalance))
        + '</div>'

        + '<div class="chart-grid">'
        + '<div class="chart-card"><div class="chart-title">&#127759; Crops Allocated per Site</div><div class="chart-box"><canvas id="chCrops"></canvas></div></div>'
        + '<div class="chart-card"><div class="chart-title">&#128203; Work Assignment Status</div><div class="chart-box"><canvas id="chStatus"></canvas></div></div>'
        + '</div>'

        + '<div class="chart-grid">'
        + '<div class="chart-card"><div class="chart-title">&#128176; Salary Paid per Site</div><div class="chart-box"><canvas id="chSalary"></canvas></div></div>'
        + '<div class="chart-card"><div class="chart-title">&#128200; Monthly Payment Trend</div><div class="chart-box"><canvas id="chMonthly"></canvas></div></div>'
        + '</div>'

        + '<div class="chart-card" style="margin-bottom:12px;">'
        + '<div class="chart-title">&#127941; Top Employees by Work Amount</div>'
        + buildEmpTable(d.topEmployees || [])
        + '</div>';

    document.getElementById('dashContent').innerHTML = html;
    document.getElementById('dashTs').textContent = 'Updated ' + new Date().toLocaleTimeString();

    buildCropsChart(d.cropsPerSite   || []);
    buildStatusChart(d.workStatus    || []);
    buildSalaryChart(d.salaryPerSite || []);
    buildMonthlyChart(d.monthlyTrend || []);
}

function kpiCard(icon, cls, label, val) {
    return '<div class="kpi-card ' + cls + '">'
        + '<div class="kpi-icon">' + icon + '</div>'
        + '<div class="kpi-label">' + label + '</div>'
        + '<div class="kpi-val">' + val + '</div>'
        + '</div>';
}

function buildEmpTable(data) {
    if (!data.length) return '<p style="color:var(--text-muted);font-size:12px;padding:6px 0;">No employee data yet.</p>';
    var maxAmt = Math.max.apply(null, data.map(function(e){ return parseFloat(e.amount)||0; })) || 1;
    var rows = data.map(function(e, i) {
        var pct = Math.round((parseFloat(e.amount)||0) / maxAmt * 100);
        return '<tr><td style="font-weight:600;color:var(--green-dk);">#' + (i+1) + '</td>'
             + '<td>' + esc(e.name) + '</td>'
             + '<td><div class="bar-cell"><div class="bar-bg"><div class="bar-fill" style="width:' + pct + '%"></div></div>'
             + '<span style="white-space:nowrap;">' + fmtCur(e.amount) + '</span></div></td>'
             + '</tr>';
    }).join('');
    return '<table class="emp-table"><thead><tr><th>#</th><th>Employee</th><th>Total Amount</th></tr></thead><tbody>' + rows + '</tbody></table>';
}

function esc(s) {
    return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

var GREENS  = ['#1b5e20','#2e7d32','#388e3c','#43a047','#66bb6a','#a5d6a7'];
var BLUES   = ['#0d47a1','#1565c0','#1976d2','#1e88e5','#42a5f5','#90caf9'];
var PALETTE = ['#2e7d32','#1565c0','#e65100','#6a1b9a','#00838f','#c62828','#f57f17','#4e342e'];

function buildCropsChart(data) {
    killChart('crops');
    if (!data.length) return;
    _charts['crops'] = new Chart(document.getElementById('chCrops').getContext('2d'), {
        type: 'bar',
        data: {
            labels: data.map(function(d){ return d.site; }),
            datasets: [{
                label: 'Crop Records',
                data: data.map(function(d){ return d.count; }),
                backgroundColor: data.map(function(_, i){ return GREENS[i % GREENS.length]; }),
                borderRadius: 4, borderSkipped: false
            }]
        },
        options: {
            indexAxis: 'y', responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } }
        }
    });
}

function buildStatusChart(data) {
    killChart('status');
    if (!data.length) return;
    var colorMap = {
        'Completed':   '#2e7d32',
        'Pending':     '#f57f17',
        'In Progress': '#1565c0',
        'InProgress':  '#1565c0'
    };
    var colors = data.map(function(d){ return colorMap[d.status] || '#9e9e9e'; });
    _charts['status'] = new Chart(document.getElementById('chStatus').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: data.map(function(d){ return d.status; }),
            datasets: [{ data: data.map(function(d){ return d.count; }),
                         backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right', labels: { font: { size: 11 }, boxWidth: 12 } }
            }
        }
    });
}

function buildSalaryChart(data) {
    killChart('salary');
    if (!data.length) return;
    _charts['salary'] = new Chart(document.getElementById('chSalary').getContext('2d'), {
        type: 'bar',
        data: {
            labels: data.map(function(d){ return d.site; }),
            datasets: [{
                label: 'Salary Paid',
                data: data.map(function(d){ return parseFloat(d.amount); }),
                backgroundColor: data.map(function(_, i){ return BLUES[i % BLUES.length]; }),
                borderRadius: 4, borderSkipped: false
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { callback: function(v){ return fmtCur(v); } }
                }
            }
        }
    });
}

function buildMonthlyChart(data) {
    killChart('monthly');
    if (!data.length) return;
    _charts['monthly'] = new Chart(document.getElementById('chMonthly').getContext('2d'), {
        type: 'line',
        data: {
            labels: data.map(function(d){ return d.month; }),
            datasets: [{
                label: 'Payments',
                data: data.map(function(d){ return parseFloat(d.amount); }),
                borderColor: '#2e7d32',
                backgroundColor: 'rgba(46,125,50,0.08)',
                pointBackgroundColor: '#2e7d32',
                pointRadius: 4,
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { callback: function(v){ return fmtCur(v); } }
                }
            }
        }
    });
}

loadDashboard();
</script>
</body>
</html>
