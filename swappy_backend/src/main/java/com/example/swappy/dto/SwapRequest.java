package com.example.swappy.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Setter
@Getter
public class SwapRequest {
    private Long productId;
    private Long sellerId;
    private Double estimatedRetailPrice;
    private String swapProductTitle;
    private String swapProductDescription;
    private String swapProductImage;
}