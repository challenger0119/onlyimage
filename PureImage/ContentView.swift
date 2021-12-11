//
//  ContentView.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/20.
//

import SwiftUI
import WebKit

enum ButtonStatus {
    case view
    case boom
    
    func title() -> String {
        switch self {
        case .view:
            return "Boom!"
        case .boom:
            return "Web"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ContentView: View {
    @State private var url: String = ""
    @State private var images: [URLRequest] = []
    @State private var btnStatus: ButtonStatus = .boom
    @State private var webRequest: URLRequest?
    @State private var imageSize: CGFloat = 200 * imageSize1KB
    
    static var originUrl: URL!
    static var htmlInfo: HTMLInfo?
    
    init() {
        self.imageSize = SettingStore.shared.floatImageSize
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Input URL", text: $url, onCommit: {
                        boom()
                    })
                    .textContentType(.URL)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    Button("Clear", action: clear)
                    Button(btnStatus.title(), action: boom)
                }
                if btnStatus == .view {
                    WebView(request: $webRequest)
                } else {
                    ImageCollection(imageRequest: $images, size: $imageSize)
                }
                Spacer()
                HStack {
                    Button("Next", action: next)
                    Button("Back", action: back)
                    Spacer()
                    NavigationLink("Settings", destination: NavigationLazyView(SettingsView()))
                    Spacer()
                    Button("Back", action: back)
                    Button("Next", action: next)
                }
            }
            .padding()
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: settingsMinImageSizeUpdated)) { _ in
                self.imageSize = SettingStore.shared.floatImageSize
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    static func makeLoadRequest(url: URL, useReferer: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        if useReferer {
            request.setValue(Self.originUrl.absoluteString, forHTTPHeaderField: "Referer")
        }
        return request
    }
    
    func makeWebRequest(url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
    
    func currentUrl() -> URL? {
        if let url = WebView.pageUrl {
            return url.withHostFixed()
        }
        if let url = URL(string: self.url.lowercased()) {
            return url.withHostFixed()
        }
        return nil
    }
    
    func getOriginUrlFrom(url: URL) -> URL {
        guard var comp = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        comp.query = nil
        comp.path = ""
        return comp.url ?? url
    }
}

//MARK: - Btn Actions
extension ContentView {
    
    func boom() {
        UIApplication.endEdit()
        switch btnStatus {
        case .boom:
            guard let url = currentUrl() else { return }
            Self.originUrl = getOriginUrlFrom(url: url)
            self.webRequest = makeWebRequest(url: url)
            self.btnStatus = .view
        case .view:
            guard let url = currentUrl() else { return }
            self.showImages(url: url)
            self.btnStatus = .boom
        }
    }
    
    func clear() {
        UIApplication.endEdit()
        self.images = []
        self.btnStatus = .boom
        self.url = ""
        WebView.pageUrl = nil
    }
    
    func changePage(url: URL) {
        WebView.pageUrl = url
        showImages(url: url)
    }
    
    func next() {
        if let nextUrl = Self.htmlInfo?.nextPageLink {
            changePage(url: nextUrl)
        }
    }
    
    func back() {
        if let backUrl = Self.htmlInfo?.lastPageLink {
            changePage(url: backUrl)
        }
    }
    
    func openUrl() {
        if let url = WebView.pageUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//MARK: - HTML Parser
extension ContentView {
    
    func showImages(url: URL, currentImages: [URLRequest] = []) {
        print("showing image url: \(url)")
        var request = Self.makeLoadRequest(url: url, useReferer: SettingStore.shared.useReferer)
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { data, reponse, error in
            guard let data = data else {
                print("showImage error \(String(describing: error))")
                return
            }
            if let htmlString = String(data: data, encoding: .utf8) {
                parseHTML(htmlString, currentImages: currentImages)
            } else {
                print("reponse is not string \(String(describing: reponse))")
            }
        }.resume()
    }
    
    func parseHTML(_ html: String, currentImages: [URLRequest]) {
        let parser = HTMLParser(html: html, originUrl: Self.originUrl, nextPageName: SettingStore.shared.nextPageName, lastPageName: SettingStore.shared.lastPageName)
        guard let info = parser.parse() else {
            return
        }
        let infoImages = info.imageUrls.map({ url in
            return Self.makeLoadRequest(url: url, useReferer: SettingStore.shared.useReferer)
        })
        let isFirstParsing = currentImages.isEmpty
        
        var currentImages = currentImages
        currentImages.append(contentsOf: infoImages)
        
        if isFirstParsing {
            Self.htmlInfo = info
        } else {
            Self.htmlInfo = HTMLInfo(imageUrls: info.imageUrls, nextPageLink: info.nextPageLink, lastPageLink: Self.htmlInfo?.lastPageLink)
        }
        
        let minPicCount = SettingStore.shared.minImageCount
        if minPicCount > 0, currentImages.count < minPicCount, let next = info.nextPageLink {
            showImages(url: next, currentImages: currentImages)
        } else {
            self.images = currentImages
        }
        
        DLog(info.description)
    }
}
