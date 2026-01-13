RentEase

Rental Management Application

A modern, cross-platform rental management application built with Flutter to simplify rental property management, billing, and communication between landlords and tenants using a role-based system.

📱 Overview

RentEase is designed to digitize and automate rental operations. The application separates workflows for landlords and tenants, ensuring clarity, security, and ease of use.

Objectives

Simplify rental and tenant management

Automate bill creation and tracking

Improve transparency between landlords and tenants

Provide a scalable and maintainable system

✨ Features
Landlord

Create and manage tenants

Generate monthly bills

Track paid and unpaid bills

View billing history

Dashboard overview

Tenant

View assigned bills

Track payment status

View billing history

Communicate with landlord

General

Email/password authentication

Role-based access (Landlord / Tenant)

Light and dark theme

Cross-platform support

🏗️ Architecture

The project follows Clean Architecture with Provider-based state management.

lib/
 ├── main.dart
 ├── models/
 │    ├── user.dart
 │    └── bill.dart
 ├── providers/
 │    ├── auth_provider.dart
 │    ├── bill_provider.dart
 │    └── theme_provider.dart
 ├── services/
 │    └── backend_service.dart
 ├── screens/
 │    ├── auth/
 │    ├── landlord/
 │    ├── tenant/
 │    └── common/
 ├── widgets/
 └── utils/

🛠️ Technology Stack

Flutter

Dart

Backend as a Service (Authentication & Database)

Provider (State Management)

Local Storage (Caching)

🚀 Project Setup Guide

(Clone, Configure & Run)

1️⃣ Clone the Project
git clone https://github.com/MAHABUB122003/RentEase_APP
cd RentEase

2️⃣ Verify Flutter Installation
flutter doctor


✔️ Make sure there are no critical errors
✔️ Chrome or Android emulator should be available

3️⃣ Install Dependencies
flutter pub get

4️⃣ Backend Configuration (Required)

The application requires authentication and database setup.

A. Authentication

Enable email/password authentication

Users register as Landlord or Tenant

B. Database Tables
users table
id (uuid, primary key)
email (text)
full_name (text)
phone (text)
role (text)
created_at (timestamp)

bills table
id (uuid, primary key)
tenant_id (uuid)
landlord_id (uuid)
amount (numeric)
month (text)
status (text)
created_at (timestamp)

C. Security

Enable Row Level Security (RLS)

Users can only read/write their own data

Tenants can only see their own bills

Landlords can only manage their tenants’ bills

5️⃣ Environment Initialization

Ensure backend is initialized before running the app.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_PROJECT_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(MyApp());
}

6️⃣ Run the Application
Web (Chrome)
flutter run -d chrome

Android
flutter run

💻 Application Workflow
Landlord Flow
Register as Landlord
      ↓
Add Tenants
      ↓
Create Monthly Bills
      ↓
Track Payments

Tenant Flow
Register as Tenant
      ↓
View Assigned Bills
      ↓
Check Payment Status

🗄️ Data Model (Conceptual)
User
id
email
full_name
phone
role
created_at

Bill
id
tenant_id
landlord_id
amount
month
status
created_at

🐛 Common Issues
App Not Running
flutter clean
flutter pub get
flutter run

Data Not Showing

Check database tables

Verify security rules

Confirm correct user role

JSON Error (Unexpected token '<')

Backend table missing

Permission (RLS) not configured

Wrong table name

📈 Future Enhancements

Online payment gateway

Bill reminders

Multi-property support

Maintenance request system

Analytics dashboard

Multi-language support

📄 License

This project is distributed under the MIT License.

👤 Author

MD Mahabubur Rahman
Bachelor of Science in Computer Science & Engineering
