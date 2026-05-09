package com.shop.crud.Controller;

import com.shop.crud.Model.*;
import com.shop.crud.Repo.OrderRepo;
import com.shop.crud.Repo.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderRepo orderRepo;

    @Autowired
    private UserRepo userRepo;
    @PostMapping("/checkout")
    @PreAuthorize("hasRole('USER')")
    @ResponseStatus(HttpStatus.CREATED)
    public Order checkout(@RequestBody Order order) {
        User currentUser = getCurrentUser();
        
        order.setUser(currentUser);
        order.setDate(new Date());
        
        order.setOrderNumber(generateOrderNumber());
        
        order.setStatus(OrderStatus.PENDING);
        
        if (order.getFullName() == null || order.getFullName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Full name is required");
        }
        if (order.getAddress() == null || order.getAddress().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Address is required");
        }
        if (order.getPhone() == null || order.getPhone().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number is required");
        }
        
        if (order.getPaymentMethod() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Payment method is required");
        }
        
        // Set order reference on items
        if (order.getItems() != null && !order.getItems().isEmpty()) {
            for (OrderItem item : order.getItems()) {
                item.setOrder(order);
            }
        }
        
        order.calculateTotalPrice();
        
        return orderRepo.save(order);
    }

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    @ResponseStatus(HttpStatus.CREATED)
    public Order createOrder(@RequestBody Order order) {
        User currentUser = getCurrentUser();
        order.setUser(currentUser);
        order.setDate(new Date());
        order.setStatus(OrderStatus.PENDING);
        
        // Set order reference on items
        if (order.getItems() != null && !order.getItems().isEmpty()) {
            for (OrderItem item : order.getItems()) {
                item.setOrder(order);
            }
        }
        
        order.calculateTotalPrice();
        return orderRepo.save(order);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('USER','ADMIN')")
    public List<Order> getMyOrders() {
        User currentUser = getCurrentUser();
        return orderRepo.findByUser(currentUser);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER','ADMIN')")
    public Order getOrderById(@PathVariable Long id) {
        Order order = orderRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
        
        // Check if user owns this order
        User currentUser = getCurrentUser();
        User orderUser = order.getUser();
        if (orderUser == null || orderUser.getId() != currentUser.getId()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have access to this order");
        }
        
        return order;
    }

    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public List<Order> getAllOrders() {
        return orderRepo.findAll();
    }

    @PatchMapping("/admin/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public Order updateOrderStatus(@PathVariable Long id, @RequestBody OrderStatusUpdate statusUpdate) {
        Order order = orderRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
        
        if (statusUpdate.getStatus() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status is required");
        }
        
        order.setStatus(statusUpdate.getStatus());
        return orderRepo.save(order);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteOrder(@PathVariable Long id) {
        orderRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
        orderRepo.deleteById(id);
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        System.out.println("DEBUG: Looking up user with email: '" + email + "'");
        System.out.println("DEBUG: Authentication principal: " + authentication.getPrincipal());
        System.out.println("DEBUG: Authentication name: " + authentication.getName());
        return userRepo.findByEmail(email)
                .orElseThrow(() -> {
                    String errorMsg = "User not found with email: '" + email + "'";
                    System.out.println("DEBUG ERROR: " + errorMsg);
                    return new ResponseStatusException(HttpStatus.UNAUTHORIZED, errorMsg);
                });
    }

    private String generateOrderNumber() {
        return "ORD-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    @lombok.Data
    @lombok.AllArgsConstructor
    @lombok.NoArgsConstructor
    public static class OrderStatusUpdate {
        private OrderStatus status;
    }
}
