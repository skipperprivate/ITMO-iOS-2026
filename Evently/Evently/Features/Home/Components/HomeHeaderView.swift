import SwiftUI

struct HomeHeaderView: View {

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("home.title")
                    .font(.system(
                        size: 28,
                        weight: .bold
                    ))
            }

            Spacer()

//            BellButton()
        }
        .padding(.horizontal, 20)
    }
}
