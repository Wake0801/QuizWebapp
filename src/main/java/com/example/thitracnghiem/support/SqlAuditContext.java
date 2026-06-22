package com.example.thitracnghiem.support;

import org.springframework.stereotype.Component;

@Component
public class SqlAuditContext {

    public String withAppLogin(String sql) {
        return "EXEC sys.sp_set_session_context @key=N'APP_LOGINNAME', @value=?; " + sql;
    }

    public Object[] params(String appLogin, Object... params) {
        Object[] values = new Object[params.length + 1];
        values[0] = normalize(appLogin);
        System.arraycopy(params, 0, values, 1, params.length);
        return values;
    }

    private String normalize(String appLogin) {
        if (appLogin == null || appLogin.trim().isEmpty()) {
            return "UNKNOWN";
        }
        return appLogin.trim();
    }
}
