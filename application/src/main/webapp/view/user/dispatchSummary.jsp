<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
         import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity,
                 com.san.farm.adminuser.dao.PaymentProcessingDao,
                 com.san.farm.util.HibernateUtil,
                 org.hibernate.Session,
                 java.util.List" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store");

    if (session.getAttribute("loggedInUser") == null) {
        out.print("{\"error\":\"Unauthorized\"}");
        return;
    }

    int _dsId = 0;
    try { _dsId = Integer.parseInt(request.getParameter("cropToSiteId")); } catch (Exception _e) {}
    if (_dsId <= 0) {
        out.print("{\"pendingCount\":0,\"totalBalance\":0}");
        return;
    }

    int _dsPending = 0;
    double _dsBalance = 0;
    Session _dsSession = HibernateUtil.opensession();
    try {
        @SuppressWarnings("unchecked")
        List<AssignEmployeeToFarmEntity> _dsList = _dsSession.createQuery(
            "FROM AssignEmployeeToFarmEntity e WHERE e.cropToSiteEntity.cropToSiteId = :id")
            .setParameter("id", _dsId).list();
        PaymentProcessingDao _dsDao = new PaymentProcessingDao();
        for (AssignEmployeeToFarmEntity _dsE : _dsList) {
            String _dsStatus = _dsE.getWorkStatus() != null ? _dsE.getWorkStatus() : "";
            if (!"Completed".equalsIgnoreCase(_dsStatus)) _dsPending++;
            double _dsPaid = _dsDao.getTotalSalaryPaidByAssignResourceId(_dsE.getAssignResourceId());
            double _dsBal  = _dsE.getAmount() - _dsE.getAdvPayment() - _dsPaid;
            if (_dsBal > 0) _dsBalance += _dsBal;
        }
    } finally {
        _dsSession.close();
    }

    out.print("{\"pendingCount\":" + _dsPending + ",\"totalBalance\":" + _dsBalance + "}");
%>
