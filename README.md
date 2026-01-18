# Parity

E-commerce checkout system with automated USDC-to-COP payment conversion using Mural Pay.

## Overview

Parity enables merchants to accept USDC cryptocurrency payments and automatically convert them to Colombian Pesos (COP) for bank deposit. When customers deposit USDC to your wallet, the system matches transactions to orders, converts the funds, and sends COP directly to your Colombian bank account.

## Features

- Accept USDC payments on Polygon blockchain
- Automatic transaction matching to orders
- USDC to COP conversion via Mural Pay
- Direct bank deposits in Colombian Pesos
- Webhook-based transaction notifications
- Admin dashboard for orders, payments, and withdrawals

## Prerequisites

- Ruby 3.4.8
- PostgreSQL
- Mural Pay account (staging or production)

## Installation

### 1. Install System Dependencies (macOS)

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PostgreSQL
brew install postgresql@18
brew services start postgresql@18

# Install rbenv (Ruby version manager)
brew install rbenv ruby-build

# Add rbenv to your shell
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

# Install Ruby 3.4.8
rbenv install 3.4.8
rbenv global 3.4.8

# Verify Ruby installation
ruby -v  # Should show ruby 3.4.8

# Install Bundler
gem install bundler
```

### 2. Clone and Install Dependencies

```bash
git clone <repository-url>
cd parity
bundle install
```

### 3. Database Setup

```bash
# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate
```

### 4. Environment Configuration

Create a `.env` file in the project root:

```bash
# Rails Configuration
RAILS_MAX_THREADS=5
PORT=3000
RAILS_LOG_LEVEL=debug

# Mural Pay Configuration
MURAL_PAY_API_KEY=your_api_key_here
MURAL_PAY_BASE_URL=https://api-staging.muralpay.com
MURAL_WEBHOOK_PUBLIC_KEY="your_webhook_public_key_here"

# Admin Dashboard
ADMIN_USER=admin
ADMIN_PASSWORD=password

# Background Job Configuration
JOB_CONCURRENCY=1
```

### 5. Mural Pay Setup

#### Get Your API Key

Sign up for Mural Pay and retrieve your API key from the dashboard.

#### Configure Merchant Settings

Run these commands in Rails console (`bin/rails console`):

```ruby
# Get your Mural Pay account details
client = MuralPay::Accounts.new
account = client.list.first
account_id = account['id']
wallet = account.dig('accountDetails', 'walletDetails', 'walletAddress')

# Update merchant settings
settings = MerchantSetting.current
settings.update!(
  mural_account_id: account_id,
  deposit_wallet_address: wallet
)

puts "Account ID: #{account_id}"
puts "Wallet Address: #{wallet}"
```

#### Create Webhook

```ruby
client = MuralPay::Webhooks.new
webhook = client.create(
  url: 'https://your-app.herokuapp.com/webhooks/mural_pay',
  categories: ['MURAL_ACCOUNT_BALANCE_ACTIVITY', 'PAYOUT_REQUEST']
)

# Enable the webhook
client.enable(webhook['id'])

# Copy the public key to your .env file
puts "Add this to .env:"
puts "MURAL_WEBHOOK_PUBLIC_KEY=\"#{webhook['publicKey']}\""
```

#### Setup Colombian Bank Account for Payouts

```ruby
# 1. Get list of supported banks
client = MuralPay::Counterparties.new
banks = client.supported_banks(payout_types: 'copDomestic')
banks['copDomestic']['banks'].each do |bank|
  puts "#{bank['id']} - #{bank['name']}"
end

# 2. Create a counterparty (business or individual)
counterparty = client.create_business(
  business_name: 'Your Business Name',
  email: 'contact@yourbusiness.com',
  address: {
    line1: 'Your Street Address',
    city: 'Bogotá',
    state: 'Cundinamarca',
    postal_code: '110111',
    country: 'CO'
  }
)

counterparty_id = counterparty['id']
puts "Counterparty ID: #{counterparty_id}"

# 3. Create payout method (Colombian bank account)
payout_method = client.create_cop_domestic_payout_method(
  counterparty_id: counterparty_id,
  alias_name: 'Main Bank Account',
  bank_id: 'bank_cop_022',  # Choose from the bank list above
  account_number: 'YOUR_ACCOUNT_NUMBER',
  account_type: 'SAVINGS',  # or 'CHECKING'
  document_number: 'YOUR_CEDULA_OR_NIT',
  document_type: 'NATIONAL_ID',  # or 'RUC_NIT' for business
  phone_number: '+573001234567'
)

