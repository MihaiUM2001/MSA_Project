package com.example.swappy.loader;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataLoaderRunner implements CommandLineRunner {

    @Autowired
    private DataLoader dataLoader;

    @Override
    public void run(String... args) {
        dataLoader.loadData();
    }
}
