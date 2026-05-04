package san.farm.login.entity;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import san.farm.adminuser.entity.UserTypeEntity;

@Entity
@Table(name="loginuser")
public class LoginUser {
	@Id
	@GeneratedValue
	private long loginUserId;
	private String uname;
	private String password;
	
	@ManyToOne(cascade=CascadeType.ALL)
	@JoinColumn(name="userTypeId")
	private UserTypeEntity userTypeEntity;	
	
	public long getLoginUserId() {
		return loginUserId;
	}
	public void setLoginUserId(long loginUserId) {
		this.loginUserId = loginUserId;
	}
	public String getUname() {
		return uname;
	}
	public void setUname(String uname) {
		this.uname = uname;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public UserTypeEntity getUserTypeEntity() {
		return userTypeEntity;
	}
	public void setUserTypeEntity(UserTypeEntity userTypeEntity) {
		this.userTypeEntity = userTypeEntity;
	}
	
	
}
