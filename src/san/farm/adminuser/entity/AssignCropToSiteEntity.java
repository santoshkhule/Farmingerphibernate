package san.farm.adminuser.entity;

import java.sql.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name="assigncroptoSite")
public class AssignCropToSiteEntity {
	@Id
	@GeneratedValue
	int assignCroptoSiteId;
	Date cropAssignDate;
	
	@ManyToOne
	@JoinColumn(name="siteInfoId")
	private ConfigSiteInformationEntity siteInformationEntity;

	@OneToMany(mappedBy="cropToSiteEntity",targetEntity=AssignCropToSiteRefEntity.class,cascade=CascadeType.ALL,fetch=FetchType.EAGER)
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
	 * @return the assignCroptoSiteId
	 */
	public int getAssignCroptoSiteId() {
		return assignCroptoSiteId;
	}

	/**
	 * @param assignCroptoSiteId the assignCroptoSiteId to set
	 */
	public void setAssignCroptoSiteId(int assignCroptoSiteId) {
		this.assignCroptoSiteId = assignCroptoSiteId;
	}

	/**
	 * @return the cropAssignDate
	 */
	public Date getCropAssignDate() {
		return cropAssignDate;
	}

	/**
	 * @param cropAssignDate the cropAssignDate to set
	 */
	public void setCropAssignDate(Date cropAssignDate) {
		this.cropAssignDate = cropAssignDate;
	}

	/**
	 * @return the siteInformationEntity
	 */
	public ConfigSiteInformationEntity getSiteInformationEntity() {
		return siteInformationEntity;
	}

	/**
	 * @param siteInformationEntity the siteInformationEntity to set
	 */
	public void setSiteInformationEntity(
			ConfigSiteInformationEntity siteInformationEntity) {
		this.siteInformationEntity = siteInformationEntity;
	}
	
	
	
}
