package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {

    int selectRemarkSize(String[] ids);

    int deleteRemark(String[] ids);

    List<ActivityRemark> selectRemarkByAcId(String activityId);

    int deleteRemarkById(String id);

    int insertRemark(ActivityRemark activityRemark);

    int updateRemark(ActivityRemark activityRemark);
}
