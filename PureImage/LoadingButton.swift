//
//  LoadingBtn.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/12/12.
//

import Foundation
import SwiftUI

struct LoadingButton<T: View>: View {
    @Binding var isLoading: Bool
    let action: () -> Void
    let label: () -> T
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                label()
            }
        }
    }
}

struct TextLoadingButton: View {
    @Binding var isLoading: Bool
    let content: String
    let font: Font = Font.system(size: 14)
    let action: () -> Void
    
    var body: some View {
        LoadingButton(isLoading: $isLoading, action: action, label: {
            Text(content)
                .font(font)
        })
    }
}
