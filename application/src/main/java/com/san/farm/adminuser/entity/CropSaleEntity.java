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
@Table(name = "CropSale")
public class CropSaleEntity {

    @Id
    @GeneratedValue
    private int saleId;

    private Date saleDate;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "assignCroptoSiteId")
    private AssignCropToSiteEntity assignCropToSiteEntity;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "cropId")
    private ConfigCropEntity cropEntity;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "buyerId")
    private BuyerEntity buyerEntity;

    private double quantity;
    private String unit;
    private double pricePerUnit;
    private double totalAmount;
    private String comment;

    public int getSaleId() { return saleId; }
    public void setSaleId(int saleId) { this.saleId = saleId; }

    public Date getSaleDate() { return saleDate; }
    public void setSaleDate(Date saleDate) { this.saleDate = saleDate; }

    public AssignCropToSiteEntity getAssignCropToSiteEntity() { return assignCropToSiteEntity; }
    public void setAssignCropToSiteEntity(AssignCropToSiteEntity assignCropToSiteEntity) {
        this.assignCropToSiteEntity = assignCropToSiteEntity;
    }

    public ConfigCropEntity getCropEntity() { return cropEntity; }
    public void setCropEntity(ConfigCropEntity cropEntity) { this.cropEntity = cropEntity; }

    public BuyerEntity getBuyerEntity() { return buyerEntity; }
    public void setBuyerEntity(BuyerEntity buyerEntity) { this.buyerEntity = buyerEntity; }

    public double getQuantity() { return quantity; }
    public void setQuantity(double quantity) { this.quantity = quantity; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public double getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(double pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
