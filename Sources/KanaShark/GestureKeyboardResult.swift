//
//  GestureKeyboardResult.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/25.
//

import Foundation

/// The result of a gesture input on the keyboard.
/// Contains the recognized text and its confidence score.
public struct GestureKeyboardResult: Sendable, Identifiable {
    public let id = UUID()
    /// The recognized text from the gesture.
    public let text: String
    /// The confidence score of the recognition.
    public let confidence: Double
}
