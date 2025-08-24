import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { hideDelay: Number }

  connect() {
    this.timeout = setTimeout(() => this.fadeOut(), this.hideDelayValue || 4000)
  }

  fadeOut() {
    this.element.classList.add("opacity-0")
    setTimeout(() => this.close(), 700)
  }

  close() {
    this.element.outerHTML = '<turbo-frame id="modal-alert"></turbo-frame>'
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}