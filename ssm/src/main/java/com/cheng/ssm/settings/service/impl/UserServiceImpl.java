package com.cheng.ssm.settings.service.impl;

import com.cheng.ssm.exception.LoginFailException;
import com.cheng.ssm.settings.dao.UserDao;
import com.cheng.ssm.settings.domain.User;
import com.cheng.ssm.settings.service.UserService;
import com.cheng.ssm.utils.DateTimeUtil;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;


// User类的service层 业务层用来处理业务
@Service
public class UserServiceImpl implements UserService {

    // UserDao层对象 通过Resource byName赋值
    @Resource
    private UserDao userDao;

    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginFailException {
        User user = new User();
        user.setLoginAct(loginAct);
        user.setLoginPwd(loginPwd);
        user = userDao.selectUserLogin(user);
        if (user == null){
            // 验证用户信息是否符合要求
            throw new LoginFailException("账号或密码错误！");

            // 验证失效时间 当前系统时间大于失效时间
        }else if(DateTimeUtil.getSysTime().compareTo(user.getExpireTime()) > 0){
            throw new LoginFailException("账号已经失效！");

            // 验证账号是否锁定
        }else if("0".equals(user.getLockState())){
            throw  new LoginFailException("此账号已锁定！");

            // 验证ip地址是否正确
        }else if(!user.getAllowIps().contains(ip)){
            throw new LoginFailException("访问主机无权限，以阻止访问！");
        }

        // 全部通过则返回uer
        return user;
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> getUserList() {   //获取所有登录用户
        return userDao.getUserList();
    }
}
