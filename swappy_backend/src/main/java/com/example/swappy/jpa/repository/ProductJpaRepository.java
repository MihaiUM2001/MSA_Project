package com.example.swappy.jpa.repository;

import com.example.swappy.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductJpaRepository extends JpaRepository<Product, Long> {

    List<Product> findAll();
    Product findOneById(Long id);

    List<Product> findAllBySellerId(Long id);
}
