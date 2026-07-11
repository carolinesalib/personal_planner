import HotwireNative
import UIKit

extension HotwireTab {
    static let all: [HotwireTab] = [.today, .shoulds, .planner]

    static let today = HotwireTab(
        title: "Today",
        image: UIImage(systemName: "sun.max")!,
        url: rootURL.appendingPathComponent("today")
    )

    static let shoulds = HotwireTab(
        title: "Shoulds",
        image: UIImage(systemName: "checklist")!,
        url: rootURL.appendingPathComponent("shoulds")
    )

    static let planner = HotwireTab(
        title: "Calendar",
        image: UIImage(systemName: "calendar")!,
        url: rootURL.appendingPathComponent("planner")
    )
}
