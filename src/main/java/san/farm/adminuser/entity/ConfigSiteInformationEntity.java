package san.farm.adminuser.entity;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;
/**
 * ConfigSiteInformationEntity POJO provides MetaData for DB
 * @author santosh khule
 * @since 15/11/2014
 * 
 * */
@Entity
@Table(name="SiteInformation")
public class ConfigSiteInformationEntity {
	@Id
	@GeneratedValue
	private int siteInfoId;
	private String siteName;
	private double siteArea;
	private String siteLocation;
	
	@OneToMany(targetEntity=AssignCropToSiteEntity.class,mappedBy="siteInformationEntity",fetch=FetchType.LAZY,cascade=CascadeType.ALL)
	private List<AssignCropToSiteEntity> cropToSiteEntity;
	
	/**
	 * @return the siteInfoId
	 */
	public int getSiteInfoId() {
		return siteInfoId;
	}
	/**
	 * @param siteInfoId the siteInfoId to set
	 */
	public void setSiteInfoId(int siteInfoId) {
		this.siteInfoId = siteInfoId;
	}
	/**
	 * @return the siteName
	 */
	public String getSiteName() {
		return siteName;
	}
	/**
	 * @param siteName the siteName to set
	 */
	public void setSiteName(String siteName) {
		this.siteName = siteName;
	}
	/**
	 * @return the siteArea
	 */
	public double getSiteArea() {
		return siteArea;
	}
	/**
	 * @param siteArea the siteArea to set
	 */
	public void setSiteArea(double siteArea) {
		this.siteArea = siteArea;
	}
	/**
	 * @return the siteLocation
	 */
	public String getSiteLocation() {
		return siteLocation;
	}
	/**
	 * @param siteLocation the siteLocation to set
	 */
	public void setSiteLocation(String siteLocation) {
		this.siteLocation = siteLocation;
	}
	/**
	 * @return the cropToSiteEntity
	 */
	public List<AssignCropToSiteEntity> getCropToSiteEntity() {
		return cropToSiteEntity;
	}
	/**
	 * @param cropToSiteEntity the cropToSiteEntity to set
	 */
	public void setCropToSiteEntity(List<AssignCropToSiteEntity> cropToSiteEntity) {
		this.cropToSiteEntity = cropToSiteEntity;
	}
	
	
	
}
