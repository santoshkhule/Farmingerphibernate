package san.farm.adminuser.entity;

import java.sql.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "authemployeeinfo")
public class EmployeeInfoEntity {
	@Id
	@GeneratedValue
	private int employeeInfoId;
	private String firstName;
	private String middleName;
	private String lastName;
	private String contactNo1;
	private String contactNo2;
	private String emailId;
	private Date birthDate;
	private String perAddress;
	private String localAddress;
	private String comment;
	private String bankName;
	private String accountNumber;
	private String panCardNo;
	private String empPicPath;
	/*@OneToOne(cascade=CascadeType.ALL,fetch=FetchType.EAGER,mappedBy="authEmployeeInfo",targetEntity=LoginUser.class)
	@JoinColumn(name="loginUserId")
	private LoginUser loginUser;*/
	
	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}
	/**
	 * @return the employeeInfoId
	 */
	public int getEmployeeInfoId() {
		return employeeInfoId;
	}
	/**
	 * @param employeeInfoId the employeeInfoId to set
	 */
	public void setEmployeeInfoId(int employeeInfoId) {
		this.employeeInfoId = employeeInfoId;
	}
	/**
	 * @param firstName the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	/**
	 * @return the middleName
	 */
	public String getMiddleName() {
		return middleName;
	}
	/**
	 * @param middleName the middleName to set
	 */
	public void setMiddleName(String middleName) {
		this.middleName = middleName;
	}
	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}
	/**
	 * @param lastName the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	/**
	 * @return the contactNo1
	 */
	public String getContactNo1() {
		return contactNo1;
	}
	/**
	 * @param contactNo1 the contactNo1 to set
	 */
	public void setContactNo1(String contactNo1) {
		this.contactNo1 = contactNo1;
	}
	/**
	 * @return the contactNo2
	 */
	public String getContactNo2() {
		return contactNo2;
	}
	/**
	 * @param contactNo2 the contactNo2 to set
	 */
	public void setContactNo2(String contactNo2) {
		this.contactNo2 = contactNo2;
	}
	/**
	 * @return the emailId
	 */
	public String getEmailId() {
		return emailId;
	}
	/**
	 * @param emailId the emailId to set
	 */
	public void setEmailId(String emailId) {
		this.emailId = emailId;
	}
	/**
	 * @return the birthDate
	 */
	public Date getBirthDate() {
		return birthDate;
	}
	/**
	 * @param birthDate the birthDate to set
	 */
	public void setBirthDate(Date birthDate) {
		this.birthDate = birthDate;
	}
	/**
	 * @return the perAddress
	 */
	public String getPerAddress() {
		return perAddress;
	}
	/**
	 * @param perAddress the perAddress to set
	 */
	public void setPerAddress(String perAddress) {
		this.perAddress = perAddress;
	}
	/**
	 * @return the localAddress
	 */
	public String getLocalAddress() {
		return localAddress;
	}
	/**
	 * @param localAddress the localAddress to set
	 */
	public void setLocalAddress(String localAddress) {
		this.localAddress = localAddress;
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
	 * @return the bankName
	 */
	public String getBankName() {
		return bankName;
	}
	/**
	 * @param bankName the bankName to set
	 */
	public void setBankName(String bankName) {
		this.bankName = bankName;
	}
	/**
	 * @return the accountNumber
	 */
	public String getAccountNumber() {
		return accountNumber;
	}
	/**
	 * @param accountNumber the accountNumber to set
	 */
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}
	/**
	 * @return the panCardNo
	 */
	public String getPanCardNo() {
		return panCardNo;
	}
	/**
	 * @param panCardNo the panCardNo to set
	 */
	public void setPanCardNo(String panCardNo) {
		this.panCardNo = panCardNo;
	}
	/**
	 * @return the empPicPath
	 */
	public String getEmpPicPath() {
		return empPicPath;
	}
	/**
	 * @param empPicPath the empPicPath to set
	 */
	public void setEmpPicPath(String empPicPath) {
		this.empPicPath = empPicPath;
	}

}
