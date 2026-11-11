//
//  GuideScreen.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026. обновленно 19.10.2026
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
            }
            .padding(24)
        }
        .background(Color(hex: "F8F4ED").ignoresSafeArea())
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
            HStack(alignment: .center) {
                Text(section.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "4A5B48"))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: "728C6A"))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
            }
            
            if isExpanded {
                Text(section.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(hex: "4A5B48").opacity(0.8))
                    .lineSpacing(4)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onTap()
            }
        }
    }
}
