import SwiftUI

struct TimerRing: View {
    let timeRemaining: Double
    let total: Double

    private var progress: Double { timeRemaining / total }

    private var ringColor: Color {
        if progress > 0.6 { return .green }
        if progress > 0.3 { return .orange }
        return .red
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 5)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            Text("\(Int(timeRemaining.rounded(.up)))")
                .font(.caption.bold())
                .foregroundColor(ringColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: Int(timeRemaining))
        }
        .frame(width: 52, height: 52)
    }
}
