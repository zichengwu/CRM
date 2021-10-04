package com.cheng.ssm.workbench.service;

import com.cheng.ssm.workbench.domain.Clue;
import com.cheng.ssm.workbench.domain.Tran;

import java.util.List;

public interface ClueService {

    boolean saveClue(Clue clue);

    List<Clue> getPageList();

    Clue getClueById(String id);

    boolean deleteACRelation(String id);

    boolean bind(String clueId, String[] ids);

    void convert(String clueId, Tran tran, String createBy);

}
