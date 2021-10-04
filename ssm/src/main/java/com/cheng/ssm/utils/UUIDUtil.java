package com.cheng.ssm.utils;

import java.util.UUID;

public class UUIDUtil {	//生成UUID
	
	public static String getUUID(){
		
		return UUID.randomUUID().toString().replaceAll("-","");
		
	}
	
}
