//
//  SettingsView.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/12/4.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct SettingsView: View {
    
    @State private var minImageSize: String
    @State private var nextPageName: String
    @State private var lastPageName: String
    @State private var useReferer: Bool
    @State private var minImageCount: String
    
    init() {
        self.minImageSize = SettingStore.shared.minImageSize
        self.nextPageName = SettingStore.shared.nextPageName
        self.lastPageName = SettingStore.shared.lastPageName
        self.useReferer = SettingStore.shared.useReferer
        self.minImageCount = "\(SettingStore.shared.minImageCount)"
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("The minimum image size (KB)")
                    Spacer()
                }
                HStack {
                    TextField("Input minimum image size", text: $minImageSize, onCommit: {
                        SettingStore.shared.minImageSize = self.minImageSize
                    })
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    Spacer()
                }.background(Color.white)
                    .cornerRadius(4.0)
            }
            .padding()
            .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
            
            VStack {
                HStack {
                    Text("The minimum image count")
                    Spacer()
                }
                HStack {
                    TextField("Input minimum image count", text: $minImageCount, onCommit: {
                        SettingStore.shared.minImageCount = Int(minImageCount) ?? 0
                    })
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    Spacer()
                }.background(Color.white)
                    .cornerRadius(4.0)
            }
            .padding()
            .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
            
            VStack {
                HStack {
                    Text("Next page name in target HTML")
                    Spacer()
                }
                HStack {
                    TextField("Input next page name", text: $nextPageName, onCommit: {
                        SettingStore.shared.nextPageName = self.nextPageName
                    })
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    Spacer()
                }.background(Color.white)
                    .cornerRadius(4.0)
            }
            .padding()
            .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
            
            VStack {
                HStack {
                    Text("Last page name in target HTML")
                    Spacer()
                }
                HStack {
                    TextField("Input last page name", text: $lastPageName, onCommit: {
                        SettingStore.shared.lastPageName = self.lastPageName
                    })
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    Spacer()
                }.background(Color.white)
                    .cornerRadius(4.0)
            }
            .padding()
            .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
            
            Toggle("Add 'Referer' in HTTP Header", isOn: $useReferer)
            .padding()
            .background(Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .onChange(of: useReferer, perform: { newValue in
            SettingStore.shared.useReferer = newValue
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
