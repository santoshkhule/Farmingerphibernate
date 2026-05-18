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
import com.san.farm.adminuser.dao.BuyerService;
import com.san.farm.adminuser.dao.ConfigCropService;
import com.san.farm.adminuser.dao.CropSaleDao;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.BuyerEntity;
import com.san.farm.adminuser.entity.ConfigCropEntity;
import com.san.farm.adminuser.entity.CropSaleEntity;
import com.san.farm.util.FarmUtility;

/**
 * Handles CropSale CRUD operations.
 *
 * @author santosh khule
 * @version 1.0
 */
public class CropSaleController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(CropSaleController.class);

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logger.debug("Processing CropSaleController request");
        String redirectUrl = "view/user/saleProcess.jsp";
        int saleId = 0;
        try {
            CropSaleDao cropSaleDao               = new CropSaleDao();
            AssignCropToSiteService siteService   = new AssignCropToSiteService();
            ConfigCropService cropService         = new ConfigCropService();
            BuyerService buyerService             = new BuyerService();

            String saleIdParam = request.getParameter("saleId");
            if (saleIdParam != null && !saleIdParam.trim().isEmpty()) {
                try { saleId = Integer.parseInt(saleIdParam.trim()); } catch (Exception e) { saleId = 0; }
            }

            int assignCroptoSiteId = 0;
            String actsParam = request.getParameter("assignCroptoSiteId");
            if (actsParam != null && !actsParam.trim().isEmpty()) {
                try { assignCroptoSiteId = Integer.parseInt(actsParam.trim()); } catch (Exception e) {}
            }

            int cropId = 0;
            String cropIdParam = request.getParameter("cropId");
            if (cropIdParam != null && !cropIdParam.trim().isEmpty()) {
                try { cropId = Integer.parseInt(cropIdParam.trim()); } catch (Exception e) {}
            }

            int buyerId = 0;
            String buyerIdParam = request.getParameter("buyerId");
            if (buyerIdParam != null && !buyerIdParam.trim().isEmpty()) {
                try { buyerId = Integer.parseInt(buyerIdParam.trim()); } catch (Exception e) {}
            }

            double quantity     = 0;
            double pricePerUnit = 0;
            String unit         = request.getParameter("unit")    != null ? request.getParameter("unit").trim()    : "";
            String comment      = request.getParameter("comment") != null ? request.getParameter("comment").trim() : "";

            String qtyParam = request.getParameter("quantity");
            if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                try { quantity = Double.parseDouble(qtyParam.trim()); } catch (Exception e) {}
            }
            String priceParam = request.getParameter("pricePerUnit");
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                try { pricePerUnit = Double.parseDouble(priceParam.trim()); } catch (Exception e) {}
            }

            // Always compute totalAmount server-side
            double totalAmount = quantity * pricePerUnit;

            Date saleDate = null;
            String saleDateParam = request.getParameter("saleDate");
            if (saleDateParam != null && !saleDateParam.trim().isEmpty()) {
                try {
                    saleDate = Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(saleDateParam.trim()));
                } catch (Exception e) { logger.warn("Invalid saleDate: {}", saleDateParam); }
            }

            // Add
            if (request.getParameter("add") != null) {
                logger.info("Adding new CropSale for site: {}, crop: {}, buyer: {}", assignCroptoSiteId, cropId, buyerId);
                AssignCropToSiteEntity siteEntity = siteService.getAssignCropToSiteInfoByCropToSiteId(assignCroptoSiteId);
                ConfigCropEntity cropEntity       = cropService.getCropIdByCropId(cropId);
                BuyerEntity buyerEntity           = buyerService.getById(buyerId);

                CropSaleEntity cropSale = new CropSaleEntity();
                cropSale.setSaleDate(saleDate);
                cropSale.setAssignCropToSiteEntity(siteEntity);
                cropSale.setCropEntity(cropEntity);
                cropSale.setBuyerEntity(buyerEntity);
                cropSale.setQuantity(quantity);
                cropSale.setUnit(unit);
                cropSale.setPricePerUnit(pricePerUnit);
                cropSale.setTotalAmount(totalAmount);
                cropSale.setComment(comment);

                boolean saved = cropSaleDao.save(cropSale);
                if (saved) {
                    // Retrieve the id of the just-saved entity
                    // We do a fresh getAll and find the latest (H2 auto-increments)
                    // Better: re-query by latest — for simplicity redirect to list
                    redirectUrl = "view/user/saleProcess.jsp";
                } else {
                    redirectUrl = "view/user/saleProcess.jsp";
                }
            }

            // Edit
            else if (request.getParameter("edit") != null) {
                logger.info("Updating CropSale with id: {}", saleId);
                AssignCropToSiteEntity siteEntity = siteService.getAssignCropToSiteInfoByCropToSiteId(assignCroptoSiteId);
                ConfigCropEntity cropEntity       = cropService.getCropIdByCropId(cropId);
                BuyerEntity buyerEntity           = buyerService.getById(buyerId);

                CropSaleEntity cropSale = new CropSaleEntity();
                cropSale.setSaleId(saleId);
                cropSale.setSaleDate(saleDate);
                cropSale.setAssignCropToSiteEntity(siteEntity);
                cropSale.setCropEntity(cropEntity);
                cropSale.setBuyerEntity(buyerEntity);
                cropSale.setQuantity(quantity);
                cropSale.setUnit(unit);
                cropSale.setPricePerUnit(pricePerUnit);
                cropSale.setTotalAmount(totalAmount);
                cropSale.setComment(comment);

                cropSaleDao.update(cropSale);
                redirectUrl = "view/user/saleProcess.jsp?saleId=" + saleId;
            }

            // Delete
            else if (request.getParameter("delete") != null) {
                logger.info("Deleting CropSale with id: {}", saleId);
                cropSaleDao.delete(saleId);
                redirectUrl = "view/user/saleProcess.jsp";
            }

        } catch (Exception exception) {
            logger.error("Error processing CropSaleController request", exception);
            redirectUrl = "view/user/saleProcess.jsp" + (saleId > 0 ? "?saleId=" + saleId : "");
        } finally {
            logger.debug("Redirecting to: {}", redirectUrl);
            response.sendRedirect(redirectUrl);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }
}
