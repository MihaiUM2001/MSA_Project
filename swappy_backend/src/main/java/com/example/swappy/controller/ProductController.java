package com.example.swappy.controller;

import com.example.swappy.dto.ProductDTO;
import com.example.swappy.dto.ProductRequest;
import com.example.swappy.dto.ProductUpdateRequest;
import com.example.swappy.exception.ErrorResponse;
import com.example.swappy.exception.product.SellerDoesntOwnProductException;
import com.example.swappy.model.Product;
import com.example.swappy.elasticsearch.repository.ProductElasticRepository;
import com.example.swappy.service.ProductService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    private final ProductElasticRepository productElasticRepository;
    public ProductController(ProductService productService, ProductElasticRepository productElasticRepository) {
        this.productService = productService;
        this.productElasticRepository = productElasticRepository;
    }

    // !!!
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @GetMapping("/own")
    public List<Product> getOwnProducts(@RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        return productService.getOwnProducts(token);
    }

    @GetMapping("/{id}")
    public Product getProductById(@PathVariable Long id) {
        return productService.getProductById(id);
    }

    @PostMapping
    public Product createProduct(@RequestHeader(HttpHeaders.AUTHORIZATION) String token, @RequestBody ProductRequest product) {
        return productService.saveProduct(product, token);
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProductDTO>> searchProducts(@RequestParam String q) {
        List<ProductDTO> products = productElasticRepository.findByTitleFuzzy(q);
        return ResponseEntity.ok(products);
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
