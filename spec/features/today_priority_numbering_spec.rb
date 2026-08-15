require "rails_helper"

# The priority items on Today's Plan are numbered with a circled digit (1, 2, 3…)
# that reflects each item's position in the list. Adding a priority gives it the
# next number, and deleting one in the middle renumbers the rest so there are no
# gaps. The numbers come from the collection render counter, so create and delete
# re-render the whole #priorities-list (rather than appending/removing a single
# node) to keep the numbering correct — see create/destroy.turbo_stream.erb.
RSpec.describe "Today priority numbering", type: :feature do
  before { sign_in_via_browser(create(:user)) }

  # The circled number is the text of the toggle button at the start of each
  # priority row. Returns the numbers as shown, top to bottom.
  # Collecting the rows and then reading each row's button in a separate step
  # leaves a window where a turbo-stream replace detaches a row mid-read
  # (StaleReferenceError), which the edit specs below hit. Retry the whole read
  # when that happens rather than asserting on a half-swapped list.
  def visible_priority_numbers
    attempts = 0
    begin
      within("#priorities-list") do
        all(".should-item").map do |row|
          row.first("button", minimum: 1).text.strip
        end
      end
    rescue Capybara::Playwright::Node::StaleReferenceError
      attempts += 1
      raise if attempts > 3
      retry
    end
  end

  # The priority add form is the .plan-add-row immediately after #priorities-list
  # (the "Extra" section has its own identical add form, hence the scoping).
  def priority_add_form
    find("#priorities-list + .plan-add-row")
  end

  def add_priority(title)
    within(priority_add_form) do
      fill_in "plan_item[title]", with: title
      click_on "Add"
    end
    # Wait for the new row to land before continuing.
    expect(page).to have_css("#priorities-list .should-item", text: title)
  end

  # The dashed "add" circle previews the number the next priority will get.
  def next_priority_placeholder
    find("#next-priority-num").text.strip
  end

  it "numbers priorities 1..N as they are added" do
    add_priority("First thing")
    add_priority("Second thing")
    add_priority("Third thing")

    expect(visible_priority_numbers).to eq(%w[1 2 3])
  end

  it "shows the next number in the add placeholder as items are added and removed" do
    expect(next_priority_placeholder).to eq("1")

    add_priority("First thing")
    expect(next_priority_placeholder).to eq("2")

    add_priority("Second thing")
    expect(next_priority_placeholder).to eq("3")

    within("#priorities-list .should-item", text: "First thing") do
      find(".should-remove").click
    end
    within("[data-delete-confirm-target='modal']") { click_on "Delete" }

    expect(page).to have_no_css("#priorities-list .should-item", text: "First thing")
    expect(next_priority_placeholder).to eq("2")
  end

  # Inline edit: click the title text, type the new title, press Enter.
  #
  # The turbo-stream replace detaches the edited row and inserts a new one, so the
  # list briefly holds fewer rows than it should. Waiting only on the new title or
  # the row count can be satisfied by the pre-swap DOM and lets the caller read
  # numbers mid-swap. `expected_count` rows each carrying a non-empty number button
  # only holds once the replacement has actually landed.
  def rename_priority(from:, to:, expected_count:)
    within("#priorities-list .should-item", text: from) do
      find(".should-text").click
      # The input opens pre-selected, so typing replaces the old title.
      find("input.should-input").send_keys(to, :enter)
    end
    expect(page).to have_css("#priorities-list .should-item", text: to)
    expect(page).to have_no_css("#priorities-list input.should-input")
    expect(page).to have_css("#priorities-list .should-item", count: expected_count)
    expect(page).to have_css("#priorities-list .should-item form button:not(:empty)", count: expected_count)
  end

  it "keeps the circled number after editing a priority's title" do
    add_priority("First thing")
    add_priority("Second thing")
    add_priority("Third thing")

    rename_priority(from: "Second thing", to: "Second thing, renamed", expected_count: 3)

    expect(visible_priority_numbers).to eq(%w[1 2 3])
  end

  # The first priority's counter is 0, the one value most likely to be dropped by
  # a truthiness check on the counter local.
  it "keeps the circled number after editing the first priority" do
    add_priority("First thing")
    add_priority("Second thing")

    rename_priority(from: "First thing", to: "First thing, renamed", expected_count: 2)

    expect(visible_priority_numbers).to eq(%w[1 2])
  end

  it "renumbers after deleting a middle priority" do
    add_priority("First thing")
    add_priority("Second thing")
    add_priority("Third thing")

    # Delete the middle one ("Second thing") via the row's × and the confirm modal.
    within("#priorities-list .should-item", text: "Second thing") do
      find(".should-remove").click
    end
    within("[data-delete-confirm-target='modal']") { click_on "Delete" }

    expect(page).to have_no_css("#priorities-list .should-item", text: "Second thing")
    expect(visible_priority_numbers).to eq(%w[1 2])
  end
end
