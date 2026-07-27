require "capybara/rspec"
require "capybara-playwright-driver"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    playwright_cli_executable_path: Rails.root.join("node_modules/.bin/playwright").to_s,
    browser_type: :chromium,
    headless: ENV["HEADFUL"] != "1"
  )
end

Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :playwright
  end

  config.before(:each, :mobile, type: :system) do
    page.current_window.resize_to(390, 844)
  end
end
