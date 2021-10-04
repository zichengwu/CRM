package com.cheng.ssm.workbench.service;

import com.cheng.ssm.workbench.domain.Contacts;

import java.util.List;

public interface ContactsService {
    List<Contacts> getContactsByName(String name);
}
