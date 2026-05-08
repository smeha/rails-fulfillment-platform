import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const REFRESH_INTERVAL_MS = 3000

export default class extends Controller {
  static values = { pending: Boolean }

  connect() {
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  pendingValueChanged() {
    this.pendingValue ? this.startPolling() : this.stopPolling()
  }

  startPolling() {
    if (this.intervalId || !this.pendingValue) return

    this.intervalId = setInterval(() => {
      Turbo.visit(window.location.href, { action: "replace" })
    }, REFRESH_INTERVAL_MS)
  }

  stopPolling() {
    if (!this.intervalId) return

    clearInterval(this.intervalId)
    this.intervalId = null
  }
}
