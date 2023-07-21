//
//  Previews.swift
//  Lottie
//
//  Created by Noah Martin on 7/17/23.
//

import Foundation
import SwiftUI
import Lottie

struct Lottie_Previews: PreviewProvider {

  struct Data: Hashable {
    let animationName: String
    let progress: Double
  }

  static let animations = Samples.sampleAnimationNames.sorted()
  static let progress = [0.0, 0.25, 0.5, 0.75, 1.0]
  static let data = animations.flatMap { a in
    progress.map { Data(animationName: a, progress: $0) }
  }

  static func isEligible(_ animationName: String) -> Bool {
    // Edit the following line to filter for the animation you are trying to preview
    // return animationName == "HamburgerArrow"
    return true
  }

  static var previews: some View {
    ForEach(data.filter { isEligible($0.animationName) }, id: \.self) { data in
      let sampleAnimationName = data.animationName
      let progress = data.progress
        let animationView = makeAnimationView(
          for: sampleAnimationName)

        animationView.configure { v in
          v.currentProgress = progress
        }
        .previewDisplayName("\(sampleAnimationName)-\(progress)")
        .previewLayout(.sizeThatFits)
    }
  }

  static func makeAnimationView(
    for sampleAnimationName: String)
  -> LottieView
  {
    guard let animation = Samples.animation(named: sampleAnimationName) else {
      preconditionFailure("Couldn't create animation named \(sampleAnimationName)")
    }
    return LottieView(animation: animation)
  }
}

// MARK: - Samples

/// MARK: - Samples

enum Samples {
  /// The name of the directory that contains the sample json files
  static let directoryName = "Samples"

  /// The list of sample animation files in `Tests/Samples`
  static let sampleAnimationURLs = Bundle.lottie.fileURLs(in: Samples.directoryName, withSuffix: "json")

  /// The list of sample animation names in `Tests/Samples`
  static let sampleAnimationNames = sampleAnimationURLs.lazy
    .map { sampleAnimationURL -> String in
      // Each of the sample animation URLs has the format
      // `.../*.bundle/Samples/{subfolder}/{animationName}.json`.
      // The sample animation name should include the subfolders
      // (since that helps uniquely identity the animation JSON file).
      let pathComponents = sampleAnimationURL.pathComponents
      let samplesIndex = pathComponents.lastIndex(of: Samples.directoryName)!
      let subpath = pathComponents[(samplesIndex + 1)...]

      return subpath
        .joined(separator: "/")
        .replacingOccurrences(of: ".json", with: "")
        .replacingOccurrences(of: ".lottie", with: "")
    }

  static func animation(named sampleAnimationName: String) -> LottieAnimation? {
    guard
      let animation = LottieAnimation.named(
        sampleAnimationName,
        bundle: .lottie,
        subdirectory: Samples.directoryName)
    else { return nil }

    return animation
  }
}

extension Bundle {
  /// The Bundle representing files in this module
  static var lottie: Bundle {
    Bundle.main
  }

  /// Retrieves URLs for all of the files in the given directory with the given suffix
  func fileURLs(in directory: String, withSuffix suffix: String) -> [URL] {
    let enumerator = FileManager.default.enumerator(atPath: Bundle.lottie.bundlePath)!

    var fileURLs: [URL] = []

    while let fileSubpath = enumerator.nextObject() as? String {
      if
        fileSubpath.hasPrefix(directory),
        fileSubpath.contains(suffix)
      {
        let fileURL = Bundle.lottie.bundleURL.appendingPathComponent(fileSubpath)
        fileURLs.append(fileURL)
      }
    }

    return fileURLs
  }
}
