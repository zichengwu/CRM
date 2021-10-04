package com.cheng.ssm.workbench.web.controller;

import com.cheng.ssm.settings.domain.User;
import com.cheng.ssm.settings.service.UserService;
import com.cheng.ssm.utils.Msg;
import com.cheng.ssm.workbench.domain.Activity;
import com.cheng.ssm.workbench.domain.Clue;
import com.cheng.ssm.workbench.domain.Tran;
import com.cheng.ssm.workbench.service.ActivityService;
import com.cheng.ssm.workbench.service.ClueService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Controller
@RequestMapping("/workbench/clue")
public class ClueController {

    @Resource
    private UserService userService;

    @Resource
    private ActivityService activityService;

    @Resource
    private ClueService clueService;

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public Msg getUserList() {

        List<User> list = userService.getUserList();

        return Msg.success("获取用户成功").add("userList", list);
    }

    //保存线索
    @RequestMapping("/saveClue.do")
    @ResponseBody
    public Msg saveClue(Clue clue) {

        if(clueService.saveClue(clue)) {
            return Msg.success("保存成功");
        }
        return Msg.failure("保存失败");
    }

    //获取分页数据
    @RequestMapping("/getPageList.do")
    @ResponseBody
    public Msg getPageList(int pageNo, int pageSize) {
        PageHelper.startPage(pageNo, pageSize);
        List<Clue> list = clueService.getPageList();
        PageInfo<Clue> page = new PageInfo<>(list, pageSize);
        return Msg.success("查询成功").add("pageInfo", page);
    }

    //跳转线索详情
    @RequestMapping("/showDetail.do")
    public ModelAndView showDetail(String id) {
        ModelAndView mv = new ModelAndView();
        Clue c  = clueService.getClueById(id);
        mv.addObject("clue",c);
        mv.setViewName("/workbench/clue/detail.jsp");
        return mv;
    }

    //根据线索id查询关联得市场活动
    @RequestMapping("/showActivityByClueId.do")
    @ResponseBody
    public Msg getActivitiesByClueId(String id) {
        List<Activity> list = activityService.getActivitiesByClueId(id);
        return Msg.success("查询成功").add("list", list);
    }

    @RequestMapping("/unBindAC.do")
    @ResponseBody
    //根据关联关系表的id删除关联关系
    public Msg unBindAC(String id) {
        if(clueService.deleteACRelation(id)) {
            return Msg.success("解除成功");
        }
        return Msg.failure("解除失败");
    }

    //根据名称模糊查询市场活动列表用于关联线索（过滤已经关联了线索id的活动）
    @RequestMapping("/getAcByNameAndNotBind.do")
    @ResponseBody
    public Msg getActivityByName(String name, String clueId) {
        List<Activity> activities = activityService.getAcByNameAndNotBind(name, clueId);
        return Msg.success("查询成功").add("AcList", activities);
    }

    //根据线索id和市场活动id[]建立关联关系
    @RequestMapping("/bindAC.do")
    @ResponseBody
    public Msg bind(String clueId, @RequestParam("id") String[] ids) {
        String msg = null;
        try {
            if(clueService.bind(clueId, ids)) {
                return Msg.success("关联成功");
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = e.getLocalizedMessage();
        }
        return Msg.failure(msg);
    }

    // 根据活动名模糊查询活动信息
    @RequestMapping("/getAcByName.do")
    @ResponseBody
    public Msg getAcByName(String name){
        List<Activity> activities = activityService.getAcByName(name);
        return Msg.success("查询成功").add("acList", activities);
    }

    // 将线索转换为客户和联系人（根据flag判断是否要添加交易）
    @RequestMapping("/convert.do")
    public ModelAndView convert(String clueId, String flag, Tran tran, HttpServletRequest request){
        ModelAndView mv = new ModelAndView();
        User user = (User) request.getSession(false).getAttribute("user");
        String createBy = user.getName();
        // flag为0代表不需要添加交易
        // flag为1代表需要添加交易
        if("0".equals(flag)){
            tran = null;
        }
        try {
            clueService.convert(clueId,tran,createBy);
            mv.setViewName("/workbench/clue/index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mv;
    }
}
