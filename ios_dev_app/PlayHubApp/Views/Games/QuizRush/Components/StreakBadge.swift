import SwiftUI

struct StreakBadge: View {
    let streak: Int

    private var flameScale: CGFloat {
        switch streak {
        case 0: return 0
        case 1...2: return 0.9
        case 3...5: return 1.1
        default: return 1.3
        }
    }

    private var flameColor: Color {
        switch streak {
        case 0: return .clear
        case 1...2: return .orange
        case 3...5: return .red
        default: return .pink
        }
    }

    var body: some View {
        if streak > 0 {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.title2)
                    .scaleEffect(flameScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: streak)

                Text("×\(streak)")
                    .font(.headline.bold())
                    .foregroundColor(flameColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: streak)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(flameColor.opacity(0.15))
            .clipShape(Capsule())
            .transition(.scale.combined(with: .opacity))
        }
    }
}
