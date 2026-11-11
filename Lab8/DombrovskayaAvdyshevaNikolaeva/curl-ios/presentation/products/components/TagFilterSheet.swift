import SwiftUI

struct TagFilterSheet: View {
    let selectedTags: [String: String?]
    let onTagClick: (String, String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
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
        .frame(maxWidth: .infinity)
    }
}

private struct FilterGroup: View {
    let title: String
    let options: [String]
    let selected: String?
    let onClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.curlyDarkGreen))

            HStack(spacing: 8) {
                ForEach(options, id: \.self) { tag in
                    let isSelected = selected == tag

                    Text(tag)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color(.curlyDarkGreen))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color(.curlyGreen) : Color(.curlySurface))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture { onClick(tag) }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
