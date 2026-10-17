//
//  FirstView.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 24.09.2026.
//

import SwiftUI

struct FirstView: View {
    @StateObject private var viewModel = GenerateNumberViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(viewModel.numberText)
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        viewModel.generateButtonTapped()
                    } label: {
                        Text("Random number")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    NavigationLink {
                        SecondView()
                    } label: {
                        Text("Second View")
                        .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
        }
        .padding()
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
