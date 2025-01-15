package com.example.swappy.jpa.repository;

import com.example.swappy.model.Swap;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SwapRepository extends JpaRepository<Swap, Long> {
    Swap findOneById(Long id);
    List<Swap> findAllByProductId(Long id);
    List<Swap> findAllByProductIdAndAndBuyerId(Long productId, Long buyerId);
}

