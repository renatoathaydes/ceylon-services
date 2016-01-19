package com.athaydes.java_se_service;

import com.google.auto.service.AutoService;

@AutoService(Runnable.class)
public class AJavaService implements Runnable {
	
	public void run() {
		System.out.println("A Java Service is running");
	}
	
}
