package com.cheng.ssm.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

public class DateTimeUtil {	//生成当前系统时间
	
	public static String getSysTime(){
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		Date date = new Date();

		return sdf.format(date);
		
	}
	
}
