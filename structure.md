# Tokn App - Project Structure & Workflow

Yeh document aapke **Tokn App** ke pure structure, working workflow, use hue tools aur API's ki detail information deta hai.

---

## 1. Tech Stack & Tools Used 🛠️

### **Frontend (Mobile App)**
*   **Framework:** Flutter (Dart)
*   **State Management:** `setState` (Basic) & `shared_preferences` (Local Storage)
*   **API Calling:** `http` package
*   **Security:** `flutter_secure_storage` (JWT Token save karne ke liye)
*   **UI/Design Tools:** 
    *   `google_fonts` (Custom Typography ke liye)
    *   `cupertino_icons` & `font_awesome_flutter` (Icons ke liye)
    *   `flutter_staggered_animations` (Beautiful UI animations ke liye)
*   **Other:** `google_sign_in`, `flutter_facebook_auth` (Social Login ke liye), `permission_handler`

### **Backend (API Server)**
*   **Environment:** Node.js
*   **Framework:** Express.js
*   **Database:** MongoDB
*   **ODM (Object Data Modeling):** Mongoose
*   **Security & Auth:** 
    *   `jsonwebtoken` (JWT based authentication ke liye)
    *   `bcryptjs` (Password encrypt/hash karne ke liye)
    *   `cors` (Cross-Origin requests handle karne ke liye)
*   **Hosting/Deployment:** Render (Free Tier)

---

## 2. Folder & File Structure 📂

### **Frontend (`/lib`) - Flutter**
*   `main.dart`: App ka entry point.
*   **Pages (Screens):**
    *   `home_page.dart`: Main dashboard jahan hospitals ki list dikhti hai.
    *   `login_page.dart`: User login screen.
    *   `signup_page.dart`: Naya account create karne ki screen.
    *   `otp_verification_page.dart`: OTP enter karne ki screen.
    *   `forgot_password_page.dart`: Password reset page.
    *   `hospital_details_page.dart`: Kisi hospital ki puri details aur booking page.
    *   `my_bookings_page.dart`: User ki apni appointments/bookings dekhne ka page.
*   **Services:**
    *   `services/api_service.dart`: Yeh file backend se communicate karti hai. Isme saare HTTP requests (GET, POST) likhe hain. 60-second timeout ke sath.
*   **Widgets:**
    *   `widgets/animation_utils.dart`: App me use hone wale custom animations.

### **Backend (`/backend`) - Node.js**
*   `server.js`: Backend ka main server file.
*   `.env`: Secret keys (Database URI, JWT_SECRET, Port) store karne wali file.
*   **Controllers (`/controllers`):** (Logic yahan likha jata hai)
    *   `authController.js`: Signup, Login, OTP verification ka logic.
    *   `hospitalController.js`: Hospitals ka data bhejne ka logic.
    *   `bookingController.js`: Booking create aur fetch karne ka logic.
*   **Models (`/models`):** (Database ka structure)
    *   `User.js`: User ka schema (Name, Email, Phone, Password, OTP).
    *   `Hospital.js`: Hospital ka schema.
    *   `Booking.js`: Appointment/Booking ka schema.
*   **Routes (`/routes`):** (API Endpoints define hote hain)
    *   `authRoutes.js`, `hospitalRoutes.js`, `bookingRoutes.js`

---

## 3. APIs Used 🌐

**Base URL:** `https://tokn-backend.onrender.com/api`

### **Authentication APIs (`/auth`)**
1.  **POST `/auth/signup`**
    *   *Work:* Naya user create karna. (Name, Email, Phone, Password leta hai).
2.  **POST `/auth/login`**
    *   *Work:* Email/Phone aur Password ke through login karna aur JWT Token return karna.
3.  **POST `/auth/send-otp`**
    *   *Work:* OTP bhejna. (Abhi testing ke liye console me ja raha hai).
4.  **POST `/auth/verify-otp`**
    *   *Work:* OTP check karna. (Abhi testing ke liye **koi bhi 4-digit number** accept kar raha hai).
5.  **GET `/auth/me`**
    *   *Work:* Current login user ki profile details lana.

### **Hospital APIs (`/hospitals`)**
6.  **GET `/hospitals`**
    *   *Work:* Database se saare hospitals ki list lana.

### **Booking APIs (`/bookings`)**
7.  **POST `/bookings`**
    *   *Work:* Nayi booking create karna (Hospital ID, Date, Time ke sath).
8.  **GET `/bookings`**
    *   *Work:* Sirf usi user ki bookings lana jo abhi login hai.

---

## 4. App Working Workflow 🔄

1.  **Start/Launch:** User app kholta hai.
2.  **Signup Flow:** 
    *   Agar user naya hai, toh woh `SignupPage` par details fill karta hai.
    *   Details backend par jati hain (`/auth/signup`).
    *   User `OtpVerificationPage` par jata hai.
    *   User koi bhi 4 numbers dalta hai (`/auth/verify-otp`), backend use pass kar deta hai.
3.  **Login Flow:**
    *   User apna Email ya Phone Number aur password dalta hai (`/auth/login`).
    *   Backend JWT Token deta hai, jise Flutter app `flutter_secure_storage` me save kar leta hai.
4.  **Home Page (Dashboard):**
    *   Login successful hone ke baad user `HomePage` par aata hai.
    *   App `/hospitals` API call karta hai aur hospitals ki list dikhata hai.
5.  **Hospital Booking Flow:**
    *   User kisi hospital par click karta hai -> `HospitalDetailsPage` khulta hai.
    *   User Date aur Time select karke "Book Appointment" par click karta hai.
    *   App `/bookings` (POST) API call karta hai aur backend me appointment save ho jati hai.
6.  **My Bookings:**
    *   User apne "Bookings" tab ya `MyBookingsPage` me jata hai.
    *   App `/bookings` (GET) API call karta hai aur user ko uske saare confirmed appointments dikha deta hai.

---
**Note:** App me Render ke "Cold Start" (server sleep) ki wajah se API requests me 60-seconds ka timeout set kiya gaya hai taaki server ko wake up hone ka pura time mil sake.
