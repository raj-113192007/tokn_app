# TOKN APP - COMPLETE AUDIT REPORT

This document contains a comprehensive audit of the TOKN app, comparing the current implementation with the requested requirements.

---

## PART 1 - SCREEN BY SCREEN BREAKDOWN

### 1. Splash Screen (`splash_screen.dart`)
- **Screen Name**: `SplashScreen`
- **Buttons**: None (Automatic transition after animation/permission check).
- **Inputs**: None.
- **Lists/Cards**: None.
- **Logic**: 
  - Plays a scale and fade animation for the TokN logo.
  - Requests essential permissions: Location, Notification, and Phone.
  - Next Screen: `WelcomePage`.

### 2. Welcome Page (`welcome_page.dart`)
- **Screen Name**: `WelcomePage`
- **Buttons**:
  - **Sign In**: Navigates to `LoginPage`.
  - **Sign Up**: Navigates to `SignupPage`.
  - **Social Buttons**: Google Sign-In, Facebook Sign-In (integrated with services), Gmail (placeholder).
- **Inputs**: None.
- **Lists/Cards**: None.
- **Logic**: Initial entry point with branding and primary authentication options.
- **Next Screen**: `LoginPage` or `SignupPage`.

### 3. Login Page (`login_page.dart`)
- **Screen Name**: `LoginPage`
- **Buttons**:
  - **Back**: Returns to `WelcomePage`.
  - **Forgot Password?**: Navigates to `ForgotPasswordPage`.
  - **Sign in**: Validates inputs and calls `ApiService.login`.
  - **Sign in with OTP**: Calls `ApiService.sendOtp` and navigates to `LoginOtpPage`.
  - **Password Visibility**: Toggles password masking.
- **Inputs**: 
  - "Email or Mobile Number" field.
  - "Password" field.
- **Logic**: Detects if input is phone (10 digits) or email. Enables login button only when valid.
- **Next Screen**: `HomePage` (on success) or `LoginOtpPage`.

### 4. Signup Page (`signup_page.dart`)
- **Screen Name**: `SignupPage`
- **Buttons**:
  - **Back**: Returns to `WelcomePage`.
  - **Verify OTP**: Validates form and calls `ApiService.signup`.
- **Inputs**: Full Name, Email, Phone Number, Password, Confirm Password.
- **Logic**: Client-side validation for email format, 10-digit phone, and 8+ char password with symbols.
- **Next Screen**: `OtpVerificationPage`.

### 5. OTP Verification Page (`otp_verification_page.dart`)
- **Screen Name**: `OtpVerificationPage`
- **Buttons**:
  - **Change?**: Returns to `SignupPage`.
  - **Confirm (Phone/Email)**: Verifies respective OTPs.
  - **Resend Code**: Retriggers OTP send.
  - **GO TO HOME**: Enabled only after both Phone and Email are verified.
- **Inputs**: 4-digit OTP fields for Phone and Email.
- **Logic**: Handles dual verification logic.
- **Next Screen**: `HomePage`.

### 6. Home Screen (`home_page.dart`)
- **Screen Name**: `HomePage`
- **Buttons**:
  - **Location/City Picker**: Opens bottom sheet to select city.
  - **Notification Bell**: Animated bell icon (placeholder).
  - **Hospital Cards**: Clickable cards navigating to details.
  - **Category Cards**: Search by category (Headache, Derma, etc.).
  - **Bottom Navigation**: Home, Bookings, Chat, Profile.
- **Inputs**: Search Bar (Category or Name).
- **Lists/Cards**: 
  - Banner Carousel.
  - Horizontal list of Hospitals.
  - Horizontal list of Categories.
  - Horizontal list of Recently Visited hospitals.
- **Logic**: Main dashboard for exploring clinics and navigating the app.
- **Next Screen**: `HospitalDetailsPage`.

### 7. Hospital Detail Screen (`hospital_details_page.dart`)
- **Screen Name**: `HospitalDetailsPage`
- **Buttons**:
  - **Directions**: Placeholder (Intent to open Maps).
  - **Specialty Chips**: Quick filters.
  - **Doctor Cards**: Static list of doctors.
  - **Book Token Now**: **CRITICAL** - Currently creates a booking immediately via API and shows a success dialog.
