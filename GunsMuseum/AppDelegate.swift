import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Cria a janela principal
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Cria a ViewController e configura a janela
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
