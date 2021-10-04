package com.cheng.ssm.settings.service.impl;

import com.cheng.ssm.settings.dao.DicTypeDao;
import com.cheng.ssm.settings.dao.DicValueDao;
import com.cheng.ssm.settings.domain.DicType;
import com.cheng.ssm.settings.domain.DicValue;
import com.cheng.ssm.settings.service.DicService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DicServiceImpl implements DicService {

    @Resource
    private DicTypeDao dicTypeDao;

    @Resource
    private DicValueDao dicValueDao;

    @Override
    public Map<String, List<DicValue>> getDicValue() {

        Map<String, List<DicValue>> map = new HashMap<>();

        //取出所有得类型
        List<DicType> types = dicTypeDao.getAllType();

        //根据类型取出所有值
        for (DicType dicType : types) {

            //取得每一种类型对应得类型编码code
            String code = dicType.getCode();

            //根据字典类型来获取字典值
            List<DicValue> values = dicValueDao.getDicValueByCode(code);

            // 在map中设置 每一个code对应一个value集合
            map.put(code,values);
        }
        return map;
    }
}
