# PetWell - Firebase Firestore Database

## Project Details
- **Project Name:** PetWell
- **Firebase Project ID:** petwell-24602
- **Database Type:** Cloud Firestore
- **Location:** asia-southeast1 (Singapore)

---

## Database Collections & Structure

### 1. `users`
Stores all registered users (pet owners and delivery agents)

```json
{
  "userID": "auto-generated",
  "userName": "John Silva",
  "email": "john@example.com",
  "phone": "0771234567",
  "role": "petOwner",
  "age": "25",
  "address": "123 Main St, Colombo"
}
```

---

### 2. `petOwners`
Stores pet owner profile details

```json
{
  "ownerID": "owner001",
  "userID": "auto-generated",
  "address": "123 Main St, Colombo",
  "petIDs": []
}
```

---

### 3. `owners`
Stores pet owner profiles registered via web app

```json
{
  "ownerID": "owner001",
  "uid": "auto-generated",
  "name": "John Silva",
  "email": "john@example.com",
  "phone": "0771234567",
  "role": "owner",
  "createdAt": "timestamp"
}
```

---

### 4. `drivers`
Stores delivery driver profiles (added by admin via web)

```json
{
  "driverID": "driver001",
  "uid": "auto-generated",
  "name": "Saman Fernando",
  "phone": "0712345678",
  "nic": "200012345678",
  "license": "B1234567",
  "vehicleType": "Motorcycle",
  "vehicleNo": "WP CAB-1234",
  "email": "saman@petwell.lk",
  "address": "45 High Level Rd",
  "role": "delivery",
  "status": "Active",
  "currentOrder": null,
  "totalDeliveries": 0,
  "notes": ""
}
```

---

### 5. `daycareCaretakers`
Stores daycare staff profiles

```json
{
  "staffID": "staffUID001",
  "userID": "auto-generated",
  "address": "456 Park Rd, Kandy",
  "salary": 35000
}
```

---

### 6. `pets`
Stores pet profiles registered by owners

```json
{
  "petID": "pet001",
  "ownerID": "owner001",
  "name": "Buddy",
  "type": "Dog",
  "breed": "Labrador",
  "age": "3",
  "emoji": "🐶",
  "owner": "John Silva",
  "address": "123 Main St, Colombo",
  "contact": "0771234567",
  "allergies": "None",
  "medical": "Vaccinated 2024"
}
```

---

### 7. `bookings`
Stores service booking appointments

```json
{
  "bookingID": "booking001",
  "ownerID": "owner001",
  "service": "Grooming",
  "date": "2026-03-15T00:00:00",
  "time": "9:00 AM",
  "status": "confirmed",
  "paymentID": "payment001"
}
```

---

### 8. `orders`
Stores shop orders placed by pet owners

```json
{
  "orderID": "order001",
  "userID": "auto-generated",
  "orderDate": "2026-03-13T00:00:00",
  "totalAmount": 3500,
  "status": "Processing",
  "paymentID": "payment001",
  "deliveryID": "delivery001",
  "driverID": "driver001",
  "driverName": "Saman Fernando",
  "driverPhone": "0712345678"
}
```

---

### 9. `deliveries`
Stores delivery tracking information

```json
{
  "deliveryID": "delivery001",
  "orderID": "order001",
  "driverID": "auto-generated",
  "driverName": "Saman Fernando",
  "driverPhone": "0712345678",
  "driverVehicle": "Motorcycle",
  "product": "Premium Dog Food",
  "ownerName": "John Silva",
  "address": "123 Main St, Colombo",
  "contact": "0771234567",
  "status": "Accepted",
  "acceptedAt": "2026-03-16T00:00:00"
}
```

---

### 10. `payments`
Stores payment transaction records

```json
{
  "paymentID": "payment001",
  "amount": 1500,
  "method": "Card",
  "paymentDate": "2026-03-13T00:00:00",
  "status": "completed"
}
```

---

### 11. `products`
Stores pet store product listings

```json
{
  "productID": "product001",
  "name": "Premium Dog Food",
  "description": "High-protein formula for active dogs",
  "price": 1000,
  "emoji": "🦴",
  "stock": 50,
  "category": "Food"
}
```

---

### 12. `feedback`
Stores user reviews and ratings

```json
{
  "feedbackID": "feedback001",
  "userID": "auto-generated",
  "userName": "John Silva",
  "rating": 5,
  "comment": "Great service!",
  "date": "2026-03-13T00:00:00",
  "status": "submitted"
}
```

---

### 13. `carts`
Stores shopping cart data

```json
{
  "cartID": "cart001",
  "ownerID": "auto-generated",
  "subtotal": 4600,
  "deliveryFee": 150,
  "total": 4750,
  "paymentMethod": "Card",
  "status": "active",
  "createdAt": "2026-03-21T00:00:00"
}
```

#### Sub-collection: `cartItems`
```json
{
  "itemID": "PremiumDogFood",
  "productName": "Premium Dog Food",
  "price": 1000,
  "quantity": 1
}
```

---

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /petOwners/{ownerID} {
      allow read, write: if request.auth != null;
    }
    match /owners/{ownerID} {
      allow read, write: if request.auth != null;
    }
    match /daycareCaretakers/{staffID} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == staffID;
    }
    match /pets/{petID} {
      allow read, write: if request.auth != null;
    }
    match /bookings/{bookingID} {
      allow read, write: if request.auth != null;
    }
    match /orders/{orderID} {
      allow read, write: if request.auth != null;
    }
    match /deliveries/{deliveryID} {
      allow read, write: if request.auth != null;
    }
    match /payments/{paymentID} {
      allow read, write: if request.auth != null;
    }
    match /carts/{cartID} {
      allow read, write: if request.auth != null;
      match /cartItems/{itemID} {
        allow read, write: if request.auth != null;
      }
    }
    match /products/{productID} {
      allow read, write: if request.auth != null;
    }
    match /feedback/{feedbackID} {
      allow read, write: if request.auth != null;
    }
    match /drivers/{driverID} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Collections Summary

| # | Collection | Purpose | Document ID Format |
|---|---|---|---|
| 1 | `users` | All users | Firebase Auth UID |
| 2 | `petOwners` | Pet owner profiles | owner001, owner002... |
| 3 | `owners` | Web app owners | owner001, owner002... |
| 4 | `drivers` | Delivery drivers | driver001, driver002... |
| 5 | `daycareCaretakers` | Staff profiles | staffUID |
| 6 | `pets` | Pet profiles | pet001, pet002... |
| 7 | `bookings` | Appointments | booking001, booking002... |
| 8 | `orders` | Shop orders | order001, order002... |
| 9 | `deliveries` | Delivery tracking | delivery001, delivery002... |
| 10 | `payments` | Payments | payment001, payment002... |
| 11 | `products` | Store products | product001, product002... |
| 12 | `feedback` | User reviews | feedback001, feedback002... |
| 13 | `carts` | Shopping cart | cart001, cart002... |

---

## Connected Platforms
- Mobile App: Flutter (Android and iOS)
- Web Application: HTML, CSS, JavaScript
- Backend: Node.js
