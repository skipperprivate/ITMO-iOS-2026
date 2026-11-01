//
//  RecipePhotoSection.swift
//  RecipeBox
//
//  Created by nktmahov on 10.10.26.
//

import PhotosUI
import SwiftUI
import UIKit

struct RecipePhotoSection: View {
    let imageData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    let openCamera: () -> Void
    let removePhoto: () -> Void

    var body: some View {
        Section("Фотография") {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .frame(maxWidth: .infinity)

                Button("Удалить фотографию", role: .destructive) {
                    removePhoto()
                }
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Выбрать из галереи", systemImage: "photo.on.rectangle")
            }

            Button(action: openCamera) {
                Label("Снять на камеру", systemImage: "camera")
            }
        }
    }
}
