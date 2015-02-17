package san.farm.adminuser.entity;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name="crops")
public class ConfigCropEntity {
	@Id
	@GeneratedValue
	private int cropId;
	private String cropName;
	
	@OneToMany(cascade=CascadeType.ALL)
	private List<AssignEmployeeToFarmEntity> employeeToFarmEntities;	
	
	@OneToMany(mappedBy="configCropEntity",targetEntity=AssignCropToSiteRefEntity.class,cascade=CascadeType.ALL)
	private List<AssignCropToSiteRefEntity> cropToSiteRefEntity;
	
	/**
	 * @return the cropToSiteRefEntity
	 */
	public List<AssignCropToSiteRefEntity> getCropToSiteRefEntity() {
		return cropToSiteRefEntity;
	}
	/**
	 * @param cropToSiteRefEntity the cropToSiteRefEntity to set
	 */
	public void setCropToSiteRefEntity(
			List<AssignCropToSiteRefEntity> cropToSiteRefEntity) {
		this.cropToSiteRefEntity = cropToSiteRefEntity;
	}
	
	/**
	 * @return the employeeToFarmEntities
	 */
	public List<AssignEmployeeToFarmEntity> getEmployeeToFarmEntities() {
		return employeeToFarmEntities;
	}
	/**
	 * @param employeeToFarmEntities the employeeToFarmEntities to set
	 */
	public void setEmployeeToFarmEntities(
			List<AssignEmployeeToFarmEntity> employeeToFarmEntities) {
		this.employeeToFarmEntities = employeeToFarmEntities;
	}
	/**
	 * @return the cropId
	 */
	public int getCropId() {
		return cropId;
	}
	/**
	 * @param cropId the cropId to set
	 */
	public void setCropId(int cropId) {
		this.cropId = cropId;
	}
	/**
	 * @return the cropName
	 */
	public String getCropName() {
		return cropName;
	}
	/**
	 * @param cropName the cropName to set
	 */
	public void setCropName(String cropName) {
		this.cropName = cropName;
	}
	
	
	
}
