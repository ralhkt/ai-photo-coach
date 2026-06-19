#!/usr/bin/env ruby
# Publishes the Flutter camera plugin's AVCaptureSession for native preview layers.
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
symlink = File.join(ROOT, 'ios', '.symlinks', 'plugins', 'camera_avfoundation')
plugin_root = File.directory?(symlink) ? File.realpath(symlink) : nil
plugin_root ||= File.expand_path(
  '../../.pub-cache/hosted/pub.dev/camera_avfoundation-0.10.1',
  ROOT
)

camera_plugin = File.join(
  plugin_root,
  'ios',
  'camera_avfoundation',
  'Sources',
  'camera_avfoundation',
  'CameraPlugin.swift'
)

unless File.exist?(camera_plugin)
  warn "patch_camera_avfoundation_preview: CameraPlugin.swift not found at #{camera_plugin}"
  exit 0
end

MARKER = 'AIPhotoCoachCaptureSessionBridge'
contents = File.read(camera_plugin)
if contents.include?(MARKER)
  puts 'patch_camera_avfoundation_preview: already patched'
  exit 0
end

ready_post = <<~SWIFT.rstrip
      camera.start()
      // AIPhotoCoachCaptureSessionBridge
      if let defaultCamera = camera as? DefaultCamera,
         let session = defaultCamera.videoCaptureSession as? AVCaptureSession {
        NotificationCenter.default.post(
          name: Notification.Name("AIPhotoCoachCaptureSessionReady"),
          object: session
        )
      }
    completion(.success(()))
SWIFT

unless contents.include?('camera.start()')
  warn 'patch_camera_avfoundation_preview: camera.start() anchor missing'
  exit 1
end

contents = contents.sub(
  "    camera.start()\n    completion(.success(()))",
  ready_post
)

closed_post = <<~SWIFT.rstrip
        strongSelf.camera?.close()
        strongSelf.camera = nil
        // AIPhotoCoachCaptureSessionBridge
        NotificationCenter.default.post(
          name: Notification.Name("AIPhotoCoachCaptureSessionClosed"),
          object: nil
        )
SWIFT

contents = contents.sub(
  "        strongSelf.camera?.close()\n        strongSelf.camera = nil",
  closed_post
)

File.write(camera_plugin, contents)
puts 'patch_camera_avfoundation_preview: patched CameraPlugin.swift'