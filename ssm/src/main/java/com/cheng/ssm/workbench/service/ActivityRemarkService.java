package com.cheng.ssm.workbench.service;

import com.cheng.ssm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkService {

    List<ActivityRemark> getRemarkByAcId(String activityId);

    boolean deleteRemarkById(String id);

    boolean saveRemark(ActivityRemark activityRemark);

    boolean updateRemark(ActivityRemark activityRemark);
}
