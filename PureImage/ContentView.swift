//
//  ContentView.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/20.
//

import SwiftUI
import WebKit

enum URLBtnStatus {
    case open
    case reset
    
    func title() -> String {
        switch self {
        case .open:
            return I18N.s("浏览")
        case .reset:
            return I18N.s("重置")
        }
    }
}

enum BoomBtnStatus {
    case boom
    case boomed
    
    func title() -> String {
        switch self {
        case .boom:
            return I18N.s("提取图片")
        case .boomed:
            return I18N.s("返回网页")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
        ContentView().preferredColorScheme(.dark)
    }
}

struct PIButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) var currentMode
    @Environment(\.isEnabled) var isEnabled
    
    var textColor: Color {
        if currentMode == .light {
            return isEnabled ? Color(white: 0.3) : Color(white: 0.6)
        } else {
            return isEnabled ? Color(white: 0.7) : Color(white: 0.4)
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(currentMode == .light ? Color(.sRGB, red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0) : Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1.0))
            .cornerRadius(4)
            .foregroundColor(textColor)
    }
}

struct ContentView: View {
    @State private var url: String = ""
    @State private var images: [URLRequest] = []
    @State private var urlBtnStatus: URLBtnStatus = .open
    @State private var boomBtnStatus: BoomBtnStatus = .boom
    @State private var webRequest: URLRequest?
    @State private var imageSize: CGFloat = 200 * imageSize1KB
    @State private var pageBtnLeft: Bool
    @State private var htmlInfo: HTMLInfo?
    @State private var isRequestingNext: Bool = false
    @State private var isRequestingLast: Bool = false
    
    static var originUrl: URL!
    
    init() {
        _imageSize = State(initialValue: SettingStore.shared.floatImageSize)
        _pageBtnLeft = State(initialValue: SettingStore.shared.pageBtnLeft)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if urlBtnStatus == .open {
                        TextField(I18N.s("URL"), text: $url, onCommit: {
                            urlAction()
                        })
                        .textContentType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    } else {
                        Spacer()
                    }
                    
                    Button(urlBtnStatus.title(), action: urlAction)
                        .buttonStyle(PIButtonStyle())
                        .font(.system(size: 14))
                    if urlBtnStatus == .reset {
                        Button(boomBtnStatus.title(), action: boom)
                            .buttonStyle(PIButtonStyle())
                            .font(.system(size: 14))
                    }
                }
                if urlBtnStatus == .reset && boomBtnStatus == .boom {
                    WebView(request: $webRequest)
                } else {
                    ImageCollection(imageRequest: $images, size: $imageSize)
                }
                
                Spacer()
                HStack {
                    if pageBtnLeft {
                        TextLoadingButton(isLoading: $isRequestingNext, content:SettingStore.shared.nextPageName, action: next)
                            .buttonStyle(PIButtonStyle())
                            .disabled(htmlInfo?.nextPageLink == nil ? true : false)
                        
                        TextLoadingButton(isLoading: $isRequestingLast, content:SettingStore.shared.lastPageName, action: back)
                            .buttonStyle(PIButtonStyle())
                            .disabled(htmlInfo?.lastPageLink == nil ? true : false)
                        Spacer()
                    }
                    
                    NavigationLink(I18N.s("设置"), destination: NavigationLazyView(SettingsView()))
                        .buttonStyle(PIButtonStyle())
                        .font(.system(size: 14))

                    if !pageBtnLeft {
                        Spacer()
                        TextLoadingButton(isLoading: $isRequestingLast, content:SettingStore.shared.lastPageName, action: back)
                            .buttonStyle(PIButtonStyle())
                            .disabled(htmlInfo?.lastPageLink == nil ? true : false)
                        TextLoadingButton(isLoading: $isRequestingNext, content: SettingStore.shared.nextPageName, action: next)
                            .buttonStyle(PIButtonStyle())
                            .disabled(htmlInfo?.nextPageLink == nil ? true : false)
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: settingsMinImageSizeUpdated)) { _ in
                self.imageSize = SettingStore.shared.floatImageSize
            }
            .onReceive(NotificationCenter.default.publisher(for: settingsPageBtnLeftUpdated)) { _ in
                self.pageBtnLeft = SettingStore.shared.pageBtnLeft
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
    func urlAction() {
        UIApplication.endEdit()
        switch urlBtnStatus {
        case .open:
            guard let url = currentUrl() else { return }
            Self.originUrl = getOriginUrlFrom(url: url)
            self.webRequest = makeWebRequest(url: url)
            urlBtnStatus = .reset
        case .reset:
            clear()
            urlBtnStatus = .open
        }
    }
    
    func boom() {
        switch boomBtnStatus {
        case .boomed:
            guard let url = currentUrl() else { return }
            Self.originUrl = getOriginUrlFrom(url: url)
            self.webRequest = makeWebRequest(url: url)
            self.boomBtnStatus = .boom
        case .boom:
            guard let url = currentUrl() else { return }
            isRequestingNext = true
            isRequestingLast = true
            self.showImages(url: url) { _ in
                isRequestingNext = false
                isRequestingLast = false
            }
            self.boomBtnStatus = .boomed
        }
    }
    
    func clear() {
        UIApplication.endEdit()
        images = []
        boomBtnStatus = .boom
        urlBtnStatus = .open
        url = ""
        htmlInfo = nil
        WebView.pageUrl = nil
    }
    
    func changePage(url: URL, completion: @escaping (Bool) -> Void) {
        WebView.pageUrl = url
        showImages(url: url, completion: completion)
    }
    
    func next() {
        if let nextUrl = htmlInfo?.nextPageLink {
            isRequestingNext = true
            changePage(url: nextUrl) { _ in
                isRequestingNext = false
            }
        }
    }
    
    func back() {
        if let backUrl = htmlInfo?.lastPageLink {
            isRequestingLast = true
            changePage(url: backUrl) { _ in
                isRequestingLast = false
            }
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
    
    func showImages(url: URL, currentImages: [URLRequest] = [], completion: @escaping (Bool) -> Void) {
        print("showing image url: \(url)")
        var request = Self.makeLoadRequest(url: url, useReferer: SettingStore.shared.useReferer)
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { data, reponse, error in
            guard let data = data else {
                print("showImage error \(String(describing: error))")
                completion(false)
                return
            }
            if let htmlString = String(data: data, encoding: .utf8) {
                parseHTML(htmlString, currentImages: currentImages, completion: completion)
            } else {
                print("reponse is not string \(String(describing: reponse))")
            }
            completion(true)
        }.resume()
    }
    
    func parseHTML(_ html: String, currentImages: [URLRequest], completion:@escaping (Bool) -> Void) {
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
            htmlInfo = info
        } else {
            htmlInfo = HTMLInfo(imageUrls: info.imageUrls, nextPageLink: info.nextPageLink, lastPageLink: htmlInfo?.lastPageLink)
        }
        
        let minPicCount = SettingStore.shared.minImageCount
        if minPicCount > 0, currentImages.count < minPicCount, let next = info.nextPageLink {
            showImages(url: next, currentImages: currentImages, completion: completion)
        } else {
            self.images = currentImages
        }
        
        DLog(info.description)
    }
}
