require "capybara/rspec"
require "capybara-playwright-driver"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    playwright_cli_executable_path: Rails.root.join("node_modules/.bin/playwright").to_s,
    browser_type: :chromium,
    headless: ENV["HEADFUL"] != "1",
    slowMo: ENV["SLOWMO"]&.to_i,
    noViewport: ENV["HEADFUL"] == "1" ? true : nil
  )
end

Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

# These specs use type: :feature (not :system) on purpose. rspec-rails's
# type: :system routes through Rails' ActionDispatch::SystemTesting machinery,
# which takes over the browser lifecycle and suppresses the visible window even
# when the Playwright driver is launched with headless: false. type: :feature
# uses Capybara.default_driver directly, so HEADFUL=1 actually shows a window.
RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers, type: :feature

  config.before(:each, :mobile, type: :feature) do
    page.current_window.resize_to(390, 844)
  end

  if ENV["HEADFUL"] == "1"
    config.after(:each, type: :feature) do
      sleep 2
    end
  end
end
