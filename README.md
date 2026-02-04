# ShopSphere - E-Commerce App

ShopSphere is a full-featured, modern e-commerce mobile application built with **Flutter** and **Supabase**. It provides a seamless shopping experience for customers and a robust management system for admins.

## 🚀 Features

- **Authentication**: Secure signup and login using Supabase Auth.
- **Product Management**: Browse products by categories, search, and view detailed descriptions.
- **Cart & Wishlist**: Add items to your cart or save them for later in your wishlist.
- **Order System**: Real-time order tracking and history.
- **Reviews & Ratings**: Users can leave reviews and rate products.
- **Admin Dashboard**: Specialized roles for managing products, categories, and orders.
- **Theming**: Support for both Light and Dark modes.
- **Smooth Animations**: Powered by `flutter_animate`.

## 🛠️ Tech Stack

- **Frontend**: Flutter
- **Backend/Database**: Supabase (PostgreSQL)
- **State Management**: Riverpod (Generator)
- **Navigation**: GoRouter
- **Persistence**: Shared Preferences
- **Image Handling**: Cached Network Image
- **PDF Generation**: `pdf` & `printing` for invoices/reports.

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.4 or higher)
- [Supabase Account](https://supabase.com/)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Rogersho/e_commerce-app.git
    cd ecommerce_poco
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate code**:
    Since the project uses `freezed` and `riverpod_generator`, run the following command to generate the necessary files:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

### Backend Setup (Supabase)

1.  Create a new project on [Supabase](https://supabase.com/).
2.  Navigate to the **SQL Editor** in your Supabase dashboard.
3.  Copy the contents of `supabase/schema.sql` and run it to set up the database tables, functions, and RLS policies.
4.  Enable **Email/Password** authentication in the **Auth > Providers** section.
5.  Get your **Project URL** and **Anon Key** from **Project Settings > API**.
6.  Update the credentials in `lib/core/constants/supabase_constants.dart`:

    ```dart
    class SupabaseConstants {
      static const String url = 'YOUR_SUPABASE_URL';
      static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
    }
    ```

### Running the App

1.  Ensure you have an emulator running or a physical device connected.
2.  Run the application:
    ```bash
    flutter run
    ```

## 📂 Project Structure

- `lib/core`: Global themes, constants, and utilities.
- `lib/features`: Feature-based architecture (auth, cart, product, order, etc.).
- `lib/features/*/presentation`: UI screens and controllers (Riverpod).
- `lib/features/*/domain`: Entity models.
- `lib/features/*/data`: Repositories and data sources.
- `supabase/`: Database schema and migrations.

## 📄 License

This project is open-source and available under the MIT License.
