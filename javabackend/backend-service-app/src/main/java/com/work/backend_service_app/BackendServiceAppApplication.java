package com.work.backend_service_app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendServiceAppApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendServiceAppApplication.class, args);
		System.err.println("backend microservice up!  8181");
	}

}
