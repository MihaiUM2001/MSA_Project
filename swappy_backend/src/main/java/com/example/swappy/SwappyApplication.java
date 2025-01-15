package com.example.swappy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.example.swappy.jpa.repository")
@EnableElasticsearchRepositories(basePackages = "com.example.swappy.elasticsearch.repository")
public class SwappyApplication {

    public static void main(String[] args) {
        SpringApplication.run(SwappyApplication.class, args);
    }

}
