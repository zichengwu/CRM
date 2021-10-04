package com.cheng.ssm.workbench.web.controller;

import com.cheng.ssm.utils.Msg;
import com.cheng.ssm.settings.domain.User;
import com.cheng.ssm.settings.service.UserService;
import com.cheng.ssm.utils.DateTimeUtil;
import com.cheng.ssm.utils.UUIDUtil;
import com.cheng.ssm.workbench.domain.Activity;
import com.cheng.ssm.workbench.domain.ActivityRemark;
import com.cheng.ssm.workbench.service.ActivityRemarkService;
import com.cheng.ssm.workbench.service.ActivityService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import java.util.List;

// 市场模块的controller类
@Controller
@RequestMapping("/workbench/activity")
public class ActivityController {

    @Resource
    private UserService userService;

    @Resource
    private ActivityService activityService;

    @Resource
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        // 查询用户的所有信息
        return userService.getUserList();
    }

    // 保存一条活动信息
    @RequestMapping("/saveActivity.do")
    @ResponseBody
    public Msg saveActivity(Activity activity){

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();

        activity.setId(id);
        activity.setCreateTime(createTime);
        // 得到保存结果
        if(activityService.saveActivity(activity)) {
            return Msg.success("success");
        }
        return Msg.success("failure");
    }

    @PostMapping("/pageList.do")
    @ResponseBody
    // 拿到页码和页面记录条数
    public Msg getPageList(String pageNo, String pageSize,Activity activity){
        PageHelper.startPage(Integer.parseInt(pageNo), Integer.parseInt(pageSize));
        // 得到分页完成的市场活动列表和总记录条数的分装类
        List<Activity> list = activityService.getPageList(activity);
        //使用PageInfo包装查询后的结果,只需要把PageInfo交给界面就可以(封装了详细的页面信息)
        PageInfo<Activity> page = new PageInfo<>(list,Integer.parseInt(pageSize));
        return Msg.success("处理成功").add("pageInfo", page);
    }

    //删除市场活动
    @RequestMapping ( "/delete.do")
    @ResponseBody
    public Msg delete(@RequestParam("id") String[] ids) {
        boolean flag = activityService.delete(ids);
        if(flag) {
            return Msg.success("删除成功");
        }
        return Msg.failure("删除失败，请重试！");
    }

    // 根据id查询市场活动
    @RequestMapping("/getAcById.do")
    @ResponseBody
    public Msg getAcById(String id) {
        // 查询到市场活动信息
        Activity activity = activityService.getAcById(id);
        // 拿到所有的用户
        List<User> userList = userService.getUserList();
        // 封装入Msg
        return Msg.success("处理成功").add("activity",activity).add("userList",userList);
    }

    // 修改市场活动根据id
    @RequestMapping("/updateActivity.do")
    @ResponseBody
    public Msg updateActivityById(Activity activity){
        if(activityService.updateActivityById(activity)) {
            return Msg.success("修改成功");
        }
        return Msg.failure("修改失败");
    }

    // 显示市场活动detail.jsp页面
    @RequestMapping("/showDetail.do")
    public ModelAndView showDetail(String id){
        ModelAndView mv = new ModelAndView();
        // 根据id获取activity
        Activity activity = activityService.getDetailById(id);
        mv.addObject("activity",activity);
        mv.setViewName("/workbench/activity/detail.jsp");
        return mv;
    }

    //根据市场活动id取得备注信息
    @RequestMapping("/getRemark.do")
    @ResponseBody
    public Msg getRemarkByAcId(String activityId) {
        List<ActivityRemark> remarks =  activityRemarkService.getRemarkByAcId(activityId);
        return Msg.success("查询成功").add("list", remarks);
    }

    // 根据remarkId删除remark
    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Msg deleteRemarkById(String id) {
        boolean flag = activityRemarkService.deleteRemarkById(id);
        if(flag) {
            return Msg.success("删除成功");
        }
        return Msg.failure("删除失败");
    }

    //保存添加的市场活动备注
    @RequestMapping("saveRemark.do")
    @ResponseBody
    public Msg saveRemark(ActivityRemark activityRemark) {
        // 添加创建时间
        activityRemark.setCreateTime(DateTimeUtil.getSysTime());

        // 设置修改标记
        activityRemark.setEditFlag("0");

        // 设置id
        String uuid = UUIDUtil.getUUID();
        activityRemark.setId(uuid);

        boolean flag = activityRemarkService.saveRemark(activityRemark);
        if (flag) {
            return Msg.success("添加成功").add("remark", activityRemark);
        }
        return Msg.failure("添加失败");
    }

    //更改备注
    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Msg updateRemark(ActivityRemark activityRemark) {
        // 设置属性值
        activityRemark.setEditFlag("1");
        activityRemark.setEditTime(DateTimeUtil.getSysTime());

        boolean flag = activityRemarkService.updateRemark(activityRemark);
        if (flag) {
            return Msg.success("更新成功").add("ar", activityRemark);
        }
        return Msg.failure("更新失败");
    }
}
