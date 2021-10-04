package com.cheng.ssm.workbench.service;

import com.cheng.ssm.workbench.domain.Activity;

import java.util.List;

public interface ActivityService {

    boolean saveActivity(Activity activity);

    List<Activity> getPageList(Activity activity);

    boolean delete(String[] ids);

    Activity getAcById(String id);

    boolean updateActivityById(Activity activity);

    Activity getDetailById(String id);

    List<Activity> getActivitiesByClueId(String id);

    List<Activity> getAcByNameAndNotBind(String name, String clueId);

    List<Activity> getAcByName(String name);
}
