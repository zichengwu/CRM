package com.cheng.ssm.web.listener;

import com.cheng.ssm.settings.domain.DicValue;
import com.cheng.ssm.settings.service.DicService;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

//设置系统初始化监听器  当服务器启动的时候将数据字典初始化放入上下文作用域对象中 (application)
public class SysInitListener implements ServletContextListener {

    //服务器启动上下文对象创建完成后，马上执行该方法
    //event：监听什么对象，就可以通过该参数获得什么对象
    @Override
    public void contextInitialized(ServletContextEvent event) {

        ServletContext application = event.getServletContext();

        // 通过util获取spring容器
        WebApplicationContext applicationContext = WebApplicationContextUtils.getRequiredWebApplicationContext(application);

        // 通过spring获取数据字典的业务类
        DicService dicService = applicationContext.getBean("dicServiceImpl", DicService.class);

        Map<String , List<DicValue>> map = dicService.getDicValue();

        Set<String> set =  map.keySet();

        // 将类型名称和值的集合放入上下文
        for(String key: set) {
            application.setAttribute(key,map.get(key));
        }
        System.out.println("数据字典已经放入application域！！！");

        // 将阶段和可能性的映射资源文件放入上下文作用域
        ResourceBundle resourceBundle =  ResourceBundle.getBundle("Stage2Possibility");
        Set<String> keySet = resourceBundle.keySet();
        Map<String ,String> map1 = new HashMap<>();
        keySet.forEach(key -> {
            String value = resourceBundle.getString(key);
            map1.put(key,value);
        });
        application.setAttribute("pMap",map1);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
    }
}
