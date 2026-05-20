package com.san.farm.login.entity;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

import com.san.farm.adminuser.entity.UserTypeEntity;

@Entity
@Table(name = "loginuser")
public class LoginUser {

    @Id
    @GeneratedValue
    private long loginUserId;

    private String uname;
    private String password;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "loginuser_usertype",
        joinColumns = @JoinColumn(name = "loginUserId"),
        inverseJoinColumns = @JoinColumn(name = "userTypeId")
    )
    private List<UserTypeEntity> userTypes = new ArrayList<UserTypeEntity>();

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

    public List<UserTypeEntity> getUserTypes() {
        return userTypes;
    }

    public void setUserTypes(List<UserTypeEntity> userTypes) {
        this.userTypes = userTypes;
    }
}
