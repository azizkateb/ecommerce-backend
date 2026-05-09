package com.shop.crud.Repo;

import org.springframework.data.jpa.repository.JpaRepository;

import com.shop.crud.Model.Order;
import com.shop.crud.Model.OrderStatus;
import com.shop.crud.Model.User;
import java.util.List;
import java.util.Optional;

public interface OrderRepo extends JpaRepository<Order, Long> {
    List<Order> findByUser(User user);
    List<Order> findByStatus(OrderStatus status);
    List<Order> findByUserAndStatus(User user, OrderStatus status);
    Optional<Order> findByOrderNumber(String orderNumber);
}
