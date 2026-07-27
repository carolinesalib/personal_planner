module PlanItemsHelper
  # The number shown in the dashed "add priority" circle — the position the next
  # priority would take. Caps at "+" past 9 so it stays inside the circle.
  def next_priority_number(count)
    count >= 9 ? "+" : (count + 1).to_s
  end
end
