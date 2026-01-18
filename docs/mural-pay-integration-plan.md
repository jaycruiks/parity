# Mural Pay Integration Plan

## Overview

Integrate Mural Pay API to enable USDC payments on Polygon blockchain with automatic conversion and withdrawal to Colombian Peso (COP) bank accounts.

## Progress Summary

### Completed ✅
- [x] MuralPay API clients (in `app/clients/mural_pay/`)
- [x] Database migrations (orders, payments, withdrawals, merchant_settings)
- [x] Payment model with order association
- [x] MerchantSetting model (singleton)
- [x] Order model with unique deposit amount generation
- [x] OrdersController with payment flow and status endpoint
- [x] Order show view with payment instructions UI
- [x] Admin dashboards (Order, Payment, MerchantSetting)
- [x] Routes (webhooks, payment_status, admin resources)
- [x] Webhook controller (basic structure)

### Remaining ❌
- [x] ProcessPaymentJob - match incoming transactions to orders
- [x] PollTransactionsJob - background polling for payments
- [x] InitiatePayoutJob - trigger COP payout when paid
- [x] UpdatePayoutStatusJob - handle payout status changes
- [x] Payment matching service
- [x] Stimulus controller for copy buttons and status polling
- [ ] Test with actual Mural Pay sandbox

---

## Architecture

### API Clients Structure (DONE)
```
app/clients/mural_pay/
├── base.rb           # Base HTTP client (Faraday)
├── accounts.rb       # GET/POST /api/accounts
├── transactions.rb   # POST /api/transactions/search
├── counterparties.rb # Counterparty + payout method management
├── payouts.rb        # Create and execute payout requests
└── webhooks.rb       # Webhook management
```

### Database Schema (DONE)

**payments table** (NEW - tracks incoming USDC deposits):
- `order_id` (FK)
- `mural_transaction_id`
- `amount_usdc` (decimal)
- `status` (pending, detected, confirmed, failed)
- `blockchain`, `tx_hash`
- `detected_at`, `confirmed_at`

**orders table additions:**
- `deposit_amount_usdc` - Unique amount for payment matching
- `deposit_wallet_address` - Wallet address for customer
- `mural_account_id` - Mural account used

**withdrawals table additions:**
- `mural_payout_id`
- `usdc_amount`, `exchange_rate`
- `error_message`

**merchant_settings table:**
- Mural account/wallet config
- COP bank account details
- `auto_convert_enabled`

---

## Remaining Implementation Steps

### 1. Create Background Jobs

**ProcessPaymentJob** - Called by webhook or polling:
```ruby
# app/jobs/process_payment_job.rb
class ProcessPaymentJob < ApplicationJob
  def perform(transaction_id)
    # 1. Fetch transaction from Mural API
    # 2. Find matching order by amount
    # 3. Create Payment record
    # 4. Update order status to paid
    # 5. Trigger InitiatePayoutJob if auto_convert enabled
  end
end
```

**PollTransactionsJob** - Fallback polling:
```ruby
# app/jobs/poll_transactions_job.rb
class PollTransactionsJob < ApplicationJob
  def perform
    # 1. Get recent completed transactions from Mural
    # 2. For each unprocessed transaction, call ProcessPaymentJob
    # 3. Re-enqueue self for next poll
  end
end
```

**InitiatePayoutJob** - COP payout:
```ruby
# app/jobs/initiate_payout_job.rb
class InitiatePayoutJob < ApplicationJob
  def perform(order_id)
    # 1. Get order and merchant settings
    # 2. Create payout request via MuralPay::Payouts
    # 3. Execute payout
    # 4. Create Withdrawal record
    # 5. Update order status to converting
  end
end
```

### 2. Payment Matching Service

```ruby
# app/services/payment_matcher.rb
class PaymentMatcher
  TOLERANCE = 0.001 # 0.1%

  def match(transaction)
    amount = transaction["amount"]
    Order.awaiting_payment
         .where(deposit_amount_usdc: amount_range(amount))
         .where("created_at > ?", 24.hours.ago)
         .first
  end
end
```

### 3. Stimulus Controller (optional)

For copy buttons and status polling on order show page.

---

## Key Files Reference

### Created Files
| File | Status |
|------|--------|
| `app/clients/mural_pay/base.rb` | ✅ Done |
| `app/clients/mural_pay/accounts.rb` | ✅ Done |
| `app/clients/mural_pay/transactions.rb` | ✅ Done |
| `app/clients/mural_pay/counterparties.rb` | ✅ Done |
| `app/clients/mural_pay/payouts.rb` | ✅ Done |
| `app/clients/mural_pay/webhooks.rb` | ✅ Done |
| `app/models/payment.rb` | ✅ Done |
| `app/models/merchant_setting.rb` | ✅ Done |
| `app/dashboards/payment_dashboard.rb` | ✅ Done |
| `app/dashboards/merchant_setting_dashboard.rb` | ✅ Done |
| `app/controllers/admin/payments_controller.rb` | ✅ Done |
| `app/controllers/admin/merchant_settings_controller.rb` | ✅ Done |
| `app/controllers/webhooks/mural_pay_controller.rb` | ✅ Done |
| `app/jobs/process_payment_job.rb` | ✅ Done |
| `app/jobs/poll_transactions_job.rb` | ✅ Done |
| `app/jobs/initiate_payout_job.rb` | ✅ Done |
| `app/jobs/update_payout_status_job.rb` | ✅ Done |
| `app/services/payment_matcher.rb` | ✅ Done |
| `app/javascript/controllers/payment_status_controller.js` | ✅ Done |

### Modified Files
| File | Status |
|------|--------|
| `app/models/order.rb` | ✅ Done - has_many :payments, unique deposit amount |
| `app/controllers/orders_controller.rb` | ✅ Done - payment_status endpoint |
| `app/views/orders/show_view.rb` | ✅ Done - payment instructions UI |
| `app/dashboards/order_dashboard.rb` | ✅ Done - payment fields |
| `config/routes.rb` | ✅ Done - webhooks, admin routes |

---

## Environment Variables Needed

```bash
MURAL_PAY_API_KEY=your_api_key
MURAL_PAY_BASE_URL=https://api-staging.muralpay.com
MURAL_WEBHOOK_SECRET=optional_webhook_secret
```

---

## Testing Checklist

1. [ ] Configure MerchantSetting via /admin/merchant_settings
2. [ ] Create test order, verify USDC amount displays
3. [ ] Send test USDC via Mural sandbox
4. [ ] Verify payment detection (webhook or polling)
5. [ ] Verify COP payout initiated
6. [ ] Check withdrawal status in admin
