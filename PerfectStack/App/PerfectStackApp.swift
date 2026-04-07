import SwiftUI

@main
struct PerfectStackApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appModel)
        }
    }
}

struct AppRootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ZStack {
            switch appModel.route {
            case .home:
                HomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .gameplay(let session):
                GameView(
                    session: session,
                    theme: appModel.themeCatalog.theme(id: session.themeID),
                    settings: appModel.settings,
                    analytics: appModel.analytics,
                    persistence: appModel.persistence,
                    audioManager: appModel.audioManager,
                    hapticsManager: appModel.hapticsManager,
                    onComplete: { appModel.completeRun($0) },
                    onExit: { appModel.returnHome() }
                )
                .transition(.opacity)
            case .results(let summary):
                ResultsView(
                    summary: summary,
                    theme: appModel.themeCatalog.theme(id: summary.themeID),
                    analytics: appModel.analytics,
                    onReplay: { appModel.replayCurrentRun() },
                    onHome: { appModel.returnHome() }
                )
                .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.9), value: appModel.routeID)
    }
}
