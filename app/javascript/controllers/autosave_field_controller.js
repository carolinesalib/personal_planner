import { Controller } from "@hotwired/stimulus"

// Plain text input that PATCHes its value on blur/Enter. Used for the
// weekly mission field, where there's no surrounding turbo_stream to render.
export default class extends Controller {
  static values = { url: String, param: { type: String, default: "mission" } }

  save() {
    const token = document.querySelector('meta[name="csrf-token"]').content
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ planner_period: { [this.paramValue]: this.element.value } })
    })
  }

  saveOnEnter(event) {
    event.preventDefault()
    this.element.blur()
  }
}
