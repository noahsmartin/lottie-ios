// Created by Bryn Bodayle on 1/20/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - LottieView

/// A wrapper which exposes Lottie's `LottieAnimationView` to SwiftUI
@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
public struct LottieView: UIViewConfiguringSwiftUIView {

  // MARK: Lifecycle

  /// Creates a `LottieView` that displays the given animation
  public init(animation: LottieAnimation?) {
    self.animation = animation
  }

  // MARK: Public

  public var body: some View {
    LottieAnimationView.swiftUIView {
      LottieAnimationView(
        animation: animation,
        imageProvider: imageProvider,
        textProvider: textProvider,
        fontProvider: fontProvider,
        configuration: configuration)
    }
    .sizing(sizing)
    .configure { context in
      // We check referential equality of the animation before updating as updating the
      // animation has a side-effect of rebuilding the animation layer, and it would be
      // prohibitive to do so on every state update.
      if animation !== context.view.animation {
        context.view.animation = animation
      }
    }
    .configurations(configurations)
  }

  /// Returns a copy of this `LottieView` updated to have the given closure applied to its
  /// represented `LottieAnimationView` whenever it is updated via the `updateUIView(…)`
  /// or `updateNSView(…)` method.
  public func configure(_ configure: @escaping (LottieAnimationView) -> Void) -> Self {
    var copy = self
    copy.configurations.append { context in
      configure(context.view)
    }
    return copy
  }

  /// Returns a copy of this view that can be resized by scaling its animation to fit the size
  /// offered by its parent.
  public func resizable() -> Self {
    var copy = self
    copy.sizing = .proposed
    return copy
  }

  /// Returns a copy of this animation view that loops its animation whenever visible by playing
  /// whenever it is updated with a `loopMode` of `.loop` if not already playing.
  public func looping() -> Self {
    configure { view in
      if !view.isAnimationPlaying {
        view.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
      }
    }
  }

  /// Returns a copy of this animation view with its `AnimationView` updated to have the provided
  /// background behavior.
  public func backgroundBehavior(_ value: LottieBackgroundBehavior) -> Self {
    configure { view in
      view.backgroundBehavior = value
    }
  }

  /// Returns a copy of this view with its accessibility label updated to the given value.
  public func accessibilityLabel(_ accessibilityLabel: String?) -> Self {
    configure { view in
      #if os(macOS)
      view.setAccessibilityElement(accessibilityLabel != nil)
      view.setAccessibilityLabel(accessibilityLabel)
      #else
      view.isAccessibilityElement = accessibilityLabel != nil
      view.accessibilityLabel = accessibilityLabel
      #endif
    }
  }

  /// Returns a copt of this view with its `LottieConfiguration` updated to the given value.
  public func configuration(_ configuration: LottieConfiguration) -> Self {
    var copy = self
    copy.configuration = configuration

    copy = copy.configure { view in
      if view.configuration != configuration {
        view.configuration = configuration
      }
    }

    return copy
  }

  /// Returns a copy of this view with its image provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func imageProvider<ImageProvider: AnimationImageProvider & Equatable>(_ imageProvider: ImageProvider) -> Self {
    var copy = self
    copy.imageProvider = imageProvider

    copy = copy.configure { view in
      if (view.imageProvider as? ImageProvider) != imageProvider {
        view.imageProvider = imageProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view with its text provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func textProvider<TextProvider: AnimationTextProvider & Equatable>(_ textProvider: TextProvider) -> Self {
    var copy = self
    copy.textProvider = textProvider

    copy = copy.configure { view in
      if (view.textProvider as? TextProvider) != textProvider {
        view.textProvider = textProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view with its image provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func fontProvider<FontProvider: AnimationFontProvider & Equatable>(_ fontProvider: FontProvider) -> Self {
    var copy = self
    copy.fontProvider = fontProvider

    copy = configure { view in
      if (view.fontProvider as? FontProvider) != fontProvider {
        view.fontProvider = fontProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view using the given value provider for the given keypath.
  /// The value provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func valueProvider<ValueProvider: AnyValueProvider & Equatable>(
    _ valueProvider: ValueProvider,
    for keypath: AnimationKeypath)
    -> Self
  {
    configure { view in
      if (view.valueProviders[keypath] as? ValueProvider) != valueProvider {
        view.setValueProvider(valueProvider, keypath: keypath)
      }
    }
  }

  // MARK: Internal

  var configurations = [SwiftUIView<LottieAnimationView, Void>.Configuration]()

  // MARK: Private

  private let animation: LottieAnimation?
  private var imageProvider: AnimationImageProvider?
  private var textProvider: AnimationTextProvider = DefaultTextProvider()
  private var fontProvider: AnimationFontProvider = DefaultFontProvider()
  private var configuration: LottieConfiguration = .shared
  private var sizing = SwiftUIMeasurementContainerStrategy.automatic
}
