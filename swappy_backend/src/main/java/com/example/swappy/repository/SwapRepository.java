package com.example.swappy.repository;

import com.example.swappy.model.Swap;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SwapRepository extends JpaRepository<Swap, Long> {
    Swap findOneById(Long id);
}