payout_method_id = payout_method['id']
puts "Payout Method ID: #{payout_method_id}"

# 4. Update merchant settings with payout configuration
settings = MerchantSetting.current
settings.update!(
  mural_counterparty_id: counterparty_id,
  mural_payout_method_id: payout_method_id
)

puts "✓ Merchant settings fully configured!"
```

#### Verify Configuration

```ruby
# Check all settings
settings = MerchantSetting.current
puts "Account ID: #{settings.mural_account_id}"
puts "Wallet: #{settings.deposit_wallet_address}"
puts "Counterparty ID: #{settings.mural_counterparty_id}"
puts "Payout Method ID: #{settings.mural_payout_method_id}"
puts "Configured: #{settings.configured?}"
puts "Payout Configured: #{settings.payout_configured?}"

# Test API connections
client = MuralPay::Accounts.new
account = client.find(settings.mural_account_id)
puts "Balance: #{account.dig('accountDetails', 'balances', 0, 'tokenAmount')} USDC"
```

## Running the Application

### Start Rails Server

```bash
bin/rails server
```

### Start Background Jobs (in separate terminal)

```bash
bin/rails solid_queue:start
```

### Access Admin Dashboard

Visit `http://localhost:3000/admin`

- Username: admin (or value from `ADMIN_USER` env var)
- Password: password (or value from `ADMIN_PASSWORD` env var)

## Payment Flow

1. **Customer deposits USDC** to your Polygon wallet address
2. **Mural Pay webhook** notifies your app of the transaction
3. **Transaction matching** - `ProcessPaymentJob` matches transaction to order by amount
4. **Payment confirmation** - Order marked as paid
5. **Payout initiation** - `InitiatePayoutJob` creates COP payout request
6. **Conversion** - Mural Pay converts USDC to COP
7. **Bank deposit** - COP sent to your Colombian bank account
8. **Status update** - Webhook confirms completion, order marked as complete

## API Clients

### Accounts
```ruby
client = MuralPay::Accounts.new
client.list                    # List all accounts
client.find(account_id)        # Get account details
client.balances(account_id)    # Get account balances
```

### Transactions
```ruby
client = MuralPay::Transactions.new
client.find(transaction_id)    # Get transaction details
client.search(account_id: id, limit: 100)  # Search transactions
```

### Payouts
```ruby
client = MuralPay::Payouts.new
client.search(limit: 100)      # Search payout requests
client.find(payout_id)         # Get payout details
client.create_cop_payout(...)  # Create COP payout
client.execute(payout_id)      # Execute payout
```

### Counterparties
```ruby
client = MuralPay::Counterparties.new
client.find(counterparty_id)   # Get counterparty
client.search(limit: 100)      # Search counterparties
client.supported_banks(payout_types: 'copDomestic')  # Get bank list
client.create_cop_domestic_payout_method(...)  # Add bank account
```

### Webhooks
```ruby
client = MuralPay::Webhooks.new
client.list                    # List webhooks
client.create(url:, categories:)  # Create webhook
client.enable(webhook_id)      # Enable webhook
```

## Testing

### Run Tests

```bash
bin/rails test
```

### Manual Testing

Create a test order:

```ruby
order = Order.create!(
  status: 'awaiting_payment',
  deposit_amount_usdc: 10.0,
  deposit_wallet_address: MerchantSetting.current.deposit_wallet_address
)

puts "Order ID: #{order.id}"
puts "Send 10 USDC to: #{order.deposit_wallet_address}"
```

## Deployment to Heroku

### 1. Create Heroku App

```bash
# Login to Heroku
heroku login

# Create app (if not already created)
heroku create your-app-name

# Or add existing app as remote
heroku git:remote -a parity-checkout-cec167eb8a82
```

### 2. Add Required Addons

```bash
# PostgreSQL database
heroku addons:create heroku-postgresql:essential-0
```

### 3. Set Environment Variables

```bash
# Mural Pay Configuration
heroku config:set MURAL_PAY_API_KEY=your_api_key_here
heroku config:set MURAL_PAY_BASE_URL=https://api-staging.muralpay.com
heroku config:set MURAL_WEBHOOK_PUBLIC_KEY="your_webhook_public_key_here"

# Admin Dashboard
heroku config:set ADMIN_USER=admin
heroku config:set ADMIN_PASSWORD=your_secure_password

# Rails Configuration
heroku config:set RAILS_MAX_THREADS=5
heroku config:set RAILS_LOG_LEVEL=info
heroku config:set RAILS_ENV=production
heroku config:set RACK_ENV=production

# Solid Queue (background jobs)
heroku config:set SOLID_QUEUE_IN_PUMA=true
```

