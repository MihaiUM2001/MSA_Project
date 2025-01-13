package com.example.swappy.service;

import com.example.swappy.exception.user.NoSuchUserExistsException;
import com.example.swappy.exception.user.UserAlreadyExistsException;
import com.example.swappy.model.User;
import com.example.swappy.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
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
}

