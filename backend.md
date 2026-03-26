# TokN Backend Documentation & Change Log

This file tracks all changes, architectural decisions, and updates made to the TokN backend ecosystem.

## Project Overview
- **Tech Stack:** Flutter (Frontend), Supabase (Backend/Database).
- **Backend Provider:** Supabase (PostgreSQL + Auth + Real-time).
- **Hosting:** Supabase Cloud, Vercel (for Admin/Web).

## Project Configuration
- **Supabase URL:** `https://wmcyhvbwtqcroolbyozl.supabase.co`
- **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtY3lodmJ3dHFjcm9vbGJ5b3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0Mjc2NzQsImV4cCI6MjA5MDAwMzY3NH0.rtWprVrlFC940s889nbpFAfDFgCktd5XLAHkhXp5Xlk`

### 2026-03-25 - Flutter Integration
- [x] **Dependency Added:** Added `supabase_flutter: ^2.8.2` to `pubspec.yaml`.
- [x] **Initialization:** Initialized Supabase in `lib/main.dart` with Project URL and Anon Key.
- [x] **Service Layer Created:** Created `lib/services/supabase_service.dart` to handle:
    - User Profile fetching.
    - Real-time Token Streaming (Subscribing to live updates).
    - Token Booking logic.
    - Authentication (Sign out).

### 2026-03-25 - Phone Authentication Setup (Completed)
- [x] **Twilio Account:** Created and connected.
- [x] **Messaging Service SID:** Configured in Supabase.
- [x] **Supabase Provider:** Phone (Twilio) provider enabled.
- [x] **Flutter Implementation:** Integrated `signInWithOtp` and `verifyOTP` in `SupabaseService` and UI.



---
*Next Step: Complete Twilio configuration in Supabase Dashboard.*
