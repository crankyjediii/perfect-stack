import SwiftUI

struct SettingsSheet: View {
    let settings: SettingsStore
    let theme: Theme

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            ZStack {
                AmbientBackground(theme: theme)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        GlassCard(theme: theme) {
                            Toggle("Sound", isOn: $settings.soundEnabled)
                                .tint(theme.accent)
                            Toggle("Haptics", isOn: $settings.hapticsEnabled)
                                .tint(theme.accent)
                            Toggle("Reduced Motion", isOn: $settings.reducedMotionEnabled)
                                .tint(theme.accent)
                        }

                        GlassCard(theme: theme) {
                            Text("Guidelines")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text("Perfect Stack stays intentionally focused: instant play, quiet menus, and feedback reserved for perfects, streaks, and new-best moments.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.primaryText)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

