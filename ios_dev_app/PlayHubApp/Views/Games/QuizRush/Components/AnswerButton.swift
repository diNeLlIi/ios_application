import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct AnswerButton: View {
    let answer: String
    let isCorrectAnswer: Bool
    let selectedAnswer: String?
    let action: () -> Void

    @State private var shakeAmount: CGFloat = 0
    @State private var pressScale: CGFloat = 1.0

    private var isLocked: Bool { selectedAnswer != nil }

    private var backgroundColor: Color {
        guard isLocked else { return Color(.systemGray5) }
        if answer == selectedAnswer || answer == "__timeout__" {
            return isCorrectAnswer ? .green : .red
        }
        return Color(.systemGray5)
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                pressScale = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) { pressScale = 1.0 }
            }
            action()
        } label: {
            Text(answer)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(.primary)
                .cornerRadius(10)
        }
        .scaleEffect(pressScale)
        .modifier(ShakeEffect(animatableData: shakeAmount))
        .disabled(isLocked)
        .animation(.easeInOut(duration: 0.25), value: backgroundColor)
        .onChange(of: selectedAnswer) { _, newValue in
            guard newValue == answer, !isCorrectAnswer else { return }
            withAnimation(.linear(duration: 0.4)) {
                shakeAmount += 1
            }
        }
    }
}
