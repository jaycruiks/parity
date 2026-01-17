class Withdrawal < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, default: :pending

  validates :status, presence: true
end
