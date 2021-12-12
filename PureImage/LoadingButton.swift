//
//  LoadingBtn.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/12/12.
//

import Foundation
import SwiftUI

struct LoadingButton<T: View>: View {
    
    let action: () -> Void
    let label: () -> T
    @Binding var isLoading: Bool
    
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
    let action: () -> Void
    
    var body: some View {
        LoadingButton(action: action, label: {
            Text(content)
        }, isLoading: $isLoading)
    }
}
