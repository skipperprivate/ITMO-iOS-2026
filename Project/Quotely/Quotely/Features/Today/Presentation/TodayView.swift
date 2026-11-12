//
//  TodayView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct TodayView: View {
    @State private var viewModel = TodayViewModel()
    @AppStorage(SettingsStorage.Key.showAuthor) private var showAuthor = true

    private var favoriteActionTitle: LocalizedStringKey {
        viewModel.quote?.isFavorite == true ? "today.remove_favorite" : "today.favorite"
    }

    var body: some View {
        NavigationStack {
            Group {
                if let quote = viewModel.quote {
                    VStack(alignment: .leading, spacing: 20) {
                        Image(systemName: "quote.opening")
                            .font(.title2)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)

                        Text(quote.text)
                            .font(.title2.weight(.medium))

                        if showAuthor {
                            Text(quote.author)
                                .foregroundStyle(.secondary)
                        }

                        Button(favoriteActionTitle) {
                            viewModel.toggleFavorite()
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button {
                            viewModel.pickNew()
                        } label: {
                            Label("today.another", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                } else {
                    Text("today.empty")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("today.title")
        }
        .onAppear { viewModel.load() }
    }
}
