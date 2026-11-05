//
//  EmptyStateView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String?
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
            
            Text(title).font(.headline)
            
            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding()
    }
}
