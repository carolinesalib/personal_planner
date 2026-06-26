import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "chevron"]

  toggle() {
    const isOpen = this.contentTarget.style.display !== "none"
    this.contentTarget.style.display = isOpen ? "none" : "block"
    this.chevronTarget.style.transform = isOpen ? "none" : "rotate(180deg)"
  }
}
