import UIKit
import Flutter
import FlutterPluginRegistrant

/// Native iOS AppDelegate demonstrating FlutterEngineGroup pooling.
/// Reduces per-screen memory from ~19MB to ~180KB and enables sub-millisecond launches.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    // Shared engine group managing the pool of Flutter engines
    let engines = FlutterEngineGroup(name: "enterprise_engine_group", project: nil)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    /// Spawns a lightweight Flutter screen from the shared engine group
    func presentCheckout(from viewController: UIViewController) {
        let engine = engines.makeEngine(withEntrypoint: "checkoutEntryPoint", libraryURI: nil)
        GeneratedPluginRegistrant.register(with: engine)

        let flutterViewController = FlutterViewController(
            engine: engine,
            nibName: nil,
            bundle: nil
        )
        flutterViewController.modalPresentationStyle = .fullScreen
        viewController.present(flutterViewController, animated: true)
    }
}
