package com.example.swappy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.elasticsearch.annotations.Document;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Document(indexName = "productdto")
public class ProductDTO {

    private Long id;
    private String productTitle;
    private String productDescription;
    private String productImage;
    private String swapPreference;
    private Double estimatedRetailPrice;
    private Boolean isVisible;
    private String sellerName;
    private String sellerProfilePic;
    private Boolean isSold;
}
