package com.example.swappy.config;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContexts;
import org.elasticsearch.client.RestClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.net.ssl.SSLContext;

@Configuration
public class ElasticsearchConfig {

    @Bean
    public ElasticsearchClient elasticsearchClient() throws Exception {
        final String elasticsearchHost = "http://localhost:9200";
        final String elasticsearchUsername = "elastic";
        final String elasticsearchPassword = "xaGEJd87*Ci2wgBxhymM"; // Replace with your password

        // Trust all certificates (for self-signed certificates)
        SSLContext sslContext = SSLContexts.custom()
                .loadTrustMaterial((chain, authType) -> true)
                .build();

        BasicCredentialsProvider credentialsProvider = new BasicCredentialsProvider();
        credentialsProvider.setCredentials(
                AuthScope.ANY,
                new UsernamePasswordCredentials(elasticsearchUsername, elasticsearchPassword)
        );

        CloseableHttpClient httpClient = HttpClients.custom()
                .setSSLContext(sslContext)
                .setDefaultCredentialsProvider(credentialsProvider)
                .build();

        RestClient restClient = RestClient.builder(new HttpHost("localhost", 9200, "http"))
                .setHttpClientConfigCallback(httpClientBuilder -> httpClientBuilder
                        .setDefaultCredentialsProvider(credentialsProvider)
                        .setSSLContext(sslContext))
                .build();

        ElasticsearchTransport transport = new RestClientTransport(
                restClient,
                new co.elastic.clients.json.jackson.JacksonJsonpMapper()
        );

        return new ElasticsearchClient(transport);
    }
}
