import SwiftUI

struct OneFilmView: View {
    @StateObject private var viewModel: OneFilmViewModel
    
    let onShowFunFact: (String) -> Void
    let onShowViewedFacts: () -> Void
    
    init(
        viewModel: @autoclosure @escaping() -> OneFilmViewModel,
        onShowFunFact: @escaping (String) -> Void,
        onShowViewedFacts: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onShowFunFact = onShowFunFact
        self.onShowViewedFacts = onShowViewedFacts
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(
                    Color(red: 0.72, green: 0.48, blue: 0.57)
                        .opacity(0.12)
                )
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 150, y: -250)
            
            content
        }
        .task {
            await viewModel.load()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onShowViewedFacts()
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
            
        case .loaded(let film):
            filmContent(film)
            
        case .offline:
            OfflineView(
                onRetry: {
                    Task {
                        await viewModel.retry()
                    }
                },
                onShowViewedFacts: {
                    onShowViewedFacts()
                }
            )
            
        case .error(let message):
            VStack(spacing: 18) {
                Spacer()
                
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        Color(red: 0.72, green: 0.48, blue: 0.57)
                    )
                    .frame(width: 120, height: 120)
                    .background(
                        Color(red: 0.72, green: 0.48, blue: 0.57)
                            .opacity(0.10),
                        in: RoundedRectangle(cornerRadius: 34)
                    )
                
                Text("Не удалось загрузить фильм")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button {
                    Task {
                        await viewModel.retry()
                    }
                } label: {
                    Label("Повторить", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color(red: 0.72, green: 0.48, blue: 0.57),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func filmContent(_ film: OneFilmModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                poster(film)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(film.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    
                    if let originalTitle = film.originalTitle {
                        Text(originalTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                filmInfo(film)
                
                if let description = film.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("О фильме")
                            .font(.headline)
                        
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    // Настройка спойлеров
                    Toggle(
                        isOn: Binding(
                            get: { viewModel.hideSpoilers },
                            set: { viewModel.setHideSpoilers($0) }
                        )
                    ) {
                        Label {
                            Text("Скрывать спойлеры")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } icon: {
                            Image(systemName: "eye.slash")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Color(red: 0.72, green: 0.48, blue: 0.57))
                    .padding(16)
                    .background(
                        Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    
                    // Переход к интересному факту
                    Button {
                        onShowFunFact(film.title)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                            
                            Text("Интересный факт")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(
                            Color(red: 0.65, green: 0.38, blue: 0.49)
                        )
                        .padding(16)
                        .background(
                            Color(red: 0.72, green: 0.48, blue: 0.57)
                                .opacity(0.09),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
        }
    }
    
    private func poster(_ film: OneFilmModel) -> some View {
        AsyncImage(url: URL(string: film.posterURL)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(.gray.opacity(0.15))
                .overlay {
                    ProgressView()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func filmInfo(_ film: OneFilmModel) -> some View {
        HStack(spacing: 12) {
            if let rating = film.kinopoiskRating {
                Label(
                    String(format: "%.1f", rating),
                    systemImage: "star.fill"
                )
            }
            
            if let year = film.year {
                Text(String(year))
            }
            
            if let length = film.filmLength {
                Text("\(length) мин")
            }
            
            if let ageLimit = film.ageLimit {
                Text(ageLimit.replacingOccurrences(of: "age", with: "") + "+")
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.secondary)
    }
}
