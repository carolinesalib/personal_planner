import HotwireNative
import SafariServices
import UIKit
import WebKit

let rootURL = URL(string: "https://web-production-51bc2.up.railway.app/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private let authDelegate = AuthNavigatorDelegate()
  private let navigator = Navigator(configuration: .init(
      name: "main",
      startLocation: rootURL
  ))

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      guard let windowScene = scene as? UIWindowScene else { return }
      window = UIWindow(windowScene: windowScene)
      window?.rootViewController = navigator.rootViewController
      window?.makeKeyAndVisible()
      authDelegate.viewController = navigator.rootViewController
      authDelegate.webView = navigator.session.webView
      navigator.delegate = authDelegate
      navigator.start()
  }

  // Called when iOS opens shouldplanner://auth/success?token=TOKEN
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      guard
          let url = URLContexts.first?.url,
          url.scheme == "shouldplanner",
          url.host == "auth",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let token = components.queryItems?.first(where: { $0.name == "token" })?.value
      else { return }

      // Dismiss Safari first, then load the token exchange URL directly in the webview.
      // Using navigator.session.webView.load() instead of navigator.route() avoids
      // Turbo triggering a duplicate history visit that would consume the token twice.
      let tokenLoginURL = rootURL
          .appendingPathComponent("auth/token_login")
          .appending(queryItems: [URLQueryItem(name: "token", value: token)])

      navigator.rootViewController.dismiss(animated: true) {
          self.navigator.session.webView.load(URLRequest(url: tokenLoginURL))
      }
  }
}
