package com.example.products;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/products")
public class ProductController {
    private static final List<Map<String, Object>> PRODUCTS = List.of(
            Map.of("id", 1, "name", "Gateway Guide", "price", 19.99),
            Map.of("id", 2, "name", "Rate Limit Mug", "price", 12.50));

    @GetMapping
    public Map<String, Object> all(HttpServletRequest request) {
        return response(PRODUCTS, request);
    }

    @GetMapping("/{id}")
    public Map<String, Object> one(@PathVariable int id, HttpServletRequest request) {
        return response(PRODUCTS.stream().filter(product -> product.get("id").equals(id)).findFirst()
                .orElse(Map.of("id", id, "name", "Unknown product")), request);
    }

    private Map<String, Object> response(Object data, HttpServletRequest request) {
        return Map.of("service", "products-service", "data", data, "receivedHeaders", headers(request));
    }

    private Map<String, String> headers(HttpServletRequest request) {
        return Map.of(
                "x-gateway-demo", header(request, "X-Gateway-Demo"),
                "x-correlation-id", header(request, "X-Correlation-ID"),
                "x-consumer-username", header(request, "X-Consumer-Username"),
                "x-api-key", header(request, "X-Api-Key"));
    }

    private String header(HttpServletRequest request, String name) {
        return request.getHeader(name) == null ? "" : request.getHeader(name);
    }
}
