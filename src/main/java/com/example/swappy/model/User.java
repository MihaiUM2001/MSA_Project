package com.example.swappy.model;

import jakarta.persistence.*;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "swappy_user")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String fullName;
    private String email;
    private String phoneNumber;
    private String password;
    private String profilePictureURL;

    @OneToMany(mappedBy = "seller", cascade = CascadeType.ALL)
    private List<Product> products;

    @OneToMany(mappedBy = "buyer", cascade = CascadeType.ALL)
    private List<Swap> swapsAsBuyer;

    @OneToMany(mappedBy = "seller", cascade = CascadeType.ALL)
    private List<Swap> swapsAsSeller;

    // Getters and setters
}