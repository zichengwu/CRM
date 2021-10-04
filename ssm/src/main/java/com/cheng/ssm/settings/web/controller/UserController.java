package com.cheng.ssm.settings.web.controller;

import com.cheng.ssm.exception.LoginFailException;
import com.cheng.ssm.utils.Msg;
import com.cheng.ssm.settings.domain.User;
import com.cheng.ssm.settings.service.UserService;
import com.cheng.ssm.utils.MD5Util;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

// controller层只负责调用业务层处理逻辑  和返回结果
@RequestMapping("/settings/user")
@Controller
public class UserController {

    // 引用类型自动注入 由于springMVC容器是spring的子容器 所以可以从spring容器中拿出userService
    @Resource
    private UserService userService;

    //验证用户登录
    @PostMapping("/login.do")
    @ResponseBody
    public Msg login(String loginAct, String loginPwd, HttpServletRequest request){
        // 拿到访问主机的ip地址
        String ip = request.getRemoteAddr();
//        System.out.println("ip------------------" + ip);
        loginPwd = MD5Util.getMD5(loginPwd);
        try {
            User user = userService.login(loginAct, loginPwd, ip);
            request.getSession().setAttribute("user", user);
            return Msg.success("处理成功");
        } catch (LoginFailException e) {
            e.printStackTrace();
            return Msg.failure(e.getLocalizedMessage());
        }
    }
}
