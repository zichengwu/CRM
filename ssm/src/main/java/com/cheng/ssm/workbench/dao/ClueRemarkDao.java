package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getClueRemarkByClueId(String clueId);

    int deleteClueRemark(String id);
}
