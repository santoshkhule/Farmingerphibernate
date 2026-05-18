package com.san.farm.adminuser.dao;

import com.san.farm.adminuser.entity.RolePermissionEntity;
import com.san.farm.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.*;

public class RolePermissionDao {

    /** Returns all permissions grouped by roleId → set of pageKeys. */
    @SuppressWarnings("unchecked")
    public Map<Integer, Set<String>> fetchAllByRole() {
        Map<Integer, Set<String>> result = new HashMap<>();
        Session session = HibernateUtil.opensession();
        try {
            List<RolePermissionEntity> list = session
                    .createQuery("FROM RolePermissionEntity").list();
            for (RolePermissionEntity rpe : list) {
                result.computeIfAbsent(rpe.getUserTypeId(), k -> new HashSet<>())
                      .add(rpe.getPageKey());
            }
        } finally {
            session.close();
        }
        return result;
    }

    /** Replaces all permissions for one role with the supplied page-key set. */
    public void saveRolePermissions(int userTypeId, Set<String> pageKeys) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        try {
            session.createQuery("DELETE FROM RolePermissionEntity WHERE userTypeId = :rid")
                   .setParameter("rid", userTypeId).executeUpdate();
            for (String key : pageKeys) {
                RolePermissionEntity rpe = new RolePermissionEntity();
                rpe.setUserTypeId(userTypeId);
                rpe.setPageKey(key);
                session.save(rpe);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            session.close();
        }
    }

    /** Returns the union of permitted pages for the given role IDs. */
    @SuppressWarnings("unchecked")
    public Set<String> getPermittedPagesForRoles(Collection<Integer> roleIds) {
        if (roleIds == null || roleIds.isEmpty()) return new HashSet<>();
        Session session = HibernateUtil.opensession();
        try {
            List<RolePermissionEntity> list = session
                    .createQuery("FROM RolePermissionEntity WHERE userTypeId IN (:ids)")
                    .setParameterList("ids", roleIds).list();
            Set<String> result = new HashSet<>();
            for (RolePermissionEntity rpe : list) result.add(rpe.getPageKey());
            return result;
        } finally {
            session.close();
        }
    }
}
