//
//  RecipeInstructionsView.swift
//  RecipeBox
//
//  Created by nktmahov on 09.10.26.
//

import SwiftUI

struct RecipeInstructionsView: View {
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Приготовление")
                .font(.title2.bold())
            Text(instructions.isEmpty ? "Инструкция отсутствует." : instructions)
                .textSelection(.enabled)
        }
        .padding(.horizontal)
    }
}
