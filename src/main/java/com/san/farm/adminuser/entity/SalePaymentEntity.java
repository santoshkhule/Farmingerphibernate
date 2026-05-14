package com.san.farm.adminuser.entity;

import java.sql.Date;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "SalePayment")
public class SalePaymentEntity {

    @Id
    @GeneratedValue
    private int salePaymentId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "saleId")
    private CropSaleEntity cropSaleEntity;

    private Date paymentDate;
    private double amountReceived;
    private String paymentMode;
    private String referenceNo;
    private String comment;

    public int getSalePaymentId() { return salePaymentId; }
    public void setSalePaymentId(int salePaymentId) { this.salePaymentId = salePaymentId; }

    public CropSaleEntity getCropSaleEntity() { return cropSaleEntity; }
    public void setCropSaleEntity(CropSaleEntity cropSaleEntity) { this.cropSaleEntity = cropSaleEntity; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }

    public double getAmountReceived() { return amountReceived; }
    public void setAmountReceived(double amountReceived) { this.amountReceived = amountReceived; }

    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }

    public String getReferenceNo() { return referenceNo; }
    public void setReferenceNo(String referenceNo) { this.referenceNo = referenceNo; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
