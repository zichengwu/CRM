package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.exception.DeleteActivityException;
import com.cheng.ssm.utils.DateTimeUtil;
import com.cheng.ssm.workbench.dao.ActivityDao;
import com.cheng.ssm.workbench.dao.ActivityRemarkDao;
import com.cheng.ssm.workbench.domain.Activity;
import com.cheng.ssm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ActivityServiceImpl implements ActivityService {

    // 市场活动dao
    @Resource
    private ActivityDao activityDao;

    // 市场活动备注dao
    @Autowired
    private ActivityRemarkDao activityRemarkDao;

    @Override
    public boolean saveActivity(Activity activity) {
        return 1 == activityDao.insertActivity(activity);
    }

    @Override
    public List<Activity> getPageList(Activity activity) {
        return activityDao.getActivityListByCondition(activity);
    }

    @Override
    @Transactional
    public boolean delete(String[] ids) {  //批量删除市场活动
        // 首先查询出需要删除的市场活动对应的市场活动备注的总条数
        int remarkTotal = activityRemarkDao.selectRemarkSize(ids);

        // 然后对所有需要删除的市场活动备注进行删除 得到删除的条数
        int remarkResult = 0;
        if(remarkTotal != 0){
            remarkResult = activityRemarkDao.deleteRemark(ids);
        }
        // 然后对删除数量进行对比 不一样就抛异常 回滚事务 并且利用handler捕捉异常信息
        if(remarkTotal != remarkResult){
            throw new DeleteActivityException("删除市场活动备注失败！");
        }
        // 没有抛出异常则删除市场活动
        // 对需要删除的市场活动进行删除 得到删除条数
        int activityResult = activityDao.deleteActivity(ids);
        // 比较删除数量 不一样就抛出异常 回滚事务
        if(ids.length != activityResult){
            throw new DeleteActivityException("删除市场活动失败！");
        }
        // 测试事务注解  调试后发现使用事务注解的时候不要向外部抛出异常 如 throws 否则事务失效
        // 并且捕捉的异常必须继承runtimeException
        //throw new DeleteActivityException("测试的删除失败！");
        // 没有抛出异常代表删除成功
        return true;
    }

    @Override
    public Activity getAcById(String id) {

        return activityDao.selectActivityById(id);
    }

    @Override
    public boolean updateActivityById(Activity activity) {
        // 设置修改时间
        activity.setEditTime(DateTimeUtil.getSysTime());

        return 1 == activityDao.updateActivityById(activity);
    }

    // 根据id查询市场活动信息 owner已经转换为名字
    @Override
    public Activity getDetailById(String id) {

        return activityDao.selectDetailById(id);
    }

    // 根据线索id查询市场活动
    @Override
    public List<Activity> getActivitiesByClueId(String id) {
        return activityDao.selectActivitiesByClueId(id);
    }

    //根据名称模糊查询市场活动列表用于关联线索（去掉已经关联线索id的活动）
    @Override
    public List<Activity> getAcByNameAndNotBind(String name, String clueId) {
        return activityDao.getAcByNameAndNotBind(name, clueId);
    }

    //根据名称模糊查市场活动
    @Override
    public List<Activity> getAcByName(String name) {
        return activityDao.getAcByName(name);
    }


}
