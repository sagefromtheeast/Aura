import Flutter
import UIKit
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let fileScannerChannel = FlutterMethodChannel(name: "com.aura.aura/file_scanner",
                                                  binaryMessenger: controller.binaryMessenger)
    fileScannerChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "scanAllAudio" {
        self.scanAllAudio(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func scanAllAudio(result: @escaping FlutterResult) {
    var tracks = [[String: Any]]()
    
    MPMediaLibrary.requestAuthorization { status in
      if status == .authorized {
        let query = MPMediaQuery.songs()
        if let items = query.items {
          for item in items {
            guard let url = item.assetURL else { continue }
            
            var track = [String: Any]()
            track["path"] = url.absoluteString
            track["title"] = item.title ?? "Unknown"
            track["artist"] = item.artist ?? "Unknown Artist"
            track["album"] = item.albumTitle ?? "Unknown Album"
            track["duration"] = Int((item.playbackDuration * 1000).rounded())
            track["year"] = 0 // Not directly available without heavy AVAsset extraction
            track["trackNumber"] = item.albumTrackNumber
            track["discNumber"] = item.discNumber
            track["genre"] = item.genre ?? ""
            track["size"] = 0 // Also not readily available in MPMediaItem
            track["dateAdded"] = Int(item.dateAdded.timeIntervalSince1970 * 1000)
            
            // Check if there is artwork
            if let artwork = item.artwork {
              // Can't directly pass image, usually apps save it to disk and pass the path. 
              // We leave it null for now, flutter will read ID3 tags if needed later.
              track["coverArtPath"] = nil
            }
            
            tracks.append(track)
          }
        }
        result(tracks)
      } else {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Media Library permission denied",
                            details: nil))
      }
    }
  }
}
