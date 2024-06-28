//
//  AddItem.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/06/24.
//

import SwiftUI

struct AddItem: View {
    @ObservedObject var viewModal = MenuItemPhotoModal()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    EditableRectangleItemImage(viewModal: viewModal)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AddItem()
}
