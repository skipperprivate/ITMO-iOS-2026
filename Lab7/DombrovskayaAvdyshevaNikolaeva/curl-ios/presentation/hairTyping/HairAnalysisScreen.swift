import SwiftUI
import PhotosUI

struct HairAnalysisScreen: View {
    let onSaveComplete: () -> Void

    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showSheet = false
    @State private var isLoading = false
    @State private var resultText: String?
    @State private var errorText: String?
    @State private var showSaveAlert = false
    @State private var saveError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Определение пористости")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "4A5B48"))
                    .padding(.top, 16)

                Text("Загрузи фото, на котором хорошо видно твои волосы.\nЖелательно — со спины или вид сбоку.\n\nНейросеть определит тип за пару секунд")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48"))
                    .lineSpacing(6)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "EDE9E1"))
                    .cornerRadius(24)

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipped()
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }

                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Загрузить фото")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "728C6A"))
                    .cornerRadius(30)
                }

                Spacer(minLength: 24)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(hex: "F8F4ED").ignoresSafeArea())
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    analyzeImage(data)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            resultSheet
                .presentationDetents([.height(240), .medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(hex: "C17A5B"))
        }
        .alert("Сохранение", isPresented: $showSaveAlert) {
            Button("OK") { onSaveComplete() }
        } message: {
            Text(saveError ? "Ошибка сохранения" : "Успешно сохранено")
        }
    }

    private var resultSheet: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView()
                    .tint(.white)
                Text("Ожидаем анализ…")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            } else if let errorText {
                Text("Ошибка: \(errorText)")
                    .foregroundColor(.white)
            } else if let resultText {
                Text("Тип волос: \(resultText.uppercased())")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    Button("Не сохранять") { showSheet = false }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))

                    Button("Сохранить") {
                        saveError = false
                        showSheet = false
                        showSaveAlert = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "C17A5B"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private func analyzeImage(_ data: Data) {
        isLoading = true
        showSheet = true
        errorText = nil
        resultText = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            resultText = "Пористый"
        }
    }
}
