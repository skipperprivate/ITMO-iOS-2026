//
//  SecondView.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 24.09.2026.
//

import SwiftUI

struct SecondView: View {
    @StateObject private var viewModel = SecondViewModel()
    
    var body: some View {
        List {
            if viewModel.records.isEmpty {
                Text("История пуста")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.records) { record in
                    HStack {
                        Text("\(record.value)")
                        Spacer()
                        if let date = record.date {
                            Text(date, format: .dateTime.hour().minute().second())
                        }
                    }
                }
            }
        }
        .navigationTitle("История")
        .toolbar {
            Button(role: .destructive) {
                viewModel.deleteAll()
            } label: {
                Image(systemName: "trash")
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
