import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, model: { type: String, default: "should" } }

  edit() {
    const currentText = this.element.textContent.trim()
    const input = document.createElement("input")
    input.type = "text"
    input.value = currentText
    input.className = "should-input"
    input.dataset.originalText = currentText

    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        this.save(input)
      } else if (e.key === "Escape") {
        this.cancel(input)
      }
    })

    input.addEventListener("blur", () => this.save(input))

    this.element.replaceWith(input)
    input.focus()
    input.select()
  }

  save(input) {
    const newText = input.value.trim()
    const originalText = input.dataset.originalText

    if (!newText || newText === originalText) {
      this.cancel(input)
      return
    }

    const token = document.querySelector('meta[name="csrf-token"]').content
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ [this.modelValue]: { title: newText } })
    }).then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

  cancel(input) {
    const span = document.createElement("span")
    span.className = input.dataset.spanClass || "should-text"
    span.textContent = input.dataset.originalText
    span.dataset.controller = "inline-edit"
    span.dataset.inlineEditUrlValue = this.urlValue
    span.dataset.inlineEditModelValue = this.modelValue
    span.dataset.action = "click->inline-edit#edit"
    input.replaceWith(span)
  }
}