- **Inputs**: None.
- **Lists/Cards**: Specialty list, Doctors list, Services grid.
- **Logic**: Displays hospital info, rating, and allows booking.
- **Next Screen**: Shows a confirmation Dialog with Token Number.

### 8. My Bookings Screen (`my_bookings_page.dart`)
- **Screen Name**: `MyBookingsPage`
- **Buttons**:
  - **Tabs**: Upcoming, Completed, Cancelled.
  - **Directions** (in card): Placeholder.
  - **Rebook/Retry**: Placeholder.
- **Inputs**: None.
- **Lists/Cards**: Booking cards with Hospital name, Token number, Doctor, and Time.
- **Logic**: Fetches user's booking history and updates the Home Screen Widget.
- **Next Screen**: (Part of Home Page PageView).

### 9. Messages/Chat Screen (`messages_page.dart`)
- **Screen Name**: `MessagesPage`
- **Buttons**:
  - **Edit Note**: Placeholder.
  - **Chat Items**: Clickable placeholders for conversations.
- **Inputs**: Search field for chats.
- **Lists/Cards**: List of recent messages with online status and unread counts.
- **Logic**: Filtered to show reception/hospital chats.
- **Next Screen**: (Actual individual chat screen is missing).

### 10. Profile Screen (`profile_page.dart`)
- **Screen Name**: `ProfilePage`
- **Buttons**:
  - **Settings**: Navigates to `SettingsPage`.
  - **Add Family Member**: Navigates to `AddMemberPage`.
  - **Add Money**: Wallet recharge (placeholder).
- **Inputs**: None.
- **Lists/Cards**: 
  - Info cards (Age, Blood Group, Tokens Booked, Unique ID).
  - Wallet balance and transaction history.
  - Ayushman Card mockup.
- **Logic**: General user overview.
- **Next Screen**: `SettingsPage`, `AddMemberPage`.

### 11. Other Screens
- **SettingsPage**: App Lock toggle, Language selection, Biometric toggle, Manage Family link.
- **FamilyMembersPage**: List of family members with Edit/Delete options.
- **AddMemberPage**: Form to add name, relation, and access level.
- **EditProfilePage**: Form to update personal details.
- **CompleteProfilePage**: Stepper-like form to finalize profile.

---

## PART 2 - MISSING FEATURES CHECK

### [PATIENT APP]
1.  **Splash Screen**: ✅ (Implemented with animations and permission requests).
2.  **Onboarding screens**: ❌ **MISSING**. Only `WelcomePage` exists. No multi-slide onboarding flow.
3.  **Sign Up**: ✅ (Name, phone, email, password, OTP validation implemented).
4.  **Sign In**: ✅ (Implemented with Phone/Email + Password + OTP options).
5.  **Home Screen**: 
    - Hospital list: ✅
    - Category filter: ✅
    - Search bar: ✅
