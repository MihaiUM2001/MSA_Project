package com.example.swappy.model;

import jakarta.persistence.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

@Document(indexName = "products")
public class ProductElastic {
    @Id
    private String id;

    @Field(type = FieldType.Text)
    private String productTitle;

    @Field(type = FieldType.Text)
    private String productDescription;
}
