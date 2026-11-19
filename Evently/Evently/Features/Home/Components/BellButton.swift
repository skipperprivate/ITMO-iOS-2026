import SwiftUI

//  struct BellButton<Destination: View>: View {
struct BellButton: View {
//    let destination: () -> Destination

    var body: some View {
        Button {
//            destination()
        } label: {
            Image(systemName: "bell.fill")
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .frame(
                    width: 44,
                    height: 44
                )
                .background(
                    Color.white.opacity(0.09)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
