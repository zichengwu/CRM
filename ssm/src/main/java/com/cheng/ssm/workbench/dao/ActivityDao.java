package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.Activity;

import java.util.List;

public interface ActivityDao {
    long insertActivity(Activity activity);

    List<Activity> getActivityListByCondition(Activity activity);

    int deleteActivity(String[] ids);

    Activity selectActivityById(String id);

    int updateActivityById(Activity activity);

    Activity selectDetailById(String id);

    List<Activity> selectActivitiesByClueId(String id);

    List<Activity> getAcByNameAndNotBind( String name, String clueId);

    List<Activity> getAcByName(String name);
}
