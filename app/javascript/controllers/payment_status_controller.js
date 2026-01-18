import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { orderId: Number }
  static targets = ["statusMessage"]

  connect() {
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.poll()
    this.pollInterval = setInterval(() => this.poll(), 5000)
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
  }

  async poll() {
    try {
      const response = await fetch(`/orders/${this.orderIdValue}/payment_status`)
      const data = await response.json()

      if (data.status === "paid" || data.status === "converting" || data.status === "withdrawn") {
        this.stopPolling()
        window.location.reload()
      }
    } catch (error) {
      console.error("Failed to check payment status:", error)
    }
  }

  copyAmount(event) {
    const value = event.currentTarget.dataset.copyValue
    this.copyToClipboard(value, event.currentTarget)
  }

  copyAddress(event) {
    const value = event.currentTarget.dataset.copyValue
    this.copyToClipboard(value, event.currentTarget)
  }

  async copyToClipboard(text, button) {
    try {
      await navigator.clipboard.writeText(text)
      const originalText = button.textContent
      button.textContent = "Copied!"
      button.classList.add("bg-green-100", "text-green-700")
      button.classList.remove("bg-indigo-100", "text-indigo-700")

      setTimeout(() => {
        button.textContent = originalText
        button.classList.remove("bg-green-100", "text-green-700")
        button.classList.add("bg-indigo-100", "text-indigo-700")
      }, 2000)
    } catch (error) {
      console.error("Failed to copy:", error)
    }
  }
}
