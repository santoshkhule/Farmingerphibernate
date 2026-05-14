package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.util.HibernateUtil;

public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(DashboardServlet.class);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control", "no-cache");
        PrintWriter out = res.getWriter();
        Session session = HibernateUtil.opensession();
        try {
            StringBuilder j = new StringBuilder("{");

            // KPI counts
            long totalSites       = qLong(session, "SELECT COUNT(s) FROM ConfigSiteInformationEntity s");
            long totalEmployees   = qLong(session, "SELECT COUNT(e) FROM EmployeeInfoEntity e");
            long totalCrops       = qLong(session, "SELECT COUNT(c) FROM ConfigCropEntity c");
            long totalAssignments = qLong(session, "SELECT COUNT(a) FROM AssignEmployeeToFarmEntity a");
            double totalPaid      = qDouble(session, "SELECT SUM(p.amount) FROM PaymentProcessingEntity p");
            double totalAssigned  = qDouble(session, "SELECT SUM(a.amount) FROM AssignEmployeeToFarmEntity a");
            double totalBalance   = totalAssigned - totalPaid;

            j.append("\"kpi\":{")
             .append("\"totalSites\":").append(totalSites).append(",")
             .append("\"totalEmployees\":").append(totalEmployees).append(",")
             .append("\"totalCrops\":").append(totalCrops).append(",")
             .append("\"totalAssignments\":").append(totalAssignments).append(",")
             .append("\"totalPaid\":").append(fmt(totalPaid)).append(",")
             .append("\"totalBalance\":").append(fmt(totalBalance))
             .append("}");

            // Crops per site (count crop-assignment records per site)
            @SuppressWarnings("unchecked")
            List<Object[]> cropsPerSite = session.createQuery(
                "SELECT s.siteName, COUNT(r) " +
                "FROM ConfigSiteInformationEntity s " +
                "LEFT JOIN s.cropToSiteEntity a " +
                "LEFT JOIN a.cropToSiteRefEntity r " +
                "GROUP BY s.siteInfoId, s.siteName " +
                "ORDER BY s.siteName").list();
            j.append(",\"cropsPerSite\":[");
            for (int i = 0; i < cropsPerSite.size(); i++) {
                Object[] r = cropsPerSite.get(i);
                if (i > 0) j.append(",");
                j.append("{\"site\":").append(js(r[0])).append(",\"count\":").append(toLong(r[1])).append("}");
            }
            j.append("]");

            // Work status breakdown
            @SuppressWarnings("unchecked")
            List<Object[]> workStatus = session.createQuery(
                "SELECT a.workStatus, COUNT(a) FROM AssignEmployeeToFarmEntity a " +
                "GROUP BY a.workStatus").list();
            j.append(",\"workStatus\":[");
            for (int i = 0; i < workStatus.size(); i++) {
                Object[] r = workStatus.get(i);
                if (i > 0) j.append(",");
                String status = (r[0] != null && !r[0].toString().trim().isEmpty()) ? r[0].toString().trim() : "Unknown";
                j.append("{\"status\":").append(js(status)).append(",\"count\":").append(toLong(r[1])).append("}");
            }
            j.append("]");

            // Salary paid per site (via payment → employee assignment → site)
            @SuppressWarnings("unchecked")
            List<Object[]> salaryPerSite = session.createQuery(
                "SELECT si.siteName, SUM(p.amount) " +
                "FROM PaymentProcessingEntity p " +
                "JOIN p.employeeToFarm aef " +
                "JOIN aef.cropToSiteEntity cts " +
                "JOIN cts.siteInformationEntity si " +
                "GROUP BY si.siteInfoId, si.siteName " +
                "ORDER BY si.siteName").list();
            j.append(",\"salaryPerSite\":[");
            for (int i = 0; i < salaryPerSite.size(); i++) {
                Object[] r = salaryPerSite.get(i);
                if (i > 0) j.append(",");
                j.append("{\"site\":").append(js(r[0])).append(",\"amount\":").append(fmt(toDouble(r[1]))).append("}");
            }
            j.append("]");

            // Monthly payment trend (last 18 months worth of data)
            @SuppressWarnings("unchecked")
            List<Object[]> monthly = session.createQuery(
                "SELECT YEAR(p.date), MONTH(p.date), SUM(p.amount) " +
                "FROM PaymentProcessingEntity p " +
                "GROUP BY YEAR(p.date), MONTH(p.date) " +
                "ORDER BY YEAR(p.date) ASC, MONTH(p.date) ASC").list();
            j.append(",\"monthlyTrend\":[");
            String[] MON = {"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
            for (int i = 0; i < monthly.size(); i++) {
                Object[] r = monthly.get(i);
                if (i > 0) j.append(",");
                int yr = ((Number) r[0]).intValue();
                int mo = ((Number) r[1]).intValue();
                j.append("{\"month\":\"").append(MON[mo]).append(" ").append(yr)
                 .append("\",\"amount\":").append(fmt(toDouble(r[2]))).append("}");
            }
            j.append("]");

            // Top employees by total assignment amount
            @SuppressWarnings("unchecked")
            List<Object[]> topEmp = session.createQuery(
                "SELECT ei.firstName, ei.lastName, SUM(a.amount) " +
                "FROM AssignEmployeeToFarmEntity a JOIN a.employeeInfoEntity ei " +
                "GROUP BY ei.employeeInfoId, ei.firstName, ei.lastName " +
                "ORDER BY SUM(a.amount) DESC").setMaxResults(6).list();
            j.append(",\"topEmployees\":[");
            for (int i = 0; i < topEmp.size(); i++) {
                Object[] r = topEmp.get(i);
                if (i > 0) j.append(",");
                String name = (r[0] != null ? r[0].toString() : "") + " " + (r[1] != null ? r[1].toString() : "");
                j.append("{\"name\":").append(js(name.trim())).append(",\"amount\":").append(fmt(toDouble(r[2]))).append("}");
            }
            j.append("]");

            j.append("}");
            out.print(j);

        } catch (HibernateException e) {
            logger.error("Dashboard data error", e);
            res.setStatus(500);
            out.print("{\"error\":\"data load failed\"}");
        } finally {
            session.clear();
            session.close();
        }
    }

    private long qLong(Session s, String hql) {
        Object r = s.createQuery(hql).uniqueResult();
        return r != null ? ((Number) r).longValue() : 0L;
    }

    private double qDouble(Session s, String hql) {
        Object r = s.createQuery(hql).uniqueResult();
        return r != null ? ((Number) r).doubleValue() : 0.0;
    }

    private long toLong(Object o) { return o != null ? ((Number) o).longValue() : 0L; }
    private double toDouble(Object o) { return o != null ? ((Number) o).doubleValue() : 0.0; }

    private String fmt(double d) { return String.format("%.2f", d); }

    private String js(Object o) {
        if (o == null) return "\"\"";
        String s = o.toString().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
        return "\"" + s + "\"";
    }
}
