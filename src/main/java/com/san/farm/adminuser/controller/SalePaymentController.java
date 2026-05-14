package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.CropSaleDao;
import com.san.farm.adminuser.dao.SalePaymentDao;
import com.san.farm.adminuser.entity.CropSaleEntity;
import com.san.farm.adminuser.entity.SalePaymentEntity;
import com.san.farm.util.FarmUtility;

/**
 * Handles SalePayment CRUD operations.
 *
 * @author santosh khule
 * @version 1.0
 */
public class SalePaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(SalePaymentController.class);

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logger.debug("Processing SalePaymentController request");
        int saleId = 0;
        try {
            SalePaymentDao paymentDao = new SalePaymentDao();
            CropSaleDao cropSaleDao   = new CropSaleDao();

            String saleIdParam = request.getParameter("saleId");
            if (saleIdParam != null && !saleIdParam.trim().isEmpty()) {
                try { saleId = Integer.parseInt(saleIdParam.trim()); } catch (Exception e) { saleId = 0; }
            }

            int salePaymentId = 0;
            String spIdParam = request.getParameter("salePaymentId");
            if (spIdParam != null && !spIdParam.trim().isEmpty()) {
                try { salePaymentId = Integer.parseInt(spIdParam.trim()); } catch (Exception e) {}
            }

            double amountReceived = 0;
            String amtParam = request.getParameter("amountReceived");
            if (amtParam != null && !amtParam.trim().isEmpty()) {
                try { amountReceived = Double.parseDouble(amtParam.trim()); } catch (Exception e) {}
            }

            String paymentMode = request.getParameter("paymentMode") != null ? request.getParameter("paymentMode").trim() : "";
            String referenceNo = request.getParameter("referenceNo") != null ? request.getParameter("referenceNo").trim() : "";
            String comment     = request.getParameter("comment")     != null ? request.getParameter("comment").trim()     : "";

            Date paymentDate = null;
            String payDateParam = request.getParameter("paymentDate");
            if (payDateParam != null && !payDateParam.trim().isEmpty()) {
                try {
                    paymentDate = Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(payDateParam.trim()));
                } catch (Exception e) { logger.warn("Invalid paymentDate: {}", payDateParam); }
            }

            CropSaleEntity cropSaleEntity = cropSaleDao.getById(saleId);

            // Add Payment
            if (request.getParameter("sbtAddPayment") != null) {
                logger.info("Adding SalePayment for saleId: {}", saleId);
                SalePaymentEntity payment = new SalePaymentEntity();
                payment.setCropSaleEntity(cropSaleEntity);
                payment.setPaymentDate(paymentDate);
                payment.setAmountReceived(amountReceived);
                payment.setPaymentMode(paymentMode);
                payment.setReferenceNo(referenceNo);
                payment.setComment(comment);
                paymentDao.save(payment);
            }

            // Update Payment
            else if (request.getParameter("sbtUpdatePayment") != null) {
                logger.info("Updating SalePayment with id: {}", salePaymentId);
                SalePaymentEntity payment = new SalePaymentEntity();
                payment.setSalePaymentId(salePaymentId);
                payment.setCropSaleEntity(cropSaleEntity);
                payment.setPaymentDate(paymentDate);
                payment.setAmountReceived(amountReceived);
                payment.setPaymentMode(paymentMode);
                payment.setReferenceNo(referenceNo);
                payment.setComment(comment);
                paymentDao.update(payment);
            }

            // Delete Payment
            else if (request.getParameter("sbtDeletePayment") != null) {
                logger.info("Deleting SalePayment with id: {}", salePaymentId);
                paymentDao.delete(salePaymentId);
            }

        } catch (Exception exception) {
            logger.error("Error processing SalePaymentController request", exception);
        } finally {
            String redirectUrl = "view/user/cropSaleProcess.jsp?saleId=" + saleId;
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
