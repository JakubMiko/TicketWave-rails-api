import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "background"];

  connect() {
    // Nie blokujemy scrolla strony
    this.onKeydown = this.onKeydown.bind(this);
    document.addEventListener("keydown", this.onKeydown);
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown);
  }

  close(event) {
    if (event) event.preventDefault();
    const frame = document.getElementById("modal_frame");
    if (frame) {
      // natychmiast, bez opóźnienia
      frame.innerHTML = "";
    }
  }

  closeOnBackgroundClick(event) {
    if (event.target === this.backgroundTarget) {
      this.close(event);
    }
  }

  onKeydown(e) {
    if (e.key === "Escape") this.close();
  }
}
