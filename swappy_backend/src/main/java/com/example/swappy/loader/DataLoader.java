package com.example.swappy.loader;

import com.example.swappy.dto.ProductDTO;
import com.example.swappy.elasticsearch.repository.ProductDTODocumentRepository;
import com.example.swappy.elasticsearch.repository.ProductElasticRepository;
import com.example.swappy.jpa.repository.ProductJpaRepository;
import com.example.swappy.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class DataLoader {

    @Autowired
    private ProductJpaRepository productRepository;

    @Autowired
    private ProductDTODocumentRepository productDTODocumentRepository;

    @Transactional
    public void loadData() {
        List<Product> products = productRepository.findAll();

        // Convert entities to DTOs
        List<ProductDTO> productDTOs = products.stream().map(product -> ProductDTO.builder()
                .id(product.getId())
                .productTitle(product.getProductTitle())
                .productDescription(product.getProductDescription())
                .productImage(product.getProductImage())
                .swapPreference(product.getSwapPreference())
                .estimatedRetailPrice(product.getEstimatedRetailPrice())
                .isVisible(product.getIsVisible())
                .isSold(product.getIsSold())
                .sellerName(product.getSeller() != null ? product.getSeller().getFullName() : null)
                .sellerProfilePic(product.getSeller() != null ? product.getSeller().getProfilePictureURL() : null)
                .build()
        ).collect(Collectors.toList());

        // Save DTOs to Elasticsearch
        productDTODocumentRepository.saveAll(productDTOs);
    }
}
