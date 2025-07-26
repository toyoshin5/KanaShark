//
//  Untitled.swift
//  KanaShark
//
//  Created by Shingo Toyoda on 2025/06/02.
//

import Foundation

/// Represents the position of a Hiragana character on the gesture keyboard.
public struct HiraganaPosition: Hashable, Sendable {
    let shiin: KanaShiin
    let x: CGFloat  // 0~1の相対位置
    let y: CGFloat  // 0~1の相対位置
    var absX: CGFloat?  // 絶対位置
    var absY: CGFloat?  // 絶対位置

    /// Initializes a HiraganaPosition with the specified consonant and relative position.
    /// - Parameters:
    ///   - shiin: The consonant (KanaShiin) of the Hiragana.
    ///   - x: The relative x position (0~1).
    ///   - y: The relative y position (0~1).
    public init(shiin: KanaShiin, x: CGFloat, y: CGFloat) {
        self.shiin = shiin
        self.x = x
        self.y = y
        self.absX = nil
        self.absY = nil
    }

    mutating func setAbsPosition(keyboardSize: CGSize) {
        self.absX = self.x * keyboardSize.width
        self.absY = self.y * keyboardSize.height
    }
}
