import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "dot", "backBtn", "nextBtn", "completeBtn", "gratitudeToggle"]
  static values = { current: { type: Number, default: 1 }, total: { type: Number, default: 5 } }

  connect() {
    this.show(this.currentValue)
  }

  next() {
    if (this.currentValue < this.totalValue) {
      this.show(this.currentValue + 1)
    }
  }

  back() {
    if (this.currentValue > 1) {
      this.show(this.currentValue - 1)
    }
  }

  show(step) {
    this.currentValue = step

    this.stepTargets.forEach((el, i) => {
      el.style.display = i + 1 === step ? "flex" : "none"
    })

    this.dotTargets.forEach((el, i) => {
      const active = i + 1 === step
      el.style.width = active ? "20px" : "7px"
      el.style.background = active ? "#2D2925" : "#C7BEB1"
    })

    if (this.hasBackBtnTarget) {
      this.backBtnTarget.style.visibility = step === 1 ? "hidden" : "visible"
      this.backBtnTarget.style.display = step === 1 ? "none" : "flex"
    }
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.style.display = step === this.totalValue ? "none" : "block"
    }
    if (this.hasCompleteBtnTarget) {
      this.completeBtnTarget.style.display = step !== this.totalValue ? "none" : "block"
    }
  }

  skip() {
    this.element.querySelector("[name='gratitude_enabled']").value = "0"
  }

  submit(e) {
    e.preventDefault()
    const form = this.element
    form.querySelector("[name='gratitude_enabled']").value = this.hasGratitudeToggleTarget && this.gratitudeToggleTarget.checked ? "1" : "0"
    form.submit()
  }
}
