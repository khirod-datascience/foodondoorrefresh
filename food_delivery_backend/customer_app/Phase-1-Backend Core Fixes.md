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
- [x] Implement pagination for the restaurant list.
- [x] Add "open/closed" status to the restaurant model.
- [x] Modify API to support the new status and pagination features.
- [x] Implement location-based filtering for nearby restaurants.

---

## 3. Viewing Food Items (Restaurant Menu)

### Tasks:
- [x] Add category grouping (e.g., starters, main course) for food items.
- [x] Modify the API to return grouped categories.

---

## 4. Cart Management

### Tasks:
- [x] Add/update/remove items from the cart.
- [x] Implement `update-cart/` and `remove-from-cart/` endpoints.

---

## 5. Placing Order

### Tasks:
- [x] Implement stock availability check before placing the order.
- [x] Implement validation for the cart before placing the order.
- [ ] *(Optional)* Integrate payment gateway for online payments.

---

## 6. Profile Management (Missing)

### Tasks:
- [x] Create `/api/customer/profile/` endpoint to view and update profile.
- [ ] Implement the necessary frontend to handle profile view and updates.

---

## 7. Address Management (Missing)

### Tasks:
- [x] Create `/api/customer/address/` endpoint to manage delivery addresses.
- [ ] Implement address management UI for adding/editing/deleting addresses.

---

## 8. Order History (Missing)

### Tasks:
- [x] Implement `/api/customer/orders/` endpoint to retrieve order history.
- [ ] Implement order history screen on the frontend.

---

## 9. Missing Backend Endpoints (Required for Frontend Features)

### Tasks:
- [x] Implement `/api/customer/banners/` endpoint to serve banner data.
- [x] Implement `/api/customer/top-rated-restaurants/` endpoint with rating-based sort.
- [x] Implement `/api/customer/categories/` endpoint to list restaurant/food categories.
- [x] Implement `/api/customer/search/` endpoint supporting name, location, category.

---

## Execution Plan - Phase 1: Backend Core Fixes
- [ ] Add OTP expiry and resend limit logic.
- [ ] Add pagination and status fields to the restaurant model.
- [ ] Implement food item category grouping.
- [ ] Implement cart item update and removal endpoints.
- [ ] Add stock check before placing orders.
- [x] Create profile and address management APIs.
- [x] Build Order History endpoint.
- [x] Build missing endpoints: Banners, Categories, Search.
