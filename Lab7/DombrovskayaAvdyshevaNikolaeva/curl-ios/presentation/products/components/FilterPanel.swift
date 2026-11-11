import SwiftUI

struct FilterPanel: View {
    let porosityTag: String?
    let coloringTag: String?
    let thicknessTag: String?
    let onTagClick: (String, String) -> Void
    let onReset: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TagFilterSheet(
                selectedTags: [
                    "Пористость": porosityTag,
                    "Окрашенность": coloringTag,
                    "Толщина": thicknessTag
                ],
                onTagClick: onTagClick,
                onClose: onSave
            )

            Spacer().frame(height: 12)

            HStack {
                Button(action: onReset) {
                    Text("Сбросить фильтры")
                        .font(.footnote)
                        .foregroundColor(.lightBeige)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.brightPink)
                        .cornerRadius(12)
                }

                Spacer()

                Button(action: onSave) {
                    Text("Сохранить")
                        .font(.footnote)
                        .foregroundColor(.lightBeige)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.darkGreen)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.lightBeige
                .clipShape(
                    .rect(
                        bottomLeadingRadius: 24,
                        bottomTrailingRadius: 24
                    )
                )
        )
        .padding(16)
    }
}
