import SwiftUI

struct FilterPanel: View {
    let porosityTag: String?
    let coloringTag: String?
    let thicknessTag: String?
    let onTagClick: (String, String) -> Void
    let onReset: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TagFilterSheet(
                selectedTags: [
                    "Пористость": porosityTag,
                    "Окрашенность": coloringTag,
                    "Толщина": thicknessTag
                ],
                onTagClick: onTagClick,
                onClose: onSave
            )

            HStack(spacing: 12) {
                Button(action: onReset) {
                    Text("Сбросить")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(.curlyDarkGreen))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.curlyDarkGreen).opacity(0.4), lineWidth: 1)
                        )
                }

                Button(action: onSave) {
                    Text("Сохранить")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.curlyGreen))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
