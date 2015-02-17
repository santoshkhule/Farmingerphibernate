package san.farm.adminuser.entity;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import san.farm.login.entity.LoginUser;

@Entity
@Table(name = "usertype")
public class UserTypeEntity {
	@Id
	@GeneratedValue
	private int userTypeId;
	private String userType;

	@OneToMany(targetEntity=LoginUser.class,mappedBy="userTypeEntity",cascade=CascadeType.ALL)
	private List<LoginUser> loginUser;
	
	public int getUserTypeId() {
		return userTypeId;
	}

	public void setUserTypeId(int userTypeId) {
		this.userTypeId = userTypeId;
	}

	public String getUserType() {
		return userType;
	}
	public void setUserType(String userType) {
		this.userType = userType;
	}

	public List<LoginUser> getLoginUser() {
		return loginUser;
	}

	public void setLoginUser(List<LoginUser> loginUser) {
		this.loginUser = loginUser;
	}

}
