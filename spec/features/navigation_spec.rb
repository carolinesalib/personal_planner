require "rails_helper"

RSpec.describe "Navigation", type: :feature do
  before do
    sign_in_via_browser(create(:user))
  end

  describe "main bottom nav (Shoulds / Today / Planner / Settings)" do
    it "reaches every tab from Today" do
      expect(page).to have_current_path(root_path)

      click_on "Shoulds"
      expect(page).to have_current_path(shoulds_path)

      click_on "Today"
      expect(page).to have_current_path(today_path)

      click_on "Planner"
      expect(page).to have_current_path(planner_path)

      click_on "Settings"
      expect(page).to have_current_path(settings_path)
    end
  end

  describe "Settings → macro planners → back to Settings (mobile)", :mobile do
    it "reaches Week planner and returns" do
      visit settings_path

      click_on "Week planner"
      expect(page).to have_current_path(planner_week_path)
      expect(page).to have_content("Week")

      find(".planner-mobile-back").click
      expect(page).to have_current_path(settings_path)
    end

    it "reaches Quarter planner and returns" do
      visit settings_path

      click_on "Quarter planner"
      expect(page).to have_current_path(planner_quarter_path)

      find(".planner-mobile-back").click
      expect(page).to have_current_path(settings_path)
    end

    it "reaches Year planner and returns" do
      visit settings_path

      click_on "Year planner"
      expect(page).to have_current_path(planner_year_path)

      find(".planner-mobile-back").click
      expect(page).to have_current_path(settings_path)
    end
  end

  describe "macro planner sidebar nav (Week / Quarter / Year)" do
    it "moves between all three periods" do
      visit planner_week_path

      click_on "Quarter"
      expect(page).to have_current_path(planner_quarter_path)

      click_on "Year"
      expect(page).to have_current_path(planner_year_path)

      click_on "Week"
      expect(page).to have_current_path(planner_week_path)
    end

    it "jumps to Shoulds and Today from the sidebar's mobile links" do
      visit planner_week_path

      click_on "Shoulds"
      expect(page).to have_current_path(shoulds_path)

      visit planner_week_path
      click_on "Today"
      expect(page).to have_current_path(root_path)
    end
  end

  describe "macro planner bottom nav (mobile-width overlay)", :mobile do
    it "reaches Shoulds, Today, Planner, and Settings from Week" do
      visit planner_week_path

      within(".planner-nav--overlay") { click_on "Shoulds" }
      expect(page).to have_current_path(shoulds_path)

      visit planner_week_path
      within(".planner-nav--overlay") { click_on "Today" }
      expect(page).to have_current_path(today_path)

      visit planner_week_path
      within(".planner-nav--overlay") { click_on "Planner" }
      expect(page).to have_current_path(planner_path)

      visit planner_week_path
      within(".planner-nav--overlay") { click_on "Settings" }
      expect(page).to have_current_path(settings_path)
    end
  end
end
