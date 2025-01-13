package com.example.swappy.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Setter
@Getter
public class ProductRequest {
    private String productTitle;
    private String productDescription;
    private String productImage;

    private String swapPreference;

    private Double estimatedRetailPrice;
}