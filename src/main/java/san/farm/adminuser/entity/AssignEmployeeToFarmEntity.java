package san.farm.adminuser.entity;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name="AssignEmployeeToFarm")
public class AssignEmployeeToFarmEntity {
	@Id
	@GeneratedValue
	private int assignResourceId;
	private Date assignWorkDate;
	private String typeOfWork;
	private double amount;
	private double advPayment;
	private String workStatus;
	private String comment;
		
	@ManyToOne
	@JoinColumn(name="employeeInfoId")
	private EmployeeInfoEntity employeeInfoEntity;
	
	@ManyToOne
	@JoinColumn(name="assignCroptoSiteId")
	private AssignCropToSiteEntity cropToSiteEntity;
	
	@ManyToOne
	@JoinColumn(name="cropId")
	private ConfigCropEntity cropEntity;	
	
	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(name="AssignTaskTOEmployee",joinColumns={@JoinColumn(name="assignResourceId")},inverseJoinColumns={@JoinColumn(name="taskId")})
	private List<ConfigFarmTaskEntity> listFarmTaskEntities=new ArrayList<ConfigFarmTaskEntity>();
		
	/**
	 * @return the cropEntity
	 */
	public ConfigCropEntity getCropEntity() {
		return cropEntity;
	}
	/**
	 * @param cropEntity the cropEntity to set
	 */
	public void setCropEntity(ConfigCropEntity cropEntity) {
		this.cropEntity = cropEntity;
	}
	
	/**
	 * @return the typeOfWork
	 */
	public String getTypeOfWork() {
		return typeOfWork;
	}
	/**
	 * @param typeOfWork the typeOfWork to set
	 */
	public void setTypeOfWork(String typeOfWork) {
		this.typeOfWork = typeOfWork;
	}
	
	/**
	 * @return the assignResourceId
	 */
	public int getAssignResourceId() {
		return assignResourceId;
	}
	/**
	 * @param assignResourceId the assignResourceId to set
	 */
	public void setAssignResourceId(int assignResourceId) {
		this.assignResourceId = assignResourceId;
	}
	/**
	 * @return the assignWorkDate
	 */
	public Date getAssignWorkDate() {
		return assignWorkDate;
	}
	/**
	 * @param assignWorkDate the assignWorkDate to set
	 */
	public void setAssignWorkDate(Date assignWorkDate) {
		this.assignWorkDate = assignWorkDate;
	}
	/**
	 * @return the employeeInfoEntity
	 */
	public EmployeeInfoEntity getEmployeeInfoEntity() {
		return employeeInfoEntity;
	}
	/**
	 * @param employeeInfoEntity the employeeInfoEntity to set
	 */
	public void setEmployeeInfoEntity(EmployeeInfoEntity employeeInfoEntity) {
		this.employeeInfoEntity = employeeInfoEntity;
	}
	
	/**
	 * @return the amount
	 */
	public double getAmount() {
		return amount;
	}
	/**
	 * @param amount the amount to set
	 */
	public void setAmount(double amount) {
		this.amount = amount;
	}
	/**
	 * @return the advPayment
	 */
	public double getAdvPayment() {
		return advPayment;
	}
	/**
	 * @param advPayment the advPayment to set
	 */
	public void setAdvPayment(double advPayment) {
		this.advPayment = advPayment;
	}
	/**
	 * @return the workStatus
	 */
	public String getWorkStatus() {
		return workStatus;
	}
	/**
	 * @param workStatus the workStatus to set
	 */
	public void setWorkStatus(String workStatus) {
		this.workStatus = workStatus;
	}
	/**
	 * @return the comment
	 */
	public String getComment() {
		return comment;
	}
	/**
	 * @param comment the comment to set
	 */
	public void setComment(String comment) {
		this.comment = comment;
	}
	/**
	 * @return the cropToSiteEntity
	 */
	public AssignCropToSiteEntity getCropToSiteEntity() {
		return cropToSiteEntity;
	}
	/**
	 * @param cropToSiteEntity the cropToSiteEntity to set
	 */
	public void setCropToSiteEntity(AssignCropToSiteEntity cropToSiteEntity) {
		this.cropToSiteEntity = cropToSiteEntity;
	}	
	
	/**
	 * @return the listFarmTaskEntities
	 */
	public List<ConfigFarmTaskEntity> getListFarmTaskEntities() {
		return listFarmTaskEntities;
	}
	/**
	 * @param listFarmTaskEntities the listFarmTaskEntities to set
	 */
	public void setListFarmTaskEntities(
			List<ConfigFarmTaskEntity> listFarmTaskEntities) {
		this.listFarmTaskEntities = listFarmTaskEntities;
	}
	@Override
	public String toString() {
		return "AssignEmployeeToFarmEntity [assignResourceId="
				+ assignResourceId + ", assignWorkDate=" + assignWorkDate
				+ ", employeeInfoEntity=" + employeeInfoEntity
				+ ", cropToSiteEntity=" + cropToSiteEntity + ", cropEntity="
				+ cropEntity + ", advPayment=" + advPayment
				+ ", workStatus=" + workStatus + ", comment=" + comment + "]";
	}
	
	
}
