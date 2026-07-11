import HotwireNative
import SafariServices
import UIKit
import WebKit

class AuthNavigatorDelegate: NavigatorDelegate {
    weak var tabBarController: HotwireTabBarController?

    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        return openSafariIfLoginURL(proposal.url) ? .reject : .accept
    }

    func requestDidFinish(at url: URL) {
        let activeWebView = tabBarController?.activeNavigator.session.webView
        let actualURL = activeWebView?.url ?? url
        openSafariIfLoginURL(actualURL)
    }

    @discardableResult
    private func openSafariIfLoginURL(_ url: URL) -> Bool {
        guard url.path == "/login" else { return false }
        guard tabBarController?.presentedViewController == nil else { return false }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "native" }) {
            queryItems.append(URLQueryItem(name: "native", value: "1"))
        }
        components.queryItems = queryItems

        let safariVC = SFSafariViewController(url: components.url!)
        tabBarController?.present(safariVC, animated: true)
        return true
    }
}
