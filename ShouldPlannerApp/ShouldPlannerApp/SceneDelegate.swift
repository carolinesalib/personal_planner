import HotwireNative
import SafariServices
import UIKit
import WebKit

let rootURL = URL(string: "https://web-production-51bc2.up.railway.app/")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let authDelegate = AuthNavigatorDelegate()
    private lazy var tabBarController = HotwireTabBarController(navigatorDelegate: authDelegate)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        configureHotwire()

        tabBarController.tabBar.isHidden = true
        UINavigationBar.appearance().isHidden = true

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        authDelegate.tabBarController = tabBarController
        tabBarController.load(HotwireTab.all)
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

        let tokenLoginURL = rootURL
            .appendingPathComponent("auth/token_login")
            .appending(queryItems: [URLQueryItem(name: "token", value: token)])

        tabBarController.dismiss(animated: true) {
            self.tabBarController.activeNavigator.session.webView.load(URLRequest(url: tokenLoginURL))
        }
    }

    private func configureHotwire() {
        if let configURL = Bundle.main.url(forResource: "path-configuration", withExtension: "json") {
            Hotwire.config.pathConfiguration.sources = [.file(configURL)]
        }
    }
}
