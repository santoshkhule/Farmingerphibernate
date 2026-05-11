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
@Table(name = "siteProductAllocation")
public class SiteProductAllocationEntity {

    @Id
    @GeneratedValue
    private int allocationId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "cropToSiteId")
    private AssignCropToSiteEntity cropToSite;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "assignVendorProductId")
    private AssignVendorToProductEntity vendorProduct;

    private double quantity;
    private Date allocationDate;
    private String comment;

    public int getAllocationId() { return allocationId; }
    public void setAllocationId(int allocationId) { this.allocationId = allocationId; }

    public AssignCropToSiteEntity getCropToSite() { return cropToSite; }
    public void setCropToSite(AssignCropToSiteEntity cropToSite) { this.cropToSite = cropToSite; }

    public AssignVendorToProductEntity getVendorProduct() { return vendorProduct; }
    public void setVendorProduct(AssignVendorToProductEntity vendorProduct) { this.vendorProduct = vendorProduct; }

    public double getQuantity() { return quantity; }
    public void setQuantity(double quantity) { this.quantity = quantity; }

    public Date getAllocationDate() { return allocationDate; }
    public void setAllocationDate(Date allocationDate) { this.allocationDate = allocationDate; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
