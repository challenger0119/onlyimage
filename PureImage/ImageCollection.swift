//
//  ImageCollection.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/24.
//

import SwiftUI
import Combine

struct ImageCollection: View {
    @Binding var imageRequest: [URLRequest]
    @Binding var size: CGFloat
    
    var body: some View {
        if !imageRequest.isEmpty {
            ScrollView {
                ForEach(imageRequest, id:\.url!.absoluteString) { request in
                    AsyncImage(request: request, sizeThreadhold: self.size)
                }
            }
        } else {
            HStack {
                Text(I18N.usage()).lineSpacing(8.0)
                Spacer()
            }.padding()
            
        }
    }
}

struct ImageCollection_Previews: PreviewProvider {
    static var previews: some View {
        ImageCollection(imageRequest: .constant([]), size: .constant(0))
    }
}

// disable blink
struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct AsyncImage: View {
    
    @StateObject private var remoteImage: RemoteImage = RemoteImage()
    private let request: URLRequest
    private let sizeThreadhold: CGFloat
    
    init(request: URLRequest, sizeThreadhold: CGFloat) {
        self.request = request
        self.sizeThreadhold = sizeThreadhold
    }
    
    var body: some View {
        Group {
            if let image = remoteImage.uiImage {
                if image.size.width * image.size.height > sizeThreadhold  {
                    NavigationLink(destination: ImageView(image: image)) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }.buttonStyle(FlatLinkStyle())
                }
            } else if remoteImage.isLoading {
                ProgressView()
            } else {
                if let errMsg = remoteImage.errorMsg {
                    Text(errMsg)
                } else {
                    Text("*****")
                }
            }
        }.onAppear {
            remoteImage.loadImage(request: request)
        }
    }
}

class RemoteImage: ObservableObject {
    @Published var uiImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMsg: String?
    
    func loadImage(request: URLRequest) {
        if errorMsg != nil || isLoading {
            return
        }
        isLoading = true
        
        guard let urlString = request.url?.absoluteString else {
            return
        }
        if let image = ImageCacheManager.shared.image(with: urlString) {
            self.isLoading = false
            self.uiImage = image
            DLog("loaded image \(urlString) from cache")
            return
        }
        DLog("start loading image \(urlString)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, let image = UIImage(data: data) else {
                    DLog("get image error: \(String(describing: error)) resp: \(String(describing: response))")
                    if let httpResp = response as? HTTPURLResponse {
                        self.errorMsg = "Failed status code: \(httpResp.statusCode) error: \(error?.localizedDescription ?? "")"
                    } else {
                        self.errorMsg = "Error: \(error?.localizedDescription ?? "")"
                    }
                    self.isLoading = false
                    return
                }
                ImageCacheManager.shared.setImage(image, key: urlString)
                self.isLoading = false
                self.uiImage = image
            }
        }.resume()
    }
}
