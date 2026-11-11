import SwiftUI

struct ReviewItem: View {
    let review: Review
    let showMenu: Bool
    let onEditClick: (() -> Void)?
    let onDeleteClick: (() -> Void)?

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .fontWeight(.bold)
                        .foregroundColor(.darkGreen)

                    Text(review.createdAt.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundColor(i <= review.rating ? .accentPink : .gray)
                    }
                }

                Spacer().frame(width: 12)

                if showMenu {
                    Menu {
                        if let onEditClick {
                            Button {
                                onEditClick()
                            } label: {
                                Label("Редактировать", systemImage: "pencil")
                            }
                        }
                        if let onDeleteClick {
                            Button(role: .destructive) {
                                onDeleteClick()
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .frame(width: 24, height: 24)
                    }
                } else {
                    Spacer().frame(width: 24)
                }
            }

            Text(review.comment)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}
