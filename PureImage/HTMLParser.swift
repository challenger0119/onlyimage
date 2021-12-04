//
//  HTMLParser.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/27.
//

import Foundation

struct HTMLInfo: CustomStringConvertible {
    
    let imageUrls: [URL]
    let nextPageLink: URL?
    let lastPageLink: URL?
    
    var description: String {
        return "HTMLInfo - imageUrl: \(imageUrls) next: \(nextPageLink?.absoluteString ?? "") last: \(lastPageLink?.absoluteString ?? "")"
    }
    
    init(imageUrls: [URL], nextPageLink: URL?, lastPageLink: URL?) {
        self.imageUrls = imageUrls
        self.nextPageLink = nextPageLink
        self.lastPageLink = lastPageLink
    }
    
    init?(jsonString: String, urlFixer: (URL) -> URL) {
        if let data = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
           let urlStrings = json["image_urls"] as? [String] {
            self.imageUrls = urlStrings.compactMap({ urlString in
                if let url = URL(string: urlString) {
                    return urlFixer(url)
                } else {
                    return nil
                }
            })
            if let nextPage = json["next_page_url"] as? String, let url = URL(string: nextPage) {
                self.nextPageLink = urlFixer(url)
            } else {
                self.nextPageLink = nil
            }
            if let lastPage = json["last_page_url"] as? String, let url = URL(string: lastPage) {
                self.lastPageLink = urlFixer(url)
            } else {
                self.lastPageLink = nil
            }
        } else {
            return nil
        }
    }
}

class HTMLParser {
    
    let html: String
    let originUrl: URL
    let nextPageName: String
    let lastPageName: String
    
    init(html: String, originUrl: URL, nextPageName: String, lastPageName: String) {
        self.html = html
        self.nextPageName = nextPageName
        self.lastPageName = lastPageName
        var originUrl = originUrl
        if originUrl.absoluteString.hasSuffix("/") {
            originUrl.deleteLastPathComponent()
        }
        self.originUrl = originUrl
    }
    
    func parse() -> HTMLInfo? {
        var imageUrls: [URL] = []
        var nextPageUrl: URL?
        var lastPageUrl: URL?
        
        var imageStart = html.startIndex
        var lastPageStart = html.startIndex
        var nextPageStart = html.startIndex
        
        while imageStart < html.endIndex || lastPageStart < html.endIndex || nextPageStart < html.endIndex {
            if let urlRange = htmlURLRangeFor(tag: .img, range: imageStart..<html.endIndex) {
                if let url = URL(string: String(html[urlRange.0])) {
                    imageUrls.append(processUrl(url))
                }
                imageStart = urlRange.0.upperBound
            } else {
                imageStart = html.endIndex
            }
            
            if let urlRange = htmlURLRangeFor(tag: .a, range: lastPageStart..<html.endIndex, withContent: true) {
                if urlRange.1 == self.lastPageName, let url = URL(string: String(html[urlRange.0])) {
                    lastPageUrl = processUrl(url)
                }
                lastPageStart = urlRange.0.upperBound
            } else {
                lastPageStart = html.endIndex
            }
            
            if let urlRange = htmlURLRangeFor(tag: .a, range: nextPageStart..<html.endIndex, withContent: true) {
                if urlRange.1 == self.nextPageName, let url = URL(string: String(html[urlRange.0])) {
                    nextPageUrl = processUrl(url)
                }
                nextPageStart = urlRange.0.upperBound
            } else {
                nextPageStart = html.endIndex
            }
        }
        return imageUrls.count > 0 ? HTMLInfo(imageUrls: imageUrls, nextPageLink: nextPageUrl, lastPageLink: lastPageUrl) : nil
    }
    
    func htmlURLRangeFor(tag: HTMLTag, range: Range<String.Index>, withContent: Bool = false) -> (Range<String.Index>, String?)? {
        if let tagRangeStart = html.range(of: tag.tagRangeStart, options: .caseInsensitive, range: range),
           let urlRangeStart = html.range(of: tag.urlRangeStart, options: .caseInsensitive, range: tagRangeStart.upperBound..<html.endIndex), let urlRangeEnd = html.range(of: tag.urlRangeEnd, options: .caseInsensitive, range: urlRangeStart.upperBound..<html.endIndex) {
            
            var content: String?
            if withContent {
                if let contentStart = html.range(of: tag.contentRangeStart, options: .caseInsensitive, range: urlRangeEnd.upperBound..<html.endIndex), let contentEnd = html.range(of: tag.contentRangeEnd, options: .caseInsensitive, range: contentStart.upperBound..<html.endIndex) {
                    content = String(html[contentStart.upperBound..<contentEnd.lowerBound])
                }
            }
            
            return (urlRangeStart.upperBound..<urlRangeEnd.lowerBound, content)
        } else {
            return nil
        }
    }
    
    func processUrl(_ url: URL) -> URL {
        var finalUrl = url
        if finalUrl.host == nil || finalUrl.host?.lowercased() == "localhost"  {
            finalUrl = self.originUrl.appendingPathComponent(url.path)
        }
        finalUrl = finalUrl.withHostFixed()
        DLog("process url origin: \(url) final: \(finalUrl)")
        return finalUrl
    }
}

enum HTMLTag {
    case img
    case a
    
    var tagRangeStart: String {
        switch self {
        case .img:
            return "<img"
        case .a:
            return "<a"
        }
    }
    
    var urlRangeStart: String {
        switch self {
        case .img:
            return "src=\""
        case .a:
            return "href=\""
        }
    }
    
    var urlRangeEnd: String {
        return "\""
    }
    
    var contentRangeStart: String {
        return ">"
    }
    
    var contentRangeEnd: String {
        switch self {
        case .img:
            return "</img>"
        case .a:
            return "</a>"
        }
    }
}
