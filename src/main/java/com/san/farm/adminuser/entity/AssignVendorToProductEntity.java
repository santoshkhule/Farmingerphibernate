package com.san.farm.adminuser.entity;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "AssignVendorToProduct")
public class AssignVendorToProductEntity {

	@Id
	@GeneratedValue
	private int assignVendorProductId;

	@ManyToOne(fetch = FetchType.EAGER)
	private VendorEntity vendorEntity;

	@ManyToOne(fetch = FetchType.EAGER)
	private CategoryEntity categoryEntity;

	@ManyToOne(fetch = FetchType.EAGER)
	private FertilizerEntity fertilizerEntity;

	@ManyToOne(fetch = FetchType.EAGER)
	private BrandEntity brandEntity;

	@ManyToOne(fetch = FetchType.EAGER)
	private UnitEntity unitEntity;

	private double price;
	private String prodDesc;
	private String comment;

	public int getAssignVendorProductId() { return assignVendorProductId; }
	public void setAssignVendorProductId(int assignVendorProductId) { this.assignVendorProductId = assignVendorProductId; }

	public VendorEntity getVendorEntity() { return vendorEntity; }
	public void setVendorEntity(VendorEntity vendorEntity) { this.vendorEntity = vendorEntity; }

	public CategoryEntity getCategoryEntity() { return categoryEntity; }
	public void setCategoryEntity(CategoryEntity categoryEntity) { this.categoryEntity = categoryEntity; }

	public FertilizerEntity getFertilizerEntity() { return fertilizerEntity; }
	public void setFertilizerEntity(FertilizerEntity fertilizerEntity) { this.fertilizerEntity = fertilizerEntity; }

	public BrandEntity getBrandEntity() { return brandEntity; }
	public void setBrandEntity(BrandEntity brandEntity) { this.brandEntity = brandEntity; }

	public UnitEntity getUnitEntity() { return unitEntity; }
	public void setUnitEntity(UnitEntity unitEntity) { this.unitEntity = unitEntity; }

	public double getPrice() { return price; }
	public void setPrice(double price) { this.price = price; }

	public String getProdDesc() { return prodDesc; }
	public void setProdDesc(String prodDesc) { this.prodDesc = prodDesc; }

	public String getComment() { return comment; }
	public void setComment(String comment) { this.comment = comment; }
}
