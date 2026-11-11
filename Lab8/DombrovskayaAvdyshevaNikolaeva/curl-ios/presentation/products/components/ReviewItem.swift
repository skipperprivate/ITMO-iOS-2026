import SwiftUI

struct ReviewItem: View {
    let review: Review
    let showMenu: Bool
    let onEditClick: (() -> Void)?
    let onDeleteClick: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.curlyDarkGreen))

                    Text(review.createdAt.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                        .font(.system(size: 12))
                        .foregroundColor(Color(.curlyDarkGreen).opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { starIndex in
                        Image(systemName: starIndex <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(starIndex <= review.rating ? Color(.curlyAccentPink) : Color(.curlyDarkGreen).opacity(0.25))
                    }
                }

                Spacer().frame(width: 8)

                if showMenu {
                    Menu {
                        if let onEditClick {
                            Button { onEditClick() } label: {
                                Label("Редактировать", systemImage: "pencil")
                            }
                        }
                        if let onDeleteClick {
                            Button(role: .destructive) { onDeleteClick() } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(.curlyDarkGreen).opacity(0.5))
                            .frame(width: 24, height: 24)
                    }
                }
            }

            Text(review.comment)
                .font(.system(size: 14))
                .foregroundColor(Color(.curlyDarkGreen).opacity(0.75))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}
