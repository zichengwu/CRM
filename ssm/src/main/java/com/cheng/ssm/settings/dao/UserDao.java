package com.cheng.ssm.settings.dao;

import com.cheng.ssm.settings.domain.User;

import java.util.List;

public interface UserDao {

    User selectUserLogin(User user);

    List<User> getUserList();
}
