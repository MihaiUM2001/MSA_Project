package com.example.swappy.service;

import com.example.swappy.model.User;
import com.example.swappy.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class UserAuthService implements UserDetailsService {

    private final UserRepository userRepository;

    public UserAuthService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {
        Long id;
        try {
            id = Long.parseLong(userId); // Convert string to Long
        } catch (NumberFormatException e) {
            throw new UsernameNotFoundException("Invalid User ID: " + userId);
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with ID: " + id));

        return new org.springframework.security.core.userdetails.User(
                String.valueOf(user.getId()), // Use the ID as the username
                user.getPassword(),
                new ArrayList<>() // Empty authorities
        );
    }
}
