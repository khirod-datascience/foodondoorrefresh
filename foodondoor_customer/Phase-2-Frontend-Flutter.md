# Phase 2: Frontend Flutter Tasks (Customer App)

## 1. Authentication Flow

### Tasks:
- [ ] Modify OTP login screen to handle OTP expiry (e.g., 5 min expiry).
- [ ] Implement a countdown timer on the OTP screen for resend limit.
- [ ] Show a proper error message when OTP expires or fails.
- [ ] Store JWT token securely using `flutter_secure_storage`.

---

## 2. Profile Management

### Tasks:
- [ ] Create "Profile" screen to display customer information.
- [ ] Implement functionality to update the profile (e.g., name, email).
- [ ] Fetch customer details from `/api/customer/profile/` endpoint.
- [ ] Allow user to update profile using the backend API.

---

## 3. Address Management

### Tasks:
- [ ] Create "Add/Edit/Delete Address" screen.
- [ ] Fetch existing addresses from `/api/customer/address/` endpoint.
- [ ] Implement API to add/edit/delete addresses.

---

## 4. Cart Management

### Tasks:
- [ ] Update Cart screen to allow updating item quantity.
- [ ] Add "Remove" option for cart items.
- [ ] Update API to handle add, remove, and update cart item operations.

---

## 5. Order History

### Tasks:
- [ ] Implement "Order History" screen.
- [ ] Fetch past orders from `/api/customer/orders/` endpoint.
- [ ] Display details of previous orders (items, status, etc.).

---

## 6. Error Handling & UI Polish

### Tasks:
- [ ] Improve error handling across all screens.
- [ ] Show user-friendly error messages (e.g., "Failed to fetch data", "Order not placed").
- [ ] Implement "Loading" and "No Data" states for UI feedback.
- [ ] Apply consistent UI design for all screens.

---

## 7. Home Screen Features

### Tasks:
- [ ] Fetch and display promotional banners (`/api/customer/banners/`).
- [ ] Display nearby restaurants using location-based filtering.
- [ ] Show top-rated restaurants (`/api/customer/top-rated-restaurants/`).
- [ ] Display restaurant categories (`/api/customer/categories/`).
- [ ] Implement search functionality (`/api/customer/search/`).

---

## Execution Plan - Phase 2: Flutter Frontend
- [ ] Modify OTP login for expiry and resend handling.
- [ ] Create Profile screen and update functionality.
- [ ] Build Address Management screen (CRUD).
- [ ] Update Cart to allow item quantity update/remove.
- [ ] Build Order History screen.
- [ ] Improve Error handling (UI, API failures).
- [ ] Implement home screen features: Banners, Categories, Search, Top Rated, Nearby.
