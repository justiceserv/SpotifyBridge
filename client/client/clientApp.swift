import SwiftUI
import AppKit
import Foundation
import Cocoa

@objc(SPAppleScriptTrack)
class SPAppleScriptTrack: NSObject {
    @objc var artist: String
    @objc var album: String
    @objc var title: String
    
    init(artist: String, album: String, title: String) {
        self.artist = artist
        self.album = album
        self.title = title
    }
}

@objc(MyMusicAppScript)
class MyMusicAppScript: NSObject {
    @objc var currentTrack: SPAppleScriptTrack? {
        let nowPlayingInfo = AppDelegate.shared.nowPlayingInfo
        
        return SPAppleScriptTrack(
            artist: nowPlayingInfo.artist,
            album: nowPlayingInfo.album,
            title: nowPlayingInfo.title
        )
    }
}


@main
struct ClientApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    private var updateTimer: Timer?
    @ObservedObject var nowPlayingInfo = NowPlayingInfo()
    
    override init() {
        super.init()
        AppDelegate.shared = self
        startUpdatingNowPlayingInfo()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        /*
        guard let sdefURL = Bundle.main.url(forResource: "client", withExtension: "sdef"),
              let sdefData = try? Data(contentsOf: sdefURL),
              let suiteDescription = NSScriptSuiteDescription(data: sdefData) else {
            print("Failed to load SDEF")
            return
        }
        
        NSScriptSuiteRegistry.shared.register(MyMusicAppScript)
        NSScriptSuiteRegistry.shared.register(SPAppleScriptTrack)
         */ 
    }
    
    func startUpdatingNowPlayingInfo() {
        updateTimer?.invalidate()
            
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchNowPlayingInfo(nowPlayingInfo: self?.nowPlayingInfo ?? NowPlayingInfo())
        }
    }
    
    func fetchNowPlayingInfo(nowPlayingInfo: NowPlayingInfo) {
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            print("Could not load MediaRemote framework.")
            return
        }

        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else {
            print("Could not get MRMediaRemoteGetNowPlayingInfo function pointer.")
            return
        }

        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([AnyHashable: Any]) -> Void) -> Void
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.global()) { information in
            
            let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "Unknown Title"
            let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "Various Artist"
            var album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? "Unknown Album"
            if (album == "") {album = "Unknown Album"}
            let artwork = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data ?? Data([ 0 ])
            let artworkmime = information["kMRMediaRemoteNowPlayingInfoArtworkMIMEType"] as? String ?? "image/jpeg"

            print("Title: \(title), Artist: \(artist), Album: \(album), Artworkmime: \(artworkmime), Artwork: \(artwork)")
            DispatchQueue.main.async {
                self.nowPlayingInfo.updateInfo(title: title, artist: artist, album: album, artwork: artwork, artworkmime: artworkmime)
            }
        }
        
        func applicationWillTerminate(_ notification: Notification) {
            updateTimer?.invalidate()
        }
    }
}

