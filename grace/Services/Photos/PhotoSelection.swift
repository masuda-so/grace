import Foundation
import ImageIO
import Observation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// Observable photo-picker state adapted from Apple's `ProfileModel` sample.
@MainActor
@Observable
final class PhotoSelection {
  enum ImageState {
    case empty
    case loading(Progress)
    case success(Data)
    case failure(Error)
  }

  private(set) var imageState: ImageState = .empty

  @ObservationIgnored
  private var preparationTask: Task<Void, Never>?

  var imageSelection: PhotosPickerItem? = nil {
    didSet {
      preparationTask?.cancel()
      if let imageSelection {
        let progress = loadTransferable(from: imageSelection)
        imageState = .loading(progress)
      } else {
        imageState = .empty
      }
    }
  }

  /// Retains the sample's `Progress`-returning load and stale-selection guard.
  private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
    imageSelection.loadTransferable(type: Data.self) { [weak self] result in
      Task { @MainActor [weak self] in
        guard let self else { return }
        guard Self.isCurrentSelection(imageSelection, current: self.imageSelection) else {
          print("Failed to get the selected item.")
          return
        }

        switch result {
        case .success(let data?):
          preparationTask = Task { [weak self] in
            do {
              let imageData = try await Self.preparedImageData(from: data)
              guard
                !Task.isCancelled,
                let self,
                Self.isCurrentSelection(imageSelection, current: self.imageSelection)
              else {
                return
              }
              imageState = .success(imageData)
            } catch is CancellationError {
              return
            } catch {
              guard
                let self,
                Self.isCurrentSelection(imageSelection, current: self.imageSelection)
              else {
                return
              }
              imageState = .failure(error)
            }
          }
        case .success(nil):
          imageState = .empty
        case .failure(let error):
          imageState = .failure(error)
        }
      }
    }
  }

  /// Returns whether an asynchronous result still belongs to the selected photo.
  nonisolated static func isCurrentSelection(
    _ selection: PhotosPickerItem,
    current: PhotosPickerItem?
  ) -> Bool {
    selection == current
  }

  /// Local storage boundary: downsample and encode the selected photo before persistence.
  nonisolated static func preparedImageData(from data: Data) async throws -> Data {
    let task = Task.detached(priority: .userInitiated) {
      try Task.checkCancellation()
      let preparedData = try prepareImageData(from: data)
      try Task.checkCancellation()
      return preparedData
    }

    return try await withTaskCancellationHandler {
      try await task.value
    } onCancel: {
      task.cancel()
    }
  }

  private nonisolated static func prepareImageData(from data: Data) throws -> Data {
    guard
      let source = CGImageSourceCreateWithData(data as CFData, nil),
      CGImageSourceGetCount(source) > 0
    else {
      throw PhotoSelectionError.invalidImage
    }

    let options: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: 1_600,
    ]
    guard
      let thumbnail = CGImageSourceCreateThumbnailAtIndex(
        source,
        0,
        options as CFDictionary
      )
    else {
      throw PhotoSelectionError.imagePreparationFailed
    }

    let encodedData = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        encodedData,
        UTType.jpeg.identifier as CFString,
        1,
        nil
      )
    else {
      throw PhotoSelectionError.imagePreparationFailed
    }

    let properties: [CFString: Any] = [
      kCGImageDestinationLossyCompressionQuality: 0.82
    ]
    CGImageDestinationAddImage(destination, thumbnail, properties as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
      throw PhotoSelectionError.imagePreparationFailed
    }
    return encodedData as Data
  }
}

private enum PhotoSelectionError: Error {
  case invalidImage
  case imagePreparationFailed
}