### 4. Deploy Application

```bash
# Push code to Heroku
git push heroku main

# Run database migrations
heroku run rails db:migrate

# Check logs to ensure successful deployment
heroku logs --tail
```

### 5. Configure Mural Pay on Heroku

```bash
# Open Rails console on Heroku
heroku run rails console

# Then run the merchant setup commands (same as local setup above):
```

```ruby
# Get your Mural Pay account details
client = MuralPay::Accounts.new
account = client.list.first
account_id = account['id']
wallet = account.dig('accountDetails', 'walletDetails', 'walletAddress')

# Update merchant settings
settings = MerchantSetting.current
settings.update!(
  mural_account_id: account_id,
  deposit_wallet_address: wallet
)

# Create counterparty and payout method (if not already done)
# ... follow the "Setup Colombian Bank Account for Payouts" steps from above

# Verify configuration
settings = MerchantSetting.current
puts "Configured: #{settings.configured?}"
puts "Payout Configured: #{settings.payout_configured?}"
```

### 6. Update Webhook URL

If you created the webhook locally, update it to point to your Heroku app:

```bash
heroku run rails console
```

```ruby
client = MuralPay::Webhooks.new
webhooks = client.list
webhook = webhooks.first

# Update webhook URL
client.update(
  webhook['id'],
  url: 'https://parity-checkout-cec167eb8a82.herokuapp.com/webhooks/mural_pay'
)

puts "Webhook updated to production URL"
```

### 7. Verify Deployment

```bash
# Check app is running
heroku open

# View logs
heroku logs --tail

# Check background jobs are running
heroku run rails console
# In console:
# SolidQueue::Process.all
```

### 8. Scale Dynos (Optional)

```bash
# Scale web dynos
heroku ps:scale web=1

# Check dyno status
heroku ps
```

## Heroku Maintenance Commands

```bash
# View logs
heroku logs --tail

# Restart app
heroku restart

# Run Rails console
heroku run rails console

# Run database migrations
heroku run rails db:migrate

# Check environment variables
heroku config

# Check dyno status
heroku ps

# View app info
heroku apps:info
```

## Webhook Endpoint

`POST /webhooks/mural_pay`

Handles these event types:
- `TRANSACTION_COMPLETED` - USDC deposit received
- `PAYOUT_COMPLETED` - COP withdrawal successful
- `PAYOUT_FAILED` - COP withdrawal failed

Signatures are verified using ECDSA with the public key from `MURAL_WEBHOOK_PUBLIC_KEY`.

## Troubleshooting

### Webhook not receiving events

1. Check webhook is ACTIVE: `MuralPay::Webhooks.new.list`
2. Verify URL is correct and publicly accessible
3. Check webhook signature verification isn't failing (logs)

### Transactions not matching orders

1. Ensure amounts match within 0.1% tolerance
2. Check order is in `awaiting_payment` status
3. Verify order was created within last 24 hours
4. Check logs for `PaymentMatcher` errors

### Payouts failing

1. Verify merchant settings: `MerchantSetting.current.payout_configured?`
2. Check account has sufficient USDC balance
3. Verify bank account details are correct
4. Check Mural Pay dashboard for payout status

### Heroku-specific Issues

**Background jobs not running:**
```bash
# Check if Solid Queue is enabled
heroku config | grep SOLID_QUEUE_IN_PUMA

# Check logs for job errors
heroku logs --tail | grep Job
```

**Database connection errors:**
```bash
# Reset database connection pool
heroku restart

# Check database status
heroku pg:info
```

**Memory issues:**
```bash
# Check memory usage
heroku ps

# Upgrade dyno if needed
heroku ps:resize web=standard-1x
```

## Architecture

### Models
- `Order` - Customer orders awaiting payment
- `Payment` - USDC deposits matched to orders
- `Withdrawal` - COP payouts to bank
- `MerchantSetting` - Mural Pay configuration

### Jobs
- `ProcessPaymentJob` - Matches transactions to orders
- `InitiatePayoutJob` - Creates and executes payouts
- `UpdatePayoutStatusJob` - Updates withdrawal status from webhooks

### Services
- `PaymentMatcher` - Matches USDC amounts to orders
- Mural Pay API Clients - Account, Transaction, Payout, Counterparty management

## Support

For Mural Pay API questions, visit: https://developers.muralpay.com

For app-specific issues, check the logs or contact support.
