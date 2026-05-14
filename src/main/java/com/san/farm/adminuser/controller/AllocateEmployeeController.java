package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignCropToSiteService;
import com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;

public class AllocateEmployeeController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(AllocateEmployeeController.class);

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cropToSiteId = 0;
        try {
            String ctSid = request.getParameter("cropToSiteId");
            if (ctSid != null && !ctSid.trim().isEmpty())
                cropToSiteId = Integer.parseInt(ctSid.trim());

            String action = request.getParameter("action");
            AssignResourceEmployeeToFarmService svc = new AssignResourceEmployeeToFarmService();

            /* resolve physical siteInfoId from cropToSiteId */
            int siteInfoId = 0;
            if (cropToSiteId > 0) {
                AssignCropToSiteService cropSvc = new AssignCropToSiteService();
                AssignCropToSiteEntity cropToSite = cropSvc.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);
                if (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                    siteInfoId = cropToSite.getSiteInformationEntity().getSiteInfoId();
            }

            if ("save".equals(action)) {
                String[] empIds       = request.getParameterValues("empId");
                String[] workDates    = request.getParameterValues("workDate");
                String[] taskCsvs     = request.getParameterValues("taskIdsCsv");
                String[] typeOfWorks  = request.getParameterValues("typeOfWork");
                String[] amounts      = request.getParameterValues("amount");
                String[] advPayments  = request.getParameterValues("advPayment");
                String[] statuses     = request.getParameterValues("workStatus");
                String[] remarks      = request.getParameterValues("remark");

                if (empIds != null) {
                    for (int i = 0; i < empIds.length; i++) {
                        if (empIds[i] == null || empIds[i].trim().isEmpty()) continue;
                        int empId = Integer.parseInt(empIds[i].trim());
                        if (empId <= 0) continue;

                        String taskIdsCsv = (taskCsvs != null && i < taskCsvs.length && taskCsvs[i] != null)
                                          ? taskCsvs[i].trim() : "";

                        double amount = 0;
                        if (amounts != null && i < amounts.length && amounts[i] != null && !amounts[i].trim().isEmpty())
                            try { amount = Double.parseDouble(amounts[i].trim()); } catch (Exception ignore) {}

                        double advPayment = 0;
                        if (advPayments != null && i < advPayments.length && advPayments[i] != null && !advPayments[i].trim().isEmpty())
                            try { advPayment = Double.parseDouble(advPayments[i].trim()); } catch (Exception ignore) {}

                        String workDate    = (workDates   != null && i < workDates.length)   ? workDates[i]   : "";
                        String typeOfWork  = (typeOfWorks != null && i < typeOfWorks.length) ? typeOfWorks[i] : "Contract";
                        String status      = (statuses    != null && i < statuses.length)    ? statuses[i]    : "Pending";
                        String remark      = (remarks     != null && i < remarks.length)     ? remarks[i]     : "";

                        if (svc.existsByEmpDateTaskSite(siteInfoId, empId, workDate, taskIdsCsv)) {
                            logger.warn("Skipping duplicate: siteInfoId={}, empId={}, date={}, tasks={}", siteInfoId, empId, workDate, taskIdsCsv);
                        } else {
                            svc.saveFromParams(cropToSiteId, empId, workDate, taskIdsCsv, amount, advPayment, status, remark, typeOfWork);
                        }
                    }
                    logger.info("Saved {} employee allocations for cropToSiteId={}", empIds.length, cropToSiteId);
                }

            } else if ("update".equals(action)) {
                String idStr = request.getParameter("assignResourceId");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    int assignResourceId = Integer.parseInt(idStr.trim());
                    int empId = 0;
                    try { empId = Integer.parseInt(request.getParameter("empId").trim()); } catch (Exception ignore) {}
                    String workDate   = request.getParameter("workDate")    != null ? request.getParameter("workDate")    : "";
                    String taskIdsCsv = request.getParameter("taskIdsCsv")  != null ? request.getParameter("taskIdsCsv")  : "";
                    String typeOfWork = request.getParameter("typeOfWork")   != null ? request.getParameter("typeOfWork")  : "Contract";
                    String status     = request.getParameter("workStatus")   != null ? request.getParameter("workStatus")  : "Pending";
                    String remark     = request.getParameter("remark")       != null ? request.getParameter("remark")      : "";
                    double amount = 0, advPayment = 0;
                    try { amount     = Double.parseDouble(request.getParameter("amount").trim());     } catch (Exception ignore) {}
                    try { advPayment = Double.parseDouble(request.getParameter("advPayment").trim()); } catch (Exception ignore) {}
                    svc.updateRecord(assignResourceId, empId, workDate, taskIdsCsv, amount, advPayment, status, remark, typeOfWork);
                    logger.info("Updated assignResourceId={}", assignResourceId);
                }

            } else if ("delete".equals(action)) {
                String idStr = request.getParameter("assignResourceId");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    int assignResourceId = Integer.parseInt(idStr.trim());
                    svc.deleteAssignResources(assignResourceId);
                    logger.info("Deleted assignResourceId={}", assignResourceId);
                }
            }

        } catch (Exception e) {
            logger.error("Error in AllocateEmployeeController", e);
        } finally {
            response.sendRedirect(request.getContextPath() +
                "/view/user/allocateEmployeeToSite.jsp?cropToSiteId=" + cropToSiteId);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doProcess(req, res);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doProcess(req, res);
    }
}
