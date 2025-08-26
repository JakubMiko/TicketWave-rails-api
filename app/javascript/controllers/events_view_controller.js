import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cards", "list", "cardsBtn", "listBtn"]

  connect() {
    const view = localStorage.getItem("eventsView") || "cards"
    if (view === "list") {
      this.showList()
    } else {
      this.showCards()
    }
  }

  showCards() {
    this.cardsTarget.classList.remove("hidden")
    this.listTarget.classList.add("hidden")
    this.cardsBtnTarget.classList.add("bg-purple-600", "text-white")
    this.cardsBtnTarget.classList.remove("bg-gray-200", "text-purple-800")
    this.listBtnTarget.classList.remove("bg-purple-600", "text-white")
    this.listBtnTarget.classList.add("bg-gray-200", "text-purple-800")
    localStorage.setItem("eventsView", "cards")
  }

  showList() {
    this.cardsTarget.classList.add("hidden")
    this.listTarget.classList.remove("hidden")
    this.listBtnTarget.classList.add("bg-purple-600", "text-white")
    this.listBtnTarget.classList.remove("bg-gray-200", "text-purple-800")
    this.cardsBtnTarget.classList.remove("bg-purple-600", "text-white")
    this.cardsBtnTarget.classList.add("bg-gray-200", "text-purple-800")
    localStorage.setItem("eventsView", "list")
  }
}
