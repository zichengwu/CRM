package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.ClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationDao {

    int deleteACRelation(String id);

    int insertCARelation(Map<String, String> map);

    List<ClueActivityRelation> getRelationByClueId(String clueId);
}
