//
//  ImageView.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/26.
//

import SwiftUI

struct ImageView: View {
    
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    
    var tap: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                if (self.scale >= 3) {
                    self.scale = 1.0
                } else {
                    self.scale = 3
                }
            }
    }
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.vertical, .horizontal]) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                .padding()
                .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
            }
        }
        .padding()
        .gesture(
            MagnificationGesture(minimumScaleDelta: 0.1)
                .onChanged({ scale in
                    self.scale = fmax(scale, 1.0)
                })
        )
        .navigationBarItems(trailing: Button("Save", action: save))
        .gesture(tap)
    }
    
    func save() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct ImageViewController_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: UIImage(systemName: "gearshape")!)
    }
}
