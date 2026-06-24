import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "label", "form"]

  show(event) {
    event.preventDefault()
    const title = event.params.title
    const url = event.params.url

    this.labelTarget.textContent = title
    this.formTarget.action = url
    this.modalTarget.style.display = "flex"
  }

  connect() {
    document.addEventListener("turbo:submit-end", this.handleSubmit)
  }

  disconnect() {
    document.removeEventListener("turbo:submit-end", this.handleSubmit)
  }

  handleSubmit = () => {
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
