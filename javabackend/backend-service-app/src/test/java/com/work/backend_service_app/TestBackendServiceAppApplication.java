package com.work.backend_service_app;

import org.springframework.boot.SpringApplication;

public class TestBackendServiceAppApplication {

	public static void main(String[] args) {
		SpringApplication.from(BackendServiceAppApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
