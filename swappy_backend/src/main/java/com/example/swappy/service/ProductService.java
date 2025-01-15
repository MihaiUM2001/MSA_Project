package com.example.swappy.service;

import com.example.swappy.dto.ProductDTO;
import com.example.swappy.dto.ProductRequest;
import com.example.swappy.dto.ProductUpdateRequest;
import com.example.swappy.elasticsearch.repository.ProductElasticRepository;
import com.example.swappy.exception.product.SellerDoesntOwnProductException;
import com.example.swappy.jpa.repository.ProductJpaRepository;
import com.example.swappy.model.Product;
import com.example.swappy.model.User;
import com.example.swappy.jpa.repository.UserRepository;
import com.example.swappy.security.JwtUtil;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

@Service
public class ProductService {
    private final JwtUtil jwtUtil;

    private final UserRepository userRepository;
    private final ProductJpaRepository productJpaRepository;
    private final ProductElasticRepository productElasticRepository;

    public ProductService(JwtUtil jwtUtil, UserRepository userRepository, ProductJpaRepository productJpaRepository, ProductElasticRepository productElasticRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
        this.productJpaRepository = productJpaRepository;
        this.productElasticRepository = productElasticRepository;
    }

    // !!!
    public List<Product> getAllProducts() {
        return productJpaRepository.findAll();
    }

    public List<Product> getOwnProducts(String token) {
        String email = getEmail(token);

        User user = userRepository.findByEmail(email);

        return productJpaRepository.findAllBySellerId(user.getId());
    }

    public Product getProductById(Long id) {

        Product product = productJpaRepository.findOneById(id);
        Integer views = product.getNumberOfViews();
        product.setNumberOfViews(views + 1);
        productJpaRepository.save(product);

        return productJpaRepository.findById(id).orElse(null);
    }

    public Product saveProduct(ProductRequest product, String token) {
        String email = getEmail(token);

        User seller = userRepository.findByEmail(email);
        Product newProduct = getProduct(product, seller);
        Product savedProduct = productJpaRepository.save(newProduct);

        ProductDTO productDTO = ProductDTO.builder()
                .id(savedProduct.getId())
                .productTitle(savedProduct.getProductTitle())
                .productDescription(savedProduct.getProductDescription())
                .productImage(savedProduct.getProductImage())
                .swapPreference(savedProduct.getSwapPreference())
                .estimatedRetailPrice(savedProduct.getEstimatedRetailPrice())
                .sellerName(seller.getFullName())
                .sellerProfilePic(seller.getProfilePictureURL())
                .isVisible(savedProduct.getIsVisible())
                .build();

        // Save the ProductDTO in Elasticsearch
        productElasticRepository.save(productDTO);

        return savedProduct;
    }

    private String getEmail(String token) {
        String email = null;
        String jwt;

        if (token != null && token.startsWith("Bearer ")) {
            jwt = token.substring(7);
            email = jwtUtil.extractUsername(jwt);
        }
        return email;
    }

    private static Product getProduct(ProductRequest product, User seller) {
        Product newProduct = new Product();

        newProduct.setProductTitle(product.getProductTitle());
        newProduct.setProductDescription(product.getProductDescription());
        newProduct.setProductImage(product.getProductImage());
        newProduct.setSwapPreference(product.getSwapPreference());
        newProduct.setEstimatedRetailPrice(product.getEstimatedRetailPrice());
        newProduct.setSeller(seller);
        newProduct.setIsVisible(true);
        newProduct.setNumberOfViews(0);
        return newProduct;
    }

    public Product updateProduct(Long productId, ProductUpdateRequest product, String token) {
        String email = getEmail(token);

        // Fetch the existing product from the database
        Product existingProduct = productJpaRepository.findOneById(productId);

        // Check if the product belongs to the user
        if (Objects.equals(email, existingProduct.getSeller().getEmail()) && product != null) {
            // Update the product's fields if provided
            if (product.getProductTitle() != null) {
                existingProduct.setProductTitle(product.getProductTitle());
            }
            if (product.getProductDescription() != null) {
                existingProduct.setProductDescription(product.getProductDescription());
            }
            if (product.getProductImage() != null) {
                existingProduct.setProductImage(product.getProductImage());
            }
            if (product.getSwapPreference() != null) {
                existingProduct.setSwapPreference(product.getSwapPreference());
            }
            if (product.getEstimatedRetailPrice() != null) {
                existingProduct.setEstimatedRetailPrice(product.getEstimatedRetailPrice());
            }
            if (product.getIsVisible() != null) {
                existingProduct.setIsVisible(product.getIsVisible());
            }

            // Save the updated product in the database
            Product updatedProduct = productJpaRepository.save(existingProduct);

            // Update the product in Elasticsearch
            ProductDTO productDTO = ProductDTO.builder()
                    .id(updatedProduct.getId())
                    .productTitle(updatedProduct.getProductTitle())
                    .productDescription(updatedProduct.getProductDescription())
                    .productImage(updatedProduct.getProductImage())
                    .swapPreference(updatedProduct.getSwapPreference())
                    .estimatedRetailPrice(updatedProduct.getEstimatedRetailPrice())
                    .sellerName(updatedProduct.getSeller().getFullName())
                    .isVisible(updatedProduct.getIsVisible())
                    .build();

            productElasticRepository.save(productDTO);

            return updatedProduct;
        } else {
            throw new SellerDoesntOwnProductException("This product doesn't belong to the user trying to modify");
        }
    }


    public void deleteProduct(Long id, String token) {
        String email = getEmail(token);

        Product existingProduct = productJpaRepository.findOneById(id);

        if (Objects.equals(email, existingProduct.getSeller().getEmail())) {
            productJpaRepository.deleteById(id);
        } else {
            throw new SellerDoesntOwnProductException("This product doesn't belong to user trying to delete");
        }
    }
}
