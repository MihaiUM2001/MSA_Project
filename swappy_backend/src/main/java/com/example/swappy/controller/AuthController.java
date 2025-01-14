package com.example.swappy.controller;

import com.example.swappy.dto.LoginRequest;
import com.example.swappy.dto.LoginResponse;
import com.example.swappy.security.CustomUserDetailsService;
import com.example.swappy.security.JwtUtil;
import io.jsonwebtoken.Claims;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    private final CustomUserDetailsService userDetailsService;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil, CustomUserDetailsService userDetailsService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userDetailsService = userDetailsService;
    }

    @PostMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of(
                    "status", "invalid",
                    "message", "Authorization header is missing or improperly formatted"
            ));
        }

        String token = authHeader.substring(7); // Remove "Bearer " prefix

        try {
            // Extract claims from the token
            Claims claims = jwtUtil.extractAllClaims(token);

            // Check expiration directly from claims
            Date expiration = claims.getExpiration();
            if (expiration.before(new Date())) {
                return ResponseEntity.status(401).body(Map.of(
                        "status", "invalid",
                        "message", "Token is expired"
                ));
            }

            // Extract username and other details
            String username = claims.getSubject();
            Date issuedAt = claims.getIssuedAt();

            return ResponseEntity.ok(Map.of(
                    "status", "valid",
                    "user", Map.of(
                            "username", username,
                            "issuedAt", issuedAt,
                            "expiration", expiration
                    )
            ));
        } catch (Exception e) {
            // Handle unexpected errors during token processing
            return ResponseEntity.status(401).body(Map.of(
                    "status", "invalid",
                    "message", "Error validating token: " + e.getMessage()
            ));
        }
    }


    @PostMapping
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getEmail(),
                            loginRequest.getPassword()
                    )
            );
        } catch (Exception e) {
            // Return a 401 Unauthorized status with a structured error message
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new LoginResponse("Invalid credentials", null));
        }

        try {
            final UserDetails userDetails = userDetailsService.loadUserByUsername(loginRequest.getEmail());
            String token = jwtUtil.generateToken(userDetails);

            // Return a 200 OK status with the token and message
            return ResponseEntity.ok(new LoginResponse("Token generated successfully", token));
        } catch (Exception e) {
            // Return a 500 Internal Server Error status with a structured error message
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new LoginResponse("An error occurred during authentication", null));
        }
    }
}
