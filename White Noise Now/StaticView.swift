import SwiftUI

struct StaticView: View {
    @Binding var noiseTrigger: UUID
    private let cellSize: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let columns = Int(size.width / cellSize)
                let rows = Int(size.height / cellSize)

                for x in 0..<columns {
                    for y in 0..<rows {
                        let changeProbability = Double.random(in: 0.2...1.0) // 🔥 Randomized flicker intensity
                        if changeProbability > 0.5 {
                            let randomGray = Double.random(in: 0...1)
                            let rect = CGRect(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize, width: cellSize, height: cellSize)
                            context.fill(Path(rect), with: .color(Color(white: randomGray)))
                        }
                    }
                }
            }
            .id(noiseTrigger) // 🔥 Instantly refreshes static
        }
        .ignoresSafeArea()
    }
}
