import UIKit
import Capacitor

/// Registers the app's own (local) Capacitor plugins.
/// In Main.storyboard, set the Bridge View Controller's custom class to `MainViewController`.
class MainViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(GameCenterPlugin())
    }
}
