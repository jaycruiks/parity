# Mural Pay Merchant Checkout - Implementation Plan

## Overview
A Rails application that allows customers to purchase products and pay with USDC on Polygon, with automatic conversion to COP and withdrawal to a Colombian bank account via the Mural Pay API.

## Core Features
1. Product catalog with items for sale
2. Guest checkout flow
3. USDC payment collection (via Mural Pay API)
4. Payment detection and status display
5. Auto-conversion USDC → COP and bank transfer
6. Admin interface for products, orders, and withdrawal status
7. Inventory tracking

---

## Rails Setup

### Ruby & Rails Versions
- Ruby 3.4.8
- Rails 8.x (latest)

### Database
- PostgreSQL

### Background Jobs & Caching
- `solid_queue` - Database-backed job processing (Rails 8 default)
- `solid_cache` - Database-backed caching
- No Redis required

---

## Gems & Tooling

### Core
- `pg` - PostgreSQL adapter
- `faraday` - HTTP client for Mural Pay API calls

### Admin Interface
- `administrate` or `rails_admin` - Quick admin dashboard for products/orders

### Frontend
- `importmap-rails` - Rails 8 default for JS
- `tailwindcss-rails` - Styling
- `turbo-rails` / `stimulus-rails` - Hotwire for dynamic updates

### Development & Testing
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test fixtures
- `dotenv-rails` - Environment variable management (API keys)
- `webmock` / `vcr` - Mock external API calls in tests

### Optional
- `money-rails` - Currency handling
- `pagy` - Pagination

---

## Data Models

### Product
- name
- description
- price_cents (integer)
- inventory_count
- active (boolean)

### Order
- email
- shipping_address (or separate Address model)
- status (pending, payment_requested, paid, converting, withdrawn, failed)
- total_cents
- usdc_amount
- mural_payment_id (reference to Mural Pay)

### OrderItem
- order_id
- product_id
- quantity
- price_cents (snapshot at time of order)

### Withdrawal
- order_id
- mural_transfer_id
- amount_cop
- status (pending, processing, completed, failed)
- bank_account_info (or reference)

---

## Mural Pay API Integration

### Key Endpoints (to research in sandbox docs)
- Create payment request (get USDC deposit address/amount)
- Check payment status
- Initiate conversion (USDC → COP)
- Initiate withdrawal to bank account
- Check withdrawal status

### Integration Pattern
1. Wrap API calls in a `MuralPay::Client` service class
2. Use solid_queue jobs for:
   - Polling payment status
   - Triggering conversion on payment confirmation
   - Polling withdrawal status
3. Webhook support if Mural Pay provides it (reduces polling)

---

## USDC Payment Matching - Known Pitfalls

Since USDC payments happen externally:
- Cannot guarantee 1:1 matching if customer sends wrong amount
- Multiple orders with same amount could be ambiguous
- Network delays may cause timing issues

Potential mitigations:
- Use unique amounts per order (add cents variation)
- Time-window matching
- Manual reconciliation fallback in admin

Document these limitations in README.

---

## Deployment

### Heroku
- Heroku PostgreSQL add-on for database
- Procfile for web and worker processes
- Environment variables for Mural Pay API keys
- `rails_12factor` gem (if needed for Rails 8)

### Procfile
```
web: bin/rails server -p $PORT
worker: bin/jobs
```

---

## Next Steps

1. `rails new` with PostgreSQL
2. Add core gems to Gemfile
3. Generate models (Product, Order, OrderItem, Withdrawal)
4. Set up Mural Pay API client service
5. Build basic product catalog UI
6. Build checkout flow
7. Integrate payment creation with Mural Pay
8. Add background jobs for payment polling
9. Add auto-conversion and withdrawal logic
10. Build admin interface
11. Write tests