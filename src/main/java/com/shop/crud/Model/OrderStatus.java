package com.shop.crud.Model;

public enum OrderStatus {
    PENDING("En Attente"),
    PROCESSING("En Traitement"),
    SHIPPED("Expédié"),
    DELIVERED("Livré"),
    CANCELLED("Annulé");

    private final String displayName;

    OrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
