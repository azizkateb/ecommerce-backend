package com.shop.crud.Model;

public enum PaymentMethod {
    CASH_ON_DELIVERY("Paiement à la Livraison"),
    BANK_TRANSFER("Virement Bancaire");

    private final String displayName;

    PaymentMethod(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
