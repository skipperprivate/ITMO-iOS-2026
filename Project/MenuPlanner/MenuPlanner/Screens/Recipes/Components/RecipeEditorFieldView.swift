import SwiftUI

struct RecipeEditorFieldView<Content: View>: View {
    let error: String?
    var reservesErrorSpace = true
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(error == nil ? Color.clear : Color.red, lineWidth: 1.5)
                        .transaction { $0.animation = nil }
                }
            if reservesErrorSpace {
                RecipeValidationMessage(error: error)
            }
        }
    }
}

struct RecipeValidationMessage: View {
    let error: String?

    var body: some View {
        Text(error ?? " ")
            .font(AppFonts.small)
            .foregroundStyle(.red)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .opacity(error == nil ? 0 : 1)
            .transaction { $0.animation = nil }
    }
}
