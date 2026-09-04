import Flutter
import UIKit
import MediaPlayer
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    // Must match kFileScannerChannel in lib/core/constants.dart.
    let fileScannerChannel = FlutterMethodChannel(name: "com.aura/file_scanner",
                                                  binaryMessenger: controller.binaryMessenger)
    fileScannerChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "scanAllAudio" {
        self.scanAllAudio(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    // ── Daily Mix background regeneration (BGProcessingTask) ──────────────
    // Must match kDailyMixTaskName in lib/domain/smart_mix/mix_scheduler.dart
    // and BGTaskSchedulerPermittedIdentifiers in Info.plist.
    let mixChannel = FlutterMethodChannel(name: "com.aura/mix_scheduler",
                                          binaryMessenger: controller.binaryMessenger)
    self.mixSchedulerChannel = mixChannel
    mixChannel.setMethodCallHandler({ [weak self] (call, result) -> Void in
      if call.method == "scheduleDailyMixTask" {
        var hour = 5
        if let args = call.arguments as? [String: Any],
           let h = args["hour"] as? Int {
          hour = h
        }
        self?.scheduleDailyMixTask(hour: hour)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    if #available(iOS 13.0, *) {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: AppDelegate.dailyMixTaskIdentifier,
        using: nil
      ) { task in
        self.handleDailyMixTask(task: task)
      }
    }

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
            track["albumArtist"] = item.albumArtist ?? ""
            // Shared per-album key so Dart can group artwork by album.
            track["albumId"] = String(item.albumPersistentID)
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

  // ── Daily Mix scheduling ─────────────────────────────────────────────────

  static let dailyMixTaskIdentifier = "com.aura.dailyMixRegeneration"

  private var mixSchedulerChannel: FlutterMethodChannel?

  /// Submits a BGProcessingTask for roughly [hour] o'clock local time.
  /// iOS decides the exact moment; this is the earliest we want it to run.
  private func scheduleDailyMixTask(hour: Int) {
    guard #available(iOS 13.0, *) else { return }

    let request = BGProcessingTaskRequest(identifier: AppDelegate.dailyMixTaskIdentifier)
    // Everything is on-device, so no network is required.
    request.requiresNetworkConnectivity = false
    request.requiresExternalPower = false
    request.earliestBeginDate = AppDelegate.nextOccurrence(ofHour: hour)

    do {
      // Replace any pending copy so repeated launches don't stack requests.
      BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: AppDelegate.dailyMixTaskIdentifier)
      try BGTaskScheduler.shared.submit(request)
    } catch {
      NSLog("[Aura] Could not schedule daily mix task: \(error)")
    }
  }

  @available(iOS 13.0, *)
  private func handleDailyMixTask(task: BGTask) {
    // Always queue the next one first, so a crash here doesn't end the chain.
    scheduleDailyMixTask(hour: 5)

    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    guard let channel = mixSchedulerChannel else {
      task.setTaskCompleted(success: false)
      return
    }

    channel.invokeMethod("regenerateMixes", arguments: nil) { result in
      let ok = (result as? Bool) ?? false
      task.setTaskCompleted(success: ok)
    }
  }

  private static func nextOccurrence(ofHour hour: Int) -> Date {
    let calendar = Calendar.current
    let now = Date()
    var components = calendar.dateComponents([.year, .month, .day], from: now)
    components.hour = hour
    components.minute = 0

    guard let candidate = calendar.date(from: components) else {
      return now.addingTimeInterval(24 * 60 * 60)
    }
    return candidate > now
      ? candidate
      : calendar.date(byAdding: .day, value: 1, to: candidate) ?? candidate
  }
}
