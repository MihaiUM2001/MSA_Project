package com.example.swappy.controller;

import com.example.swappy.model.Product;
import com.example.swappy.service.ProductService;
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
    public Product createProduct(@RequestBody Product product) {
        return productService.saveProduct(product);
    }

    @PutMapping("/{id}")
    public Product updateProduct(@PathVariable Long id, @RequestBody Product updatedProduct) {
        Product existingProduct = productService.getProductById(id);
        if (existingProduct != null) {
            existingProduct.setProductTitle(updatedProduct.getProductTitle());
            existingProduct.setProductDescription(updatedProduct.getProductDescription());
            existingProduct.setProductImage(updatedProduct.getProductImage());
            existingProduct.setSwapPreference(updatedProduct.getSwapPreference());
            existingProduct.setIsVisible(updatedProduct.getIsVisible());
            return productService.saveProduct(existingProduct);
        }
        return null;
    }

    @DeleteMapping("/{id}")
    public void deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
    }
}
