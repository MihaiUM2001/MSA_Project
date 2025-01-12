package com.example.swappy.service;

import com.example.swappy.dto.ProductRequest;
import com.example.swappy.dto.ProductUpdateRequest;
import com.example.swappy.exception.product.SellerDoesntOwnProductException;
import com.example.swappy.model.Product;
import com.example.swappy.model.User;
import com.example.swappy.repository.ProductRepository;
import com.example.swappy.repository.UserRepository;
import com.example.swappy.security.JwtUtil;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

@Service
public class ProductService {
    private final JwtUtil jwtUtil;

    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public ProductService(JwtUtil jwtUtil, UserRepository userRepository, ProductRepository productRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    // !!!
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product getProductById(Long id) {

        Product product = productRepository.findOneById(id);
        Integer views = product.getNumberOfViews();
        product.setNumberOfViews(views + 1);
        productRepository.save(product);

        return productRepository.findById(id).orElse(null);
    }

    public Product saveProduct(ProductRequest product, String token) {
        String email = getEmail(token);

        User seller = userRepository.findByEmail(email);
        Product newProduct = getProduct(product, seller);
        return productRepository.save(newProduct);
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

        Product existingProduct = productRepository.findOneById(productId);

        if (Objects.equals(email, existingProduct.getSeller().getEmail()) && product != null) {
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
            return productRepository.save(existingProduct);
        } else {
            throw new SellerDoesntOwnProductException("This product doesn't belong to user trying to modify");
        }
    }

    public void deleteProduct(Long id, String token) {
        String email = getEmail(token);

        Product existingProduct = productRepository.findOneById(id);

        if (Objects.equals(email, existingProduct.getSeller().getEmail())) {
            productRepository.deleteById(id);
        } else {
            throw new SellerDoesntOwnProductException("This product doesn't belong to user trying to delete");
        }
    }
}
