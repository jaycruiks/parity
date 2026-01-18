class PaymentMatcher
  TOLERANCE = 0.001 # 0.1% tolerance for matching
  MATCH_WINDOW = 24.hours

  def initialize(transaction_data)
    @transaction_data = transaction_data
  end

  def match
    amount = extract_amount
    return nil unless amount

    Order.awaiting_payment
         .where(deposit_amount_usdc: amount_range(amount))
         .where("created_at > ?", MATCH_WINDOW.ago)
         .order(created_at: :desc)
         .first
  end

  def create_payment!(order)
    Payment.create!(
      order: order,
      mural_transaction_id: transaction_id,
      amount_usdc: extract_amount,
      blockchain: extract_blockchain,
      tx_hash: extract_tx_hash,
      status: :detected,
      detected_at: Time.current
    )
  end

  private

  def extract_amount
    @transaction_data["tokenAmount"]&.to_d ||
      @transaction_data["amount"]&.to_d
  end

  def transaction_id
    @transaction_data["id"] || @transaction_data["transactionId"]
  end

  def extract_blockchain
    @transaction_data["blockchain"] || "polygon"
  end

  def extract_tx_hash
    @transaction_data["transactionHash"] || @transaction_data["txHash"]
  end

  def amount_range(amount)
    tolerance = amount * TOLERANCE
    (amount - tolerance)..(amount + tolerance)
  end
end
