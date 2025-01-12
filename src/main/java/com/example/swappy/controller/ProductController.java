package com.example.swappy.controller;

import com.example.swappy.dto.ProductRequest;
import com.example.swappy.dto.ProductUpdateRequest;
import com.example.swappy.exception.ErrorResponse;
import com.example.swappy.exception.product.SellerDoesntOwnProductException;
import com.example.swappy.model.Product;
import com.example.swappy.service.ProductService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    // !!!
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    public Product getProductById(@PathVariable Long id) {
        return productService.getProductById(id);
    }

    @PostMapping
    public Product createProduct(@RequestHeader(HttpHeaders.AUTHORIZATION) String token, @RequestBody ProductRequest product) {
        return productService.saveProduct(product, token);
    }

    @PatchMapping("/{id}")
    public Product updateProduct(@PathVariable Long id, @RequestBody ProductUpdateRequest updatedProduct, @RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        return productService.updateProduct(id, updatedProduct, token);
    }

    @DeleteMapping("/{id}")
    public void deleteProduct(@PathVariable Long id, @RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        productService.deleteProduct(id, token);
    }

    @ExceptionHandler(value = SellerDoesntOwnProductException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleSellerDoesntOwnProductException(SellerDoesntOwnProductException e) {
        return new ErrorResponse(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }
}
