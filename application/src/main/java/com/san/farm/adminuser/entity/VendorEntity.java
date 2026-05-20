package com.san.farm.adminuser.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "Vendor")
public class VendorEntity {

	@Id
	@GeneratedValue
	private int vendorId;

	private String vendorName;
	private String shopName;
	private String perContactNo;
	private String ofcContactNo;
	private String address;
	private String emailId;

	public int getVendorId() {
		return vendorId;
	}

	public void setVendorId(int vendorId) {
		this.vendorId = vendorId;
	}

	public String getVendorName() {
		return vendorName;
	}

	public void setVendorName(String vendorName) {
		this.vendorName = vendorName;
	}

	public String getShopName() {
		return shopName;
	}

	public void setShopName(String shopName) {
		this.shopName = shopName;
	}

	public String getPerContactNo() {
		return perContactNo;
	}

	public void setPerContactNo(String perContactNo) {
		this.perContactNo = perContactNo;
	}

	public String getOfcContactNo() {
		return ofcContactNo;
	}

	public void setOfcContactNo(String ofcContactNo) {
		this.ofcContactNo = ofcContactNo;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getEmailId() {
		return emailId;
	}

	public void setEmailId(String emailId) {
		this.emailId = emailId;
	}
}
