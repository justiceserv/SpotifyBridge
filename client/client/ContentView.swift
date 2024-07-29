import SwiftUI
import Combine

class NowPlayingInfo: ObservableObject {
    @Published var title: String = "Unknown Title" // Cannot be Unknown
    @Published var artist: String = "Various Artist" // If Artist is Unknown (Unlikely)
    @Published var album: String = "Unknown Album"
    @Published var artwork: Data? = nil
    @Published var artworkmime: String = ""
    
    func updateInfo(title: String, artist: String, album: String, artwork: Data, artworkmime: String) {
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.artworkmime = artworkmime
    }
}

struct NSImageViewWrapper: NSViewRepresentable {
    var image: NSImage
    
    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = image
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
        nsView.image = image
    }
}

struct ContentView: View {
    @ObservedObject var nowPlayingInfo = NowPlayingInfo()
    @State private var nsImage: NSImage?
    
    var body: some View {
        HStack {
            VStack {
                if let nsImage = nsImage {
                    NSImageViewWrapper(image: nsImage).frame(width: 200, height: 200)
                } else {
                    Text("No Image")
                }
            }
            .frame(width: 200, height: 200, alignment: .center)
            VStack(alignment: .leading) {
                Text(nowPlayingInfo.title).font(.headline)
                Text(nowPlayingInfo.album).font(.subheadline)
                Text(nowPlayingInfo.artist).font(.subheadline)
            }
            .onAppear {
                AppDelegate.shared.nowPlayingInfo = nowPlayingInfo
                loadImage()
            }
            .frame(width: 300, height: 200, alignment: .leading)
        }
        .padding()
        .frame(width: 500, height: 200)
        VStack {
            Text("Spotify-Bridge made by Justiceserv.")
        }
        .padding()
        .frame(width: 500, height: 20, alignment: .center)
    }
    
    func loadImage() {
        if let artworkData = nowPlayingInfo.artwork,
           let image = NSImage(data: artworkData) {
            self.nsImage = image
        } else {
            self.nsImage = nil
        }
    }
}
