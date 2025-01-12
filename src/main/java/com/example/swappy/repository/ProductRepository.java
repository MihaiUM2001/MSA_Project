package com.example.swappy.repository;

import com.example.swappy.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {
    Product findOneById(Long id);

    Page<Product> findAll(Pageable pageable);
}
