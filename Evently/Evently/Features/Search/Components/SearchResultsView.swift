import SwiftUI

struct SearchResultsView: View {
    let events: [Event]
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    NavigationLink(value: AppRoute.eventDetails(event)) {
                        EventCard(event: event)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if event.id == events.last?.id { onLoadMore() }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