6.  **Hospital Detail Screen**:
    - Hospital image, About, Address: ✅
    - Rating + review count: ⚠️ (Review count missing).
    - Disease types: ⚠️ (Only generic specialties).
    - Doctors list: ✅ (Static UI).
    - Directions button: ⚠️ (UI exists but doesn't open Google Maps).
    - Book Token: ⚠️ (Direct button, lacks dedicated selection screen).
7.  **Token Booking Screen**: ❌ **MISSING**. Currently, there is NO screen to Select Doctor, Select Token Type (Normal/Emergency), or see Estimated Time Slots.
8.  **My Bookings Screen**:
    - Past/Upcoming: ✅
    - Live token tracker: ❌ **MISSING** (Crucial "current vs my number" logic).
    - Set alarm: ❌ **MISSING**.
    - PDF Download (Prescription/Bill): ❌ **MISSING**.
    - Rate hospital: ❌ **MISSING**.
9.  **Wallet Screen**: ⚠️ (Integrated into Profile, but lacks full transaction history and real recharge logic).
10. **Chat Screen**: ⚠️ (List exists, but Message Bubbles and Send Logic are MISSING).
11. **Profile Screen**: 
    - Basic fields: ✅
    - Family members (add/edit/delete): ✅ (In separate page).
    - App lock toggle: ✅ (In Settings).
    - Unique User ID: ✅
12. **Notifications Screen**: ❌ **MISSING**. Only a bell icon exists.
13. **Profile Completion Popup**: ❌ **MISSING**. (A card exists in Settings, but no global popup).

### [OTHER PANELS]
1.  **HOSPITAL RECEPTION PANEL**: ❌ **COMPLETELY MISSING**.
2.  **DOCTOR PANEL**: ❌ **COMPLETELY MISSING**.
3.  **PHARMACY PANEL**: ❌ **COMPLETELY MISSING**.
4.  **SUPER ADMIN PANEL**: ❌ **COMPLETELY MISSING**.

---

## PART 3 - BACKEND REQUIREMENTS (PROPOSED)

| Feature | Endpoint | Method | Data Sent | Data Returned | Real-time? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Auth** | `/auth/signup` | POST | Name, Phone, Email, PW | User Obj + JWT | No |
| **OTP** | `/auth/send-otp` | POST | Phone/Email | Success msg | No |
| **Booking** | `/bookings/create` | POST | HospID, DocID, Type (Normal/Emergency) | Token #, Est. Time | **Yes** (Admin update) |
| **Queue** | `/hospitals/:id/queue` | GET | - | Live Queue Data | **Yes** (Socket.io) |
| **Wallet** | `/wallet/recharge` | POST | Amount, PaymentID | Updated Balance | No |
| **Chat** | `/chat/messages` | POST | RecipientID, Text | Message status | **Yes** (Socket.io/FCM) |
| **Prescription**| `/docs/prescription` | GET | BookingID | PDF URL | No |
| **Doctor Status**| `/admin/doctor/status`| PUT | DoctorID, Status | Success msg | **Yes** (Live toggle) |

---

## PART 4 - DATABASE SCHEMA (PROPOSED)

- **Users**: `id, name, email, phone, role (Patient/Doc/Reception/Admin), profile_pic, wallet_balance, family_ids[]`
- **Hospitals**: `id, name, address, location (Lat/Lng), image_url, specialties[], rating, reviews_count`
- **Doctors**: `id, hospital_id, name, specialty, availability_status, patient_limit, fee_per_token`
- **Bookings**: `id, user_id, hospital_id, doctor_id, token_number, type (Normal/Emergency), status (Pending/In-Progress/Completed/Cancelled), estimated_time, date`
- **Transactions**: `id, user_id, type (Credit/Debit), amount, status, date`
- **Messages**: `id, sender_id, receiver_id, text, timestamp, is_read`
- **Prescriptions**: `id, booking_id, doctor_id, patient_id, diagnosis, medicines (JSON), notes, file_url`

---

## PART 5 - THIRD PARTY INTEGRATIONS

1.  **Payment Gateway**: **Razorpay** (Wallet recharge and token payment).
2.  **OTP Service**: **Firebase Phone Auth** or **MSG91** (Global coverage).
3.  **Push Notifications**: **Firebase Cloud Messaging (FCM)**.
4.  **WhatsApp Notifications**: **Twilio** or **WATI API** (For token confirmation/reminders).
5.  **PDF Generation**: `pdf` package (Flutter) and `Puppeteer` (Backend-side for high-quality).
6.  **Cloud Storage**: **Cloudinary** or **AWS S3** (Images and PDFs).
7.  **Maps**: **Google Maps SDK** (Directions and Hospital locations).
8.  **Real-time Logic**: **Socket.io** (For Live Queue tracking and Chat).

---

## PART 6 - TECH STACK RECOMMENDATION

For a highly scalable, real-time healthcare app with multiple complex roles:

1.  **Language**: **Node.js (TypeScript)** for the backend.
2.  **Framework**: **Express.js** or **NestJS** (Highly modular).
3.  **Database**: **PostgreSQL** (Relational data like hospital-doctor-booking is better served here) or **MongoDB** (If chat logs are massive). **Prisma** as ORM.
4.  **Real-time**: **Socket.io** for Bi-directional communication (Live Queue).
5.  **Cache**: **Redis** (To store high-traffic live token numbers).
6.  **Infrastructure**: **Docker** containers on **AWS (EC2/RDS)** or **Google Cloud**.
7.  **Auth**: **JWT (JSON Web Tokens)** with Refresh Token rotation.

---

**AUDITOR'S NOTE**: 
The current app has a beautiful UI and a solid animation foundation, but it is currently a "Shell". Most critical business logic (Booking selection, Wallet, Tracker) and all administrative panels need to be built from scratch.
