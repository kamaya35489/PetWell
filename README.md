# 🐾 PetWell v3

## Setup in 3 steps

### 1. Add Firebase Config
Open `firebase.js` and replace the 6 placeholder values:
- Firebase Console → ⚙️ Project Settings → Your apps → Web app → SDK setup

### 2. Enable Firebase Services
- Authentication → Email/Password ✅
- Firestore Database → Test mode ✅

Firestore Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Run (for CCTV only)
```bash
npm install && node server.js
```
Open http://localhost:3000

> All pages except CCTV work by opening HTML files directly in a browser.

## Pages
| File | Description |
|------|-------------|
| index.html | Landing — role selector |
| ownerlogin.html | Owner login/register |
| ownerdash.html | Owner dashboard (matches screenshot) |
| mypets.html | My pets |
| ownerbookings.html | Book appointments |
| petOwnershop.html | Shop + cart |
| mydeliveries.html | Track orders |
| ownerfeedback.html | Leave reviews |
| adminlogin.html | Admin login |
| admindash.html | Admin dashboard |
| adminpets.html | Pet management |
| adminbookings.html | Booking management |
| adminstore.html | Product management |
| admindelivery.html | Delivery tracking |
| adminfeedback.html | Reviews management |
| admincctv.html | CCTV monitor |
| sender.html | Phone camera sender |

## Design
- **Colors:** Teal (#1a4f72) header + Light blue (#e8f4fd) background + White cards
- **Font:** Plus Jakarta Sans
- **Navigation:** Bottom nav bar (owner) + Sidebar (admin desktop)
- **Back buttons:** All inner pages have ‹ back button in header
