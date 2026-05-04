package san.farm.adminuser.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
@Entity
@Table(name="AssignCropToSiteRef")
public class AssignCropToSiteRefEntity {
	@Id
	@GeneratedValue
	private int AssignCropToSiteRefId;
	
	@ManyToOne
	@JoinColumn(name="AssignCropToSiteId")	
	private AssignCropToSiteEntity cropToSiteEntity;
	
	@ManyToOne
	@JoinColumn(name="cropId")	
	private ConfigCropEntity configCropEntity;

	/**
	 * @return the assignCropToSiteRefId
	 */
	public int getAssignCropToSiteRefId() {
		return AssignCropToSiteRefId;
	}

	/**
	 * @param assignCropToSiteRefId the assignCropToSiteRefId to set
	 */
	public void setAssignCropToSiteRefId(int assignCropToSiteRefId) {
		AssignCropToSiteRefId = assignCropToSiteRefId;
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
	 * @return the configCropEntity
	 */
	public ConfigCropEntity getConfigCropEntity() {
		return configCropEntity;
	}

	/**
	 * @param configCropEntity the configCropEntity to set
	 */
	public void setConfigCropEntity(ConfigCropEntity configCropEntity) {
		this.configCropEntity = configCropEntity;
	}
	
	
}
