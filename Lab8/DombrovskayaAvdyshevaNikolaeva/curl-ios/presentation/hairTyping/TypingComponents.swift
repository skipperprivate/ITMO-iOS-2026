import SwiftUI

struct TypingProgressBar: View {
    let current: Int
    let total: Int
    let color: Color
    
    var body: some View {
        let progress = CGFloat(current + 1) / CGFloat(total)
        
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.curlyOrangeNeg)
                .frame(height: 20)
            
            Capsule()
                .fill(color)
                .frame(width: UIScreen.main.bounds.width * progress - 80, height: 20)
                .overlay(
                    Text("\(current + 1)/\(total)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Color.curlyOrangeNeg)
                )
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}
