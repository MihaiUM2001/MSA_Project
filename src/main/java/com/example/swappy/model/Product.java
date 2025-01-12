package com.example.swappy.model;

import jakarta.persistence.*;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String productTitle;
    private String productDescription;
    private String productImage;

    private String swapPreference;

    private Double estimatedRetailPrice;

    @ManyToOne
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    private String publishDate;
    private Integer numberOfViews;
    private Boolean isVisible;

    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL)
    private List<Swap> swaps;

    // Getters and setters
}

