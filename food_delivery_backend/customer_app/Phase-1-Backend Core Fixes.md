# Phase 1: Backend Core Fixes (Customer App)

## 1. Authentication Flow (OTP Based)

### Tasks:
- [ ] Implement OTP expiry time (e.g., 5 mins).
- [ ] Add resend limit (e.g., 1 min after expiry).
- [ ] Remove unused password field from Customer model.
- [ ] Ensure JWT tokens are issued on successful verification.

---

## 2. Fetching Data (Home Screen)

### Tasks:
- [ ] Implement pagination for the restaurant list.
- [ ] Add "open/closed" status to the restaurant model.
- [ ] Modify API to support the new status and pagination features.
- [ ] Implement location-based filtering for nearby restaurants.

---

## 3. Viewing Food Items (Restaurant Menu)

### Tasks:
- [ ] Add category grouping (e.g., starters, main course) for food items.
- [ ] Modify the API to return grouped categories.

---

## 4. Cart Management

### Tasks:
- [ ] Add/update/remove items from the cart.
- [ ] Implement `update-cart/` and `remove-from-cart/` endpoints.

---

## 5. Placing Order

### Tasks:
- [ ] Implement stock availability check before placing the order.
- [ ] Implement validation for the cart before placing the order.
- [ ] *(Optional)* Integrate payment gateway for online payments.

---

## 6. Profile Management (Missing)

### Tasks:
- [ ] Create `/api/customer/profile/` endpoint to view and update profile.
- [ ] Implement the necessary frontend to handle profile view and updates.

---

## 7. Address Management (Missing)

### Tasks:
- [ ] Create `/api/customer/address/` endpoint to manage delivery addresses.
- [ ] Implement address management UI for adding/editing/deleting addresses.

---

## 8. Order History (Missing)

### Tasks:
- [ ] Implement `/api/customer/orders/` endpoint to retrieve order history.
- [ ] Implement order history screen on the frontend.

---

## 9. Missing Backend Endpoints (Required for Frontend Features)

### Tasks:
- [ ] Implement `/api/customer/banners/` endpoint to serve banner data.
- [ ] Implement `/api/customer/top-rated-restaurants/` endpoint with rating-based sort.
- [ ] Implement `/api/customer/categories/` endpoint to list restaurant/food categories.
- [ ] Implement `/api/customer/search/` endpoint supporting name, location, category.

---

## Execution Plan - Phase 1: Backend Core Fixes
- [ ] Add OTP expiry and resend limit logic.
- [ ] Add pagination and status fields to the restaurant model.
- [ ] Implement food item category grouping.
- [ ] Implement cart item update and removal endpoints.
- [ ] Add stock check before placing orders.
- [ ] Create profile and address management APIs.
- [ ] Build Order History endpoint.
- [ ] Build missing endpoints: Banners, Top Rated, Categories, Search.
