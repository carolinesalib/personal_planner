require "rails_helper"

# The gratitude journal panel only renders on the day-planning views, and only
# when the user has enabled it. On "today" it renders collapsed; on any other
# calendar day it renders expanded (data-gratitude-open-value reflects that).
RSpec.describe "Gratitude on planning pages", type: :request do
  describe "GET /today" do
    it "shows the gratitude panel when enabled" do
      sign_in(create(:user, :with_gratitude))

      get today_path

      expect(response.body).to include('data-controller="gratitude"')
    end

    it "hides the gratitude panel when disabled" do
      sign_in(create(:user)) # gratitude_enabled: false by default

      get today_path

      expect(response.body).not_to include('data-controller="gratitude"')
    end

    it "renders the today panel collapsed" do
      sign_in(create(:user, :with_gratitude))

      get today_path

      expect(response.body).to include('data-gratitude-open-value="false"')
    end
  end

  describe "GET /planner/:date (calendar day)" do
    let(:other_day) { (Date.current - 3).iso8601 }

    it "shows the gratitude panel when enabled" do
      sign_in(create(:user, :with_gratitude))

      get planner_day_path(date: other_day)

      expect(response.body).to include('data-controller="gratitude"')
    end

    it "hides the gratitude panel when disabled" do
      sign_in(create(:user))

      get planner_day_path(date: other_day)

      expect(response.body).not_to include('data-controller="gratitude"')
    end

    it "renders a non-today calendar day expanded" do
      sign_in(create(:user, :with_gratitude))

      get planner_day_path(date: other_day)

      expect(response.body).to include('data-gratitude-open-value="true"')
    end
  end
end
