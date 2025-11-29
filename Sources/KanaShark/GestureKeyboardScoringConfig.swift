//
//  GestureKeyboardScoringConfig.swift
//  KanaShark
//
//  Created by Shingo Toyoda on 2025/11/29.
//

import Foundation

/// Configuration for the scoring engine of the gesture keyboard.
public struct GestureKeyboardScoringConfig: Sendable {
    /// The sigma value for the shape channel in the Gaussian function.
    /// Controls how strictly the shape of the gesture must match the vocabulary.
    /// Smaller values mean stricter matching.
    public var sigmaShape: Double

    /// The sigma value for the location channel in the Gaussian function.
    /// Controls how strictly the location of the gesture must match the vocabulary.
    /// Smaller values mean stricter matching.
    public var sigmaLocation: Double

    /// Initializes a new scoring configuration.
    /// - Parameters:
    ///   - sigmaShape: The sigma value for the shape channel. Default is 0.008.
    ///   - sigmaLocation: The sigma value for the location channel. Default is 12.
    public init(
        sigmaShape: Double = 0.008,
        sigmaLocation: Double = 12
    ) {
        self.sigmaShape = sigmaShape
        self.sigmaLocation = sigmaLocation
    }
}
