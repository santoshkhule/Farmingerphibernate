package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignCropToSiteService;
import com.san.farm.adminuser.dao.AssignVendorToProductService;
import com.san.farm.adminuser.dao.SiteProductAllocationService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignVendorToProductEntity;
import com.san.farm.adminuser.entity.SiteProductAllocationEntity;
import com.san.farm.util.FarmUtility;

public class SiteProductAllocationController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(SiteProductAllocationController.class);

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cropToSiteId = 0;
        try {
            String ctSid = request.getParameter("cropToSiteId");
            if (ctSid != null && !ctSid.trim().isEmpty())
                cropToSiteId = Integer.parseInt(ctSid.trim());

            String action = request.getParameter("action");
            SiteProductAllocationService allocationService = new SiteProductAllocationService();

            if ("allocate".equals(action)) {
                int avpId = Integer.parseInt(request.getParameter("assignVendorProductId").trim());
                double qty = Double.parseDouble(request.getParameter("quantity").trim());
                String dateParam = request.getParameter("allocationDate");
                String comment   = request.getParameter("comment");

                AssignCropToSiteService cropSvc = new AssignCropToSiteService();
                AssignVendorToProductService avpSvc = new AssignVendorToProductService();

                AssignCropToSiteEntity cropToSite = cropSvc.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);
                AssignVendorToProductEntity avp =
                    (AssignVendorToProductEntity) com.san.farm.util.HibernateUtil.opensession()
                        .get(AssignVendorToProductEntity.class, avpId);

                SiteProductAllocationEntity entity = new SiteProductAllocationEntity();
                entity.setCropToSite(cropToSite);
                entity.setVendorProduct(avp);
                entity.setQuantity(qty);
                if (dateParam != null && !dateParam.trim().isEmpty())
                    entity.setAllocationDate(Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(dateParam.trim())));
                entity.setComment(comment != null ? comment : "");

                allocationService.save(entity);
                logger.info("Allocated product avpId={} to cropToSiteId={}, qty={}", avpId, cropToSiteId, qty);

            } else if ("delete".equals(action)) {
                int allocationId = Integer.parseInt(request.getParameter("allocationId").trim());
                allocationService.delete(allocationId);
                logger.info("Deleted allocationId={}", allocationId);
            }

        } catch (Exception e) {
            logger.error("Error in SiteProductAllocationController", e);
        } finally {
            response.sendRedirect(request.getContextPath() +
                "/view/user/allocateFertilizersToSite.jsp?cropToSiteId=" + cropToSiteId);
        }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doProcess(req, res);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doProcess(req, res);
    }
}
