import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["master", "item"]

  connect() {
    this.syncMaster()
  }

  toggleAll() {
    this.itemTargets.forEach((item) => {
      item.checked = this.masterTarget.checked
    })
  }

  syncMaster() {
    if (!this.hasMasterTarget) return

    const total = this.itemTargets.length
    const checked = this.itemTargets.filter((item) => item.checked).length

    this.masterTarget.checked = total > 0 && checked === total
    this.masterTarget.indeterminate = checked > 0 && checked < total
  }
}
