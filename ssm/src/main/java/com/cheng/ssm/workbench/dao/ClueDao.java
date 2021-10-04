package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.Clue;

import java.util.List;

public interface ClueDao {

    int insertClue(Clue clue);

    List<Clue> getPageList();

    Clue getClueById(String id);

    Clue selectClueById(String clueId);

    int deleteClueById(String clueId);
}
