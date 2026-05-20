<%@ page import="com.san.farm.login.entity.LoginUser" %>
<%@ page import="com.san.farm.adminuser.dao.RolePermissionDao" %>
<%@ page import="com.san.farm.adminuser.entity.UserTypeEntity" %>
<%@ page import="java.util.Map,java.util.Set,java.util.HashSet" %>
<%
    LoginUser _pusr = (LoginUser) session.getAttribute("loggedInUser");
    String _pUname = (_pusr != null && _pusr.getUname() != null) ? _pusr.getUname() : "";
    boolean _isAdmin = "admin".equalsIgnoreCase(_pUname);
    boolean _hasRolePerms = false;
    Set<String> _perms = new HashSet<String>();
    if (!_isAdmin && _pusr != null && _pusr.getUserTypes() != null) {
        Set<Integer> __upRIds = new HashSet<Integer>();
        for (UserTypeEntity __upR : _pusr.getUserTypes()) {
            if (__upR != null) __upRIds.add(__upR.getUserTypeId());
        }
        if (!__upRIds.isEmpty()) {
            try {
                Map<Integer, Set<String>> __upAllPerms = new RolePermissionDao().fetchAllByRole();
                for (Integer __upRid : __upRIds) {
                    Set<String> __upRp = __upAllPerms.get(__upRid);
                    if (__upRp != null && !__upRp.isEmpty()) {
                        _hasRolePerms = true;
                        _perms.addAll(__upRp);
                    }
                }
            } catch (Exception __upE) { /* DB not ready — allow all */ }
        }
    }
%>
