import SwiftUI

struct FeaturedEventCard: View {
    let event: Event

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            eventImage
            imageGradient
            eventInformation
                .padding(18)
        }
        .frame(width: 310, height: 210)
        .clipShape(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private var eventImage: some View {
        AsyncImage(url: event.imageURL) { phase in
            switch phase {
            case .empty:
                imageBackground
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                imageBackground
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    }

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 310, height: 210)
        .clipped()
    }

    private var imageBackground: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.25))
    }

    private var imageGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.9)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    private var eventInformation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.category.rawValue.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))

            Text(event.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)

            dateLabel
            venueAndPrice
        }
    }

    private var dateLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
            Text(
                event.date.formatted(
                    .dateTime.day().month(.abbreviated).hour().minute()
                )
            )
        }
        .font(.system(size: 13))
        .foregroundStyle(.white.opacity(0.8))
    }

    private var venueAndPrice: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text(event.venue)
            Spacer()

            if let price = event.price {
                Text(price)
                    .fontWeight(.semibold)
            }
        }
        .font(.system(size: 13))
        .foregroundStyle(.white.opacity(0.8))
    }
}
