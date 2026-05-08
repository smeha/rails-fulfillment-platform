import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { pending: Boolean }

  connect() {
    if (!this.pendingValue) return

    this.timeout = setTimeout(() => {
      Turbo.visit(window.location.href, { action: "replace" })
    }, 3000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
