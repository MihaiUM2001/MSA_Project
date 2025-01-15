package com.example.swappy.service;

import com.example.swappy.exception.user.NoSuchUserExistsException;
import com.example.swappy.exception.user.UserAlreadyExistsException;
import com.example.swappy.model.User;
import com.example.swappy.jpa.repository.UserRepository;
import com.example.swappy.security.JwtUtil;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    private final JwtUtil jwtUtil;

    private final UserRepository userRepository;

    public UserService(JwtUtil jwtUtil, UserRepository userRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User getMe(String token) {
        String email = getEmail(token);

        return userRepository.findByEmail(email);
    }

    public User getUserById(Long id) {

        User user = userRepository.findById(id).orElse(null);

        if (user == null) {
            throw new NoSuchUserExistsException("User with id " + id + " not found!");
        } else return user;
    }

    public User saveUser(User user) {
        if (userRepository.findByEmail(user.getEmail()) != null) {
            throw new UserAlreadyExistsException("User already exists!");
        } else {
            return userRepository.save(user);
        }
    }

    public void deleteUser(Long id) {
        if (userRepository.findById(id).orElse(null) == null) {
            throw new NoSuchUserExistsException("User with id " + id + " not found!");
        } else {
            userRepository.deleteById(id);
        }
    }

    private String getEmail(String token) {
        String email = null;
        String jwt;

        if (token != null && token.startsWith("Bearer ")) {
            jwt = token.substring(7);
            email = jwtUtil.extractUsername(jwt);
        }
        return email;
    }
}

