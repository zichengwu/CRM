package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.workbench.dao.ActivityRemarkDao;
import com.cheng.ssm.workbench.domain.ActivityRemark;
import com.cheng.ssm.workbench.service.ActivityRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ActivityRemarkServiceImpl implements ActivityRemarkService {

    @Resource
    private ActivityRemarkDao activityRemarkDao;

    @Override
    public List<ActivityRemark> getRemarkByAcId(String activityId) {

        return activityRemarkDao.selectRemarkByAcId(activityId);
    }

    @Override
    public boolean deleteRemarkById(String id) {

        return 1 == activityRemarkDao.deleteRemarkById(id);
    }

    @Override
    public boolean saveRemark(ActivityRemark activityRemark) {

        return 1 == activityRemarkDao.insertRemark(activityRemark);
    }

    @Override
    public boolean updateRemark(ActivityRemark activityRemark) {

        return 1 == activityRemarkDao.updateRemark(activityRemark);
    }
}
