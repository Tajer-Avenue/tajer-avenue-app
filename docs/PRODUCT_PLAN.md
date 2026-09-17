# Tajer Avenue — Product Plan

## Marketplace model

Tajer Avenue is a multi-tenant digital marketplace for the UAE. It supports both product-based and service-based businesses and is designed to connect suppliers, sellers, buyers, projects, and services in one app.

## Merchant storefront

Each merchant receives an independent customizable store page with:

- Logo
- Cover image
- Brand colors
- Intro/video
- Products and/or services
- Prices
- Ratings and reviews
- Instagram
- WhatsApp
- Location
- Direct store link
- 3–5 store themes suited to the business type

## Customer discovery

Primary discovery surfaces:

- New Drops
- Trending
- Nearby
- Categories
- Search
- Featured stores
- Store pages

## Customer navigation

Initial customer flows:

1. Home
2. Categories
3. Stores
4. Store Page
5. Products / Services
6. Product / Service Details
7. Search
8. Favorites
9. Cart
10. Account

## Merchant navigation

Initial merchant flows:

1. Dashboard
2. My Store
3. Add Product / Service
4. Orders
5. Analytics
6. Subscription

## Technical direction

- Client: Flutter
- Backend: Supabase
- Repository: Tajer-Avenue/tajer-avenue-app

## Delivery phases

### Phase 1 — App foundation

- Centralized brand and theme tokens
- Feature-based Flutter structure
- Customer shell and working navigation
- Mock catalog, local search, favorites, stores, and cart entry point

### Phase 2 — Supabase foundation

- Development and production environments
- Authentication and user profiles
- Database schema, storage buckets, and row-level security
- Repository/data layer and error handling

### Phase 3 — Customer commerce

- Store, product, and service detail flows
- Shared multi-store cart
- Checkout, addresses, UAE delivery rules, and payments
- Orders, reviews, notifications, and deep links

### Phase 4 — Merchant system

- Merchant onboarding and automatic storefront creation
- Store themes and customization
- Product/service management, inventory, orders, and analytics
- Subscription plans and merchant billing

### Phase 5 — Release readiness

- Arabic and English localization
- Accessibility, analytics, crash reporting, tests, and performance
- Legal name review, privacy/terms, App Store and Play Store release

## Development principle

Build Tajer Avenue independently. Do not couple this repository to the DEV Website project.

The working name, logo, colors, and customer-facing copy must remain centralized
and replaceable until the final legal review is complete.
