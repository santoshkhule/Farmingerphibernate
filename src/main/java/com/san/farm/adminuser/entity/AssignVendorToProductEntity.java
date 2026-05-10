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
	private FertilizerEntity fertilizerEntity;

	private double price;

	public int getAssignVendorProductId() {
		return assignVendorProductId;
	}

	public void setAssignVendorProductId(int assignVendorProductId) {
		this.assignVendorProductId = assignVendorProductId;
	}

	public VendorEntity getVendorEntity() {
		return vendorEntity;
	}

	public void setVendorEntity(VendorEntity vendorEntity) {
		this.vendorEntity = vendorEntity;
	}

	public FertilizerEntity getFertilizerEntity() {
		return fertilizerEntity;
	}

	public void setFertilizerEntity(FertilizerEntity fertilizerEntity) {
		this.fertilizerEntity = fertilizerEntity;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}
}
