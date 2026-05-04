package san.farm.adminuser.entity;

import java.sql.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name="salaryTransactions")
public class SalaryProcessingEntity {
	@Id
	@GeneratedValue
	private int salaryProcessId;
	private double amount;
	private Date date;
	private String paymentType;
	private String bankName;
	private String accountNumber;
	private String comment;
	
	@ManyToOne
	@JoinColumn(name="assignResourceId")
	private AssignEmployeeToFarmEntity employeeToFarm;
	

	/**
	 * @return the employeeToFarm
	 */
	public AssignEmployeeToFarmEntity getEmployeeToFarm() {
		return employeeToFarm;
	}

	/**
	 * @param employeeToFarm the employeeToFarm to set
	 */
	public void setEmployeeToFarm(AssignEmployeeToFarmEntity employeeToFarm) {
		this.employeeToFarm = employeeToFarm;
	}

	/**
	 * @return the salaryProcessId
	 */
	public int getSalaryProcessId() {
		return salaryProcessId;
	}

	/**
	 * @return the paymentType
	 */
	public String getPaymentType() {
		return paymentType;
	}

	/**
	 * @param paymentType
	 *            the paymentType to set
	 */
	public void setPaymentType(String paymentType) {
		this.paymentType = paymentType;
	}

	/**
	 * @param salaryProcessId
	 *            the salaryProcessId to set
	 */
	public void setSalaryProcessId(int salaryProcessId) {
		this.salaryProcessId = salaryProcessId;
	}

	/**
	 * @return the amount
	 */
	public double getAmount() {
		return amount;
	}

	/**
	 * @param amount
	 *            the amount to set
	 */
	public void setAmount(double amount) {
		this.amount = amount;
	}

	/**
	 * @return the date
	 */
	public Date getDate() {
		return date;
	}

	/**
	 * @param date
	 *            the date to set
	 */
	public void setDate(Date date) {
		this.date = date;
	}

	/**
	 * @return the bankName
	 */
	public String getBankName() {
		return bankName;
	}

	/**
	 * @param bankName
	 *            the bankName to set
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
	 * @param accountNumber
	 *            the accountNumber to set
	 */
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	/**
	 * @return the comment
	 */
	public String getComment() {
		return comment;
	}

	/**
	 * @param comment
	 *            the comment to set
	 */
	public void setComment(String comment) {
		this.comment = comment;
	}

}
