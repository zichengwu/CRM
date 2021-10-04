package com.cheng.ssm.web.filter;

import com.cheng.ssm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String path = request.getServletPath();
        //不应该被拦截的资源自动放行
        if ("/login.jsp".equals(path) || "/settings/user/login.do".equals(path)) {
            filterChain.doFilter(request, response);
        } else {
            User user = (User) request.getSession().getAttribute("user");

            if (user != null) {
                filterChain.doFilter(request, response);
            } else {
                /*
                 * 转发使用的是一种特殊的绝对路径的使用方式。这种绝对路径前面不加/项目名，这种路径也被称为内部路径
                 * 重定向使用的传统绝对路径的写法，前面必须以/项目名开始，后面跟具体资源路径
                 */
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }
    }
}
