package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.Contacts;

import java.util.List;

public interface ContactsDao {


    int save(Contacts contacts);

    List<Contacts> getContactsByName(String name);

    Contacts getOneContactsByName(String name);
}
