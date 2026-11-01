//
//  RecipeEditorView.swift
//  RecipeBox
//
//  Created by nktmahov on 14.10.26.
//

import AVFoundation
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct RecipeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let recipe: UserRecipe?

    @State private var title: String
    @State private var recipeDescription: String
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var errorMessage: String?

    init(recipe: UserRecipe?) {
        self.recipe = recipe
        _title = State(initialValue: recipe?.title ?? "")
        _recipeDescription = State(initialValue: recipe?.recipeDescription ?? "")
        _imageData = State(initialValue: recipe?.imageData)
    }

    var body: some View {
        Form {
            RecipePhotoSection(
                imageData: imageData,
                selectedPhoto: $selectedPhoto,
                openCamera: openCamera,
                removePhoto: { imageData = nil }
            )

            Section("Рецепт") {
                TextField("Название", text: $title)
                TextField(
                    "Описание и способ приготовления",
                    text: $recipeDescription,
                    axis: .vertical
                )
                .lineLimit(6...14)
            }
        }
        .navigationTitle(recipe == nil ? "Новый рецепт" : "Редактирование")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                do {
                    imageData = try await newItem.loadTransferable(type: Data.self)
                } catch {
                    errorMessage = "Не удалось загрузить выбранное изображение."
                }
            }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPicker { data in
                imageData = data
            }
            .ignoresSafeArea()
        }
        .alert(
            "Фотография недоступна",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("ОК") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "На этом устройстве нет доступной камеры."
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPresented = true
        case .notDetermined:
            Task {
                let isGranted = await AVCaptureDevice.requestAccess(for: .video)
                if isGranted {
                    isCameraPresented = true
                } else {
                    errorMessage = "Разрешите доступ к камере в настройках устройства."
                }
            }
        case .denied, .restricted:
            errorMessage = "Разрешите доступ к камере в настройках устройства."
        @unknown default:
            errorMessage = "Камера сейчас недоступна."
        }
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let recipe {
            recipe.title = cleanTitle
            recipe.recipeDescription = cleanDescription
            recipe.imageData = imageData
            recipe.updatedAt = .now
        } else {
            modelContext.insert(
                UserRecipe(
                    title: cleanTitle,
                    recipeDescription: cleanDescription,
                    imageData: imageData
                )
            )
        }
        dismiss()
    }
}
