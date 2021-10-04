package com.cheng.ssm.workbench.web.controller;

import com.cheng.ssm.settings.domain.User;
import com.cheng.ssm.settings.service.UserService;
import com.cheng.ssm.utils.Msg;
import com.cheng.ssm.workbench.domain.Activity;
import com.cheng.ssm.workbench.domain.Contacts;
import com.cheng.ssm.workbench.domain.Tran;
import com.cheng.ssm.workbench.domain.TranHistory;
import com.cheng.ssm.workbench.service.ActivityService;
import com.cheng.ssm.workbench.service.ContactsService;
import com.cheng.ssm.workbench.service.CustomerService;
import com.cheng.ssm.workbench.service.TranService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/transaction")
public class TranController {

    @Resource
    private TranService tranService;

    @Resource
    private UserService userService;

    @Resource
    private CustomerService customerService;

    @Resource
    private ContactsService contactsService;

    @Resource
    private ActivityService activityService;


    //跳转到添加页面之前先走后台取userList数据
    @RequestMapping("/add.do")
    public ModelAndView addJsp(){

        ModelAndView mv = new ModelAndView();
        List<User> userList = userService.getUserList();
        mv.addObject("userList",userList);
        mv.setViewName("/workbench/transaction/save.jsp");
        return mv;
    }

    //模糊查询客户名称
    @RequestMapping("/getCustomerName.do")
    @ResponseBody
    public Msg getCustomerName(String name){
        List<String> nameList = customerService.getCustomerName(name);
        return Msg.success("查询成功").add("cList", nameList);
    }

    //根据关键字模糊查询联系人
    @RequestMapping("/getContactsByName.do")
    @ResponseBody
    public Msg getContactsByName(String name) {
        List<Contacts> list = contactsService.getContactsByName(name);
        return Msg.success("查询成功").add("cList", list);
    }

    //根据关键字模糊查询市场活动
    @RequestMapping("/getAcByName.do")
    @ResponseBody
    public Msg getActivityByName(String name) {
        List<Activity> list = activityService.getAcByName(name);
        return Msg.success("查询成功").add("acList", list);
    }

    //分页
    @RequestMapping("/getPageList.do")
    @ResponseBody
    public Msg getPageList(int pageNo, int pageSize) {
        PageHelper.startPage(pageNo, pageSize);
        List<Tran> list = tranService.getPageList();
        PageInfo<Tran> pageInfo = new PageInfo<>(list, pageSize);
        return Msg.success("处理成功").add("pageInfo", pageInfo);
    }

    //创建交易
    @RequestMapping("/saveTran.do")
    public ModelAndView saveTran(Tran tran, String customerName, String contactsName){
        ModelAndView mv = new ModelAndView();
        tranService.saveTran(tran , customerName, contactsName);
        mv.setViewName("redirect:/workbench/transaction/index.jsp");
        return mv;
    }

    //跳转交易详情
    @RequestMapping("/detail.do")
    public ModelAndView detail(String id , HttpServletRequest request){
        ModelAndView mv = new ModelAndView();
        Tran tran = tranService.detail(id);
        Map<String , String> map = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        tran.setPossibility(map.get(tran.getStage()));
        mv.addObject("tran",tran);
        mv.setViewName("/workbench/transaction/detail.jsp");
        return mv;
    }

    //展示交易历史
    @RequestMapping("/getHistoryListByTranId.do")
    @ResponseBody
    public Msg getHistoryListByTranId(String id, HttpServletRequest request) {
        List<TranHistory> tranHistoryList = tranService.getHistoryListByTranId(id);
        Map<String , String> map = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        tranHistoryList.forEach(tranHistory -> tranHistory.setPossibility(map.get(tranHistory.getStage())));
        return Msg.success("查询成功").add("list", tranHistoryList);
    }

    //改变交易状态
    @RequestMapping("/changeStage.do")
    @ResponseBody
    public Msg changeStage(Tran tran) {
        try {
            tranService.updateStage(tran);
            return Msg.success("更新成功").add("tran", tran);
        } catch (Exception e) {
            e.printStackTrace();
            return Msg.failure(e.getMessage());
        }
    }

    //统计图标
    @RequestMapping("/getCharts.do")
    @ResponseBody
    public Msg getCharts() {

        Map<String, Object> map = tranService.getCharts();
        return Msg.success("查询成功").add("map", map);
    }
}
