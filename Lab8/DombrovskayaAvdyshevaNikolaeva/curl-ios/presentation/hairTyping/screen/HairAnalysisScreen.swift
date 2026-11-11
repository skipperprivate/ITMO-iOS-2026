import SwiftUI
import PhotosUI

struct HairAnalysisScreen: View {
    let onSaveComplete: () -> Void

    @StateObject private var viewModel = HairAnalysisViewModel()
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showSheet = false
    @State private var showSaveAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Определение пористости")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(Color(.curlyDarkGreen))
                    .padding(.top, 16)

                descriptionText

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
                    .background(Color(.curlyGreen))
                    .cornerRadius(30)
                }

                Spacer(minLength: 24)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.curlySurface).ignoresSafeArea())
        .onChange(of: photoItem) { _, newItem in
            handlePhotoChange(newItem)
        }
        .sheet(isPresented: $showSheet) {
            resultSheet
                .presentationDetents([.height(240), .medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color("curlyTerracotta"))
        }
        .onChange(of: viewModel.saved) { _, newValue in
            guard newValue != nil else { return }
            showSaveAlert = true
        }
        .alert("Сохранение", isPresented: $showSaveAlert) {
            Button("OK") {
                if viewModel.saved == true { onSaveComplete() }
                viewModel.clearSaved()
            }
        } message: {
            alertMessage
        }
    }

    private var descriptionText: some View {
        Text("Загрузи фото, на котором хорошо видно твои волосы.\nЖелательно — со спины или вид сбоку.\n\nНейросеть определит тип за пару секунд")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color(.curlyDarkGreen))
            .lineSpacing(6)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.curlySurfaceMuted))
            .cornerRadius(24)
    }

    private var alertMessage: Text {
        if viewModel.saved == true {
            return Text("Успешно сохранено")
        } else {
            return Text("Ошибка сохранения")
        }
    }

    private func handlePhotoChange(_ newItem: PhotosPickerItem?) {
        Task {
            guard
                let data = try? await newItem?.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else { return }
            selectedImage = image
            showSheet = true
            viewModel.analyze(imageData: data)
        }
    }

    private var resultSheet: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView().tint(.white)
                Text("Ожидаем анализ…")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            } else if let error = viewModel.error {
                Text("Ошибка: \(error)")
                    .foregroundColor(.white)
            } else if let resultText = viewModel.result {
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
                        showSheet = false
                        viewModel.saveResult()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("curlyTerracotta"))
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
}
