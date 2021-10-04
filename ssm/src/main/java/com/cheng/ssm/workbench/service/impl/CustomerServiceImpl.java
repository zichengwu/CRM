package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.workbench.dao.CustomerDao;
import com.cheng.ssm.workbench.service.CustomerService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class CustomerServiceImpl implements CustomerService {

    @Resource
    private CustomerDao customerDao;



    @Override
    public List<String> getCustomerName(String name) {
        return customerDao.getCustomerName(name);
    }
}
