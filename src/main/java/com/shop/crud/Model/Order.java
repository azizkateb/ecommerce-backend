package com.shop.crud.Model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Entity
@Data
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    private Date date;

    private String orderNumber; // Unique order reference

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> items;

    // Shipping Information (directly in orders table) - Optional until checkout
    private String fullName;

    private String address;

    @Pattern(regexp = "^[0-9+\\-\\s()]*$", message = "Phone number is invalid")
    private String phone;

    private Long shippingInfoId;

    // Payment Information
    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    // Order Status
    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.PENDING;

    // Total Price
    private double totalPrice;

    // Calculate total price from items
    public void calculateTotalPrice() {
        if (items != null && !items.isEmpty()) {
            this.totalPrice = items.stream()
                    .mapToDouble(item -> item.getPrice() * item.getQuantity())
                    .sum();
        } else {
            this.totalPrice = 0.0;
        }
    }
}