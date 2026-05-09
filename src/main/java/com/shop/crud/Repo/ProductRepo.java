package com.shop.crud.Repo;

import org.springframework.data.jpa.repository.JpaRepository;

import com.shop.crud.Model.Product;

public interface ProductRepo extends JpaRepository<Product, Long> {

}
