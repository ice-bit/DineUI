//
//  ItemImage.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/06/24.
//

import SwiftUI
import PhotosUI

struct ItemImage: View {
    let imageState: MenuItemPhotoModal.ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image.resizable()
        case .empty:
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        case .loading:
            ProgressView()
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

struct RectangleItemImage: View {
    let imageState: MenuItemPhotoModal.ImageState
    
    var body: some View {
        ItemImage(imageState: imageState)
            .scaledToFill()
            .clipShape(.rect(cornerRadius: 16))
            .frame(width: 100, height: 100)
            .background {
                Rectangle().fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(.rect(cornerRadius: 16))
            }
    }
}

struct EditableRectangleItemImage: View {
    @ObservedObject var viewModal: MenuItemPhotoModal
    
    var body: some View {
        RectangleItemImage(imageState: viewModal.imageState)
            .overlay(alignment: .bottomTrailing) {
                PhotosPicker(
                    selection:$viewModal.imageSelection,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 30))
                        .foregroundStyle(.app)
                }
            }
    }
}
