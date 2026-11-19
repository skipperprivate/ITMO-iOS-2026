import SwiftUI

struct SectionHeader: View {

    let title: LocalizedStringResource

    var body: some View {
        HStack {
            Text(title)
                .font(.system(
                    size: 22,
                    weight: .bold
                ))
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
