package com.example.swappy.jpa.repository;

import com.example.swappy.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

    User findByEmail(String email);
    User findOneById(Long id);

}