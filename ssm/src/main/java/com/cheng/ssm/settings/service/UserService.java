package com.cheng.ssm.settings.service;

import com.cheng.ssm.exception.LoginFailException;
import com.cheng.ssm.settings.domain.User;

import java.util.List;


public interface UserService {

    User login(String loginAct, String loginPwd, String ip) throws LoginFailException;

    List<User> getUserList();
}
