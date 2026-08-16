import { Controller } from "@hotwired/stimulus"

// Two-choice confirm for resetting a filled-in week: copy the previous week's
// plan, or start from the default empty categories. Unlike delete-confirm the
// modal has two submit paths, so the chosen strategy is written into a hidden
// field before the form submits.
export default class extends Controller {
  static targets = ["modal", "form", "strategy"]

  show(event) {
    event.preventDefault()
    this.modalTarget.style.display = "flex"
  }

  copyPrevious() {
    this.submitWith("previous")
  }

  startFromScratch() {
    this.submitWith("scratch")
  }

  submitWith(strategy) {
    this.strategyTarget.value = strategy
    this.formTarget.requestSubmit()
    this.cancel()
  }

  cancel() {
    this.modalTarget.style.display = "none"
  }

  backdropClick(event) {
    if (event.target === this.modalTarget) {
      this.cancel()
    }
  }
}
