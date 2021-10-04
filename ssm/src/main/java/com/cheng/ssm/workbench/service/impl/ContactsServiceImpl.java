package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.workbench.dao.ContactsDao;
import com.cheng.ssm.workbench.domain.Contacts;
import com.cheng.ssm.workbench.service.ContactsService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ContactsServiceImpl implements ContactsService {

    @Resource
    private ContactsDao contactsDao;


    @Override
    public List<Contacts> getContactsByName(String name) {
        return contactsDao.getContactsByName(name);
    }
}
