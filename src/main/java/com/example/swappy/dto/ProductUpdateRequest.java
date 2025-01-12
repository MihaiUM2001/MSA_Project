package com.example.swappy.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Setter
@Getter
public class ProductUpdateRequest {
    private String productTitle;
    private String productDescription;
    private String productImage;

    private String swapPreference;

    private Double estimatedRetailPrice;

    private Boolean isVisible;
}