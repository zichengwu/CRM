package com.cheng.ssm.utils;

import java.util.HashMap;
import java.util.Map;

public class Msg {
    //状态码 自定义100代表成功， 200代表失败
    private int code;

    //提示信息
    private String message;

    //返回给浏览器的数据
    private Map<String, Object> extend = new HashMap<>();

    public static Msg success(String message) {
        Msg result = new Msg();
        result.setCode(100);
        result.setMessage(message);
        return result;
    }

    public static Msg failure(String message) {
        Msg result = new Msg();
        result.setCode(200);
        result.setMessage(message);
        return result;
    }

    //用于链式调用
    public Msg add(String key, Object value){
        this.getExtend().put(key, value);
        return this;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Map<String, Object> getExtend() {
        return extend;
    }

    public void setExtend(Map<String, Object> extend) {
        this.extend = extend;
    }
}

