import SwiftUI

struct TagFilterSheet: View {
    let selectedTags: [String: String?]
    let onTagClick: (String, String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            FilterGroup(
                title: "Пористость",
                options: ["Высокая", "Средняя", "Низкая"],
                selected: selectedTags["Пористость"] ?? nil,
                onClick: { onTagClick("Пористость", $0) }
            )
            FilterGroup(
                title: "Толщина",
                options: ["Толстые", "Тонкие"],
                selected: selectedTags["Толщина"] ?? nil,
                onClick: { onTagClick("Толщина", $0) }
            )
            FilterGroup(
                title: "Окрашенность",
                options: ["Да", "Нет"],
                selected: selectedTags["Окрашенность"] ?? nil,
                onClick: { onTagClick("Окрашенность", $0) }
            )
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.accentPink.opacity(0.1))
        .clipShape(
            .rect(
                bottomLeadingRadius: 24,
                bottomTrailingRadius: 24
            )
        )
    }
}

private struct FilterGroup: View {
    let title: String
    let options: [String]
    let selected: String?
    let onClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Golos", size: 16))
                .foregroundColor(.darkGreen)

            HStack(spacing: 8) {
                ForEach(options, id: \.self) { tag in
                    let isSelected = selected == tag

                    Text(tag)
                        .font(.custom("Golos", size: 13))
                        .foregroundColor(isSelected ? .white : .darkGreen)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.brightPink : Color.lightBeige)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onClick(tag)
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
