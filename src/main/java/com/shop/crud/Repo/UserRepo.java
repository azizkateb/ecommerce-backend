package com.shop.crud.Repo;

import org.springframework.data.jpa.repository.JpaRepository;

import com.shop.crud.Model.User;
import java.util.Optional;

public interface UserRepo extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
