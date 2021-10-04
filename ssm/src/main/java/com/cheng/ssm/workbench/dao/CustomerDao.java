package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer selectCusByName(String company);

    int save(Customer customer);

    List<String> getCustomerName(String name);

}
