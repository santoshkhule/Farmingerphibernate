package com.san.farm.adminuser.entity;

import javax.persistence.*;

@Entity
@Table(name = "role_permissions",
       uniqueConstraints = @UniqueConstraint(columnNames = {"userTypeId", "pageKey"}))
public class RolePermissionEntity {

    @Id
    @GeneratedValue
    private int permissionId;

    @Column(nullable = false)
    private int userTypeId;

    @Column(nullable = false, length = 50)
    private String pageKey;

    public int getPermissionId() { return permissionId; }
    public void setPermissionId(int permissionId) { this.permissionId = permissionId; }

    public int getUserTypeId() { return userTypeId; }
    public void setUserTypeId(int userTypeId) { this.userTypeId = userTypeId; }

    public String getPageKey() { return pageKey; }
    public void setPageKey(String pageKey) { this.pageKey = pageKey; }
}
