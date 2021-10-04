package com.cheng.ssm.settings.dao;

import com.cheng.ssm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {

    List<DicValue> getDicValueByCode(String code);
}
