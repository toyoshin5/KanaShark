//
//  CGPoint+Extension.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/21.
//
import CoreGraphics

extension CGPoint {
    /// 2点間のユークリッド距離
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }

    /// 線形補間（0 <= t <= 1）
    func interpolate(to point: CGPoint, t: CGFloat) -> CGPoint {
        return CGPoint(
            x: self.x + (point.x - self.x) * t,
            y: self.y + (point.y - self.y) * t
        )
    }
}
