package com.example.swappy.elasticsearch.repository;

import com.example.swappy.dto.ProductDTO;
import com.example.swappy.model.Product;
import org.springframework.data.elasticsearch.annotations.Query;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import java.util.List;

public interface ProductElasticRepository extends ElasticsearchRepository<ProductDTO, Long> {
    @Query("{\"match\": {\"productTitle\": {\"query\": \"?0\", \"fuzziness\": \"AUTO\"}}}")
    List<ProductDTO> findByTitleFuzzy(String query);

}
