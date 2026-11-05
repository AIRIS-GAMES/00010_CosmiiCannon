import Foundation
import Capacitor
import GameKit

/// Minimal Apple Game Center bridge for Cosmii Cannon.
/// JS name: "GameCenter" (see www/index.html → GameCenter object).
@objc(GameCenterPlugin)
public class GameCenterPlugin: CAPPlugin, CAPBridgedPlugin, GKGameCenterControllerDelegate {
    public let identifier = "GameCenterPlugin"
    public let jsName = "GameCenter"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "signIn", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "submitScore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "unlockAchievement", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showLeaderboard", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showAchievements", returnType: CAPPluginReturnPromise)
    ]

    private var pendingSignIn: [CAPPluginCall] = []
    private var handlerInstalled = false

    @objc func signIn(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let player = GKLocalPlayer.local
            if player.isAuthenticated {
                call.resolve(self.playerInfo(error: nil))
                return
            }
            self.pendingSignIn.append(call)
            if self.handlerInstalled { return }
            self.handlerInstalled = true
            player.authenticateHandler = { [weak self] viewController, error in
                guard let self = self else { return }
                if let vc = viewController {
                    // Game Center wants to show its own sign-in sheet
                    self.bridge?.viewController?.present(vc, animated: true)
                    return
                }
                let result = self.playerInfo(error: error)
                let calls = self.pendingSignIn
                self.pendingSignIn.removeAll()
                calls.forEach { $0.resolve(result) }
            }
        }
    }

    private func playerInfo(error: Error?) -> [String: Any] {
        let p = GKLocalPlayer.local
        var r: [String: Any] = ["authenticated": p.isAuthenticated]
        if p.isAuthenticated {
            r["playerName"] = p.displayName
            r["playerId"] = p.gamePlayerID
        }
        if let e = error { r["error"] = e.localizedDescription }
        return r
    }

    @objc func submitScore(_ call: CAPPluginCall) {
        guard let leaderboardId = call.getString("leaderboardId"), let score = call.getInt("score") else {
            call.reject("leaderboardId and score are required"); return
        }
        guard GKLocalPlayer.local.isAuthenticated else { call.reject("Not signed in to Game Center"); return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardId]) { error in
            if let e = error { call.reject(e.localizedDescription) } else { call.resolve() }
        }
    }

    @objc func unlockAchievement(_ call: CAPPluginCall) {
        guard let achievementId = call.getString("achievementId") else { call.reject("achievementId is required"); return }
        guard GKLocalPlayer.local.isAuthenticated else { call.reject("Not signed in to Game Center"); return }
        let achievement = GKAchievement(identifier: achievementId)
        achievement.percentComplete = min(100, max(0, call.getDouble("percent") ?? 100))
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { error in
            if let e = error { call.reject(e.localizedDescription) } else { call.resolve() }
        }
    }

    @objc func showLeaderboard(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let vc: GKGameCenterViewController
            if let id = call.getString("leaderboardId") {
                vc = GKGameCenterViewController(leaderboardID: id, playerScope: .global, timeScope: .allTime)
            } else {
                vc = GKGameCenterViewController(state: .leaderboards)
            }
            vc.gameCenterDelegate = self
            self.bridge?.viewController?.present(vc, animated: true)
            call.resolve()
        }
    }

    @objc func showAchievements(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let vc = GKGameCenterViewController(state: .achievements)
            vc.gameCenterDelegate = self
            self.bridge?.viewController?.present(vc, animated: true)
            call.resolve()
        }
    }

    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
