package com.example.orders;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/orders")
public class OrderController {
    @GetMapping
    public Map<String, Object> all(HttpServletRequest request) {
        return response(List.of(Map.of("id", 1001, "status", "READY")), request);
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody(required = false) Map<String, Object> order,
            HttpServletRequest request) {
        return response(Map.of("id", 1002, "status", "CREATED", "request", order == null ? Map.of() : order),
                request);
    }

    private Map<String, Object> response(Object data, HttpServletRequest request) {
        return Map.of("service", "orders-service", "data", data, "receivedHeaders", headers(request));
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
