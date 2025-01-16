package com.example.swappy.dto;


import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Setter
@Getter
public class UserUpdateRequest {
    private String fullName;

    private String email;

    private String phoneNumber;

    private String password;

    private String profilePictureURL;
}
