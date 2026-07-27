require "rails_helper"

# The onboarding wizard is a single page whose 5 steps are stepped through
# client-side by the `onboarding` Stimulus controller. These specs drive that
# JS flow in a real browser. The server-side contract (who gets redirected to
# the wizard, what completing it does) is covered by spec/requests/onboarding_spec.rb.
RSpec.describe "Onboarding wizard", type: :feature do
  it "appears on first login and lands on the app after clicking through" do
    sign_in_via_browser(create(:user, :onboarding_pending))

    expect(page).to have_current_path(onboarding_path)

    4.times { click_on "Next" }
    click_on "Get started"

    expect(page).to have_current_path(root_path)
  end

  it "does not appear again on a later login once completed" do
    user = create(:user, :onboarding_pending)

    sign_in_via_browser(user)
    4.times { click_on "Next" }
    click_on "Get started"
    expect(page).to have_current_path(root_path)

    # Log out through the real UI, then log back in as the same user.
    visit settings_path
    click_on "Log out"
    expect(page).to have_current_path(login_path)

    sign_in_via_browser(user)

    # Straight to the app, no wizard.
    expect(page).to have_current_path(root_path)
    expect(user.reload.onboarding_completed).to be true
  end

  it "enables the gratitude journal when finished with the toggle on (default)" do
    user = create(:user, :onboarding_pending)
    sign_in_via_browser(user)

    4.times { click_on "Next" }
    click_on "Get started"

    expect(page).to have_current_path(root_path)
    expect(user.reload.gratitude_enabled).to be true
  end
end
