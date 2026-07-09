import HotwireNative
import SafariServices
import UIKit
import WebKit

class AuthNavigatorDelegate: NavigatorDelegate {
  weak var viewController: UIViewController?
  weak var webView: WKWebView?

  // Fires for Turbo-driven navigations (link clicks, form submissions)
  func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
      return openSafariIfLoginURL(proposal.url) ? .reject : .accept
  }

  // Fires after every request completes — check actual webview URL since
  // requestDidFinish reports the original URL, not the final URL after redirects
  func requestDidFinish(at url: URL) {
      let actualURL = webView?.url ?? url
      openSafariIfLoginURL(actualURL)
  }

  @discardableResult
  private func openSafariIfLoginURL(_ url: URL) -> Bool {
      guard url.path == "/login" else { return false }
      // Don't open Safari if it's already presented or if we're mid token-login flow
      guard viewController?.presentedViewController == nil else { return false }
      // Don't open Safari if the webview is loading the token exchange
      if let webViewURL = webView?.url, webViewURL.path.contains("token_login") { return false }

      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
      var queryItems = components.queryItems ?? []
      if !queryItems.contains(where: { $0.name == "native" }) {
          queryItems.append(URLQueryItem(name: "native", value: "1"))
      }
      components.queryItems = queryItems

      let safariVC = SFSafariViewController(url: components.url!)
      viewController?.present(safariVC, animated: true)
      return true
  }
}
