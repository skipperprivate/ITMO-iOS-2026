//
//  GuideScreen.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import SwiftUI

struct GuideScreen: View {
    @StateObject private var viewModel = GuideViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.sections) { section in
                    GuideCard(
                        section: section,
                        isExpanded: viewModel.isExpanded(section),
                        onTap: { viewModel.toggleSection(section) }
                    )
                }
                
                
                Button {
                    dismiss()
                } label: {
                    Text("Вернуться назад")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brightPink)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color.lightBeige)
        .navigationTitle("Гайд")
        .navigationBarTitleDisplayMode(.inline)
    }
}


private struct GuideCard: View {
    let section: GuideSection
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.brightPink)
            
            if isExpanded {
                Text(section.content)
                    .font(.body)
                    .foregroundStyle(Color.darkGreen)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.lightBeige.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onTap()
            }
        }
    }
}
