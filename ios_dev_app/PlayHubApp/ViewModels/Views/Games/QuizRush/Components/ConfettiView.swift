import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var rotation: Double
    var velocity: CGFloat
    var drift: CGFloat
    var rotationSpeed: Double
    var size: CGFloat
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let phase = Double(bitPattern: UInt64(bitPattern: Int64(truncatingIfNeeded: particle.id.hashValue)))
                        let elapsed = now + phase.truncatingRemainder(dividingBy: 1.0)
                        let y = particle.y + particle.velocity * CGFloat(elapsed) * 60
                        let x = particle.x + particle.drift * CGFloat(elapsed) * 30
                        let angle = Angle(degrees: particle.rotation + particle.rotationSpeed * elapsed * 60)

                        guard y < size.height + 20 else { continue }

                        var ctx = context
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: angle)

                        let rect = CGRect(x: -particle.size / 2, y: -particle.size / 2, width: particle.size, height: particle.size / 2)
                        ctx.fill(Path(rect), with: .color(particle.color))
                    }
                }
            }
            .onAppear { spawnParticles(width: proxy.size.width) }
        }
    }

    private func spawnParticles(width: CGFloat) {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: -200...0),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                velocity: CGFloat.random(in: 2...5),
                drift: CGFloat.random(in: -1...1),
                rotationSpeed: Double.random(in: -3...3),
                size: CGFloat.random(in: 6...14)
            )
        }
    }
}
