//
//  WatchTypingWatchTests.swift
//  WatchTypingWatchTests
//
//  Created by Shingo Toyoda on 2025/04/21.
//

import CoreGraphics
import Testing

@testable import KanaGestureKeyboard

struct ArrayExtensionTest {
    // MARK: - CGPoint 拡張のテスト
    @Test func 二点間のユークリッド距離を計算() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 3, y: 4)
        #expect(p1.distance(to: p2) == 5.0)
    }

    @Test func 線形補間で中間点を計算() {
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 10, y: 20)
        let interpolated = p1.interpolate(to: p2, t: 0.5)
        #expect(interpolated.x == 5.0)
        #expect(interpolated.y == 10.0)
    }

    // MARK: - [CGPoint] 拡張のテスト

    @Test func 単純な線分を3点にリサンプリング() {
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
        ]
        let resampled = points.resampled(to: 3)
        #expect(resampled.count == 3)
        #expect(resampled[0] == points[0])
        #expect(resampled[1].x == 5.0)
        #expect(resampled[1].y == 0.0)
        #expect(resampled[2] == points[1])
    }

    @Test func 空配列のリサンプリング() {
        let points: [CGPoint] = []
        let resampled = points.resampled(to: 5)
        #expect(resampled.isEmpty)
    }

    @Test func 単一点のリサンプリング() {
        let points = [CGPoint(x: 1, y: 1)]
        let resampled = points.resampled(to: 3)
        #expect(resampled.count == 3)
        for point in resampled {
            #expect(point == points[0])
        }
    }

    @Test func 同一2点のリサンプリング() {
        let points = [CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 1)]
        let resampled = points.resampled(to: 3)
        #expect(resampled.count == 3)
        for point in resampled {
            #expect(point == points[0])
        }
    }

    @Test func 正方形を正規化してリサンプリング() {
        let square = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2, y: 0),
            CGPoint(x: 2, y: 2),
            CGPoint(x: 0, y: 2),
        ]
        let normalized = square.normalizedResampled(to: 4, boundingBoxSide: 10)
        // 正規化後は中心が原点、最大辺が10になる
        #expect(normalized.contains { abs($0.x - 5.0) < 0.001 && abs($0.y + 5.0) < 0.001 })
        #expect(normalized.contains { abs($0.x + 5.0) < 0.001 && abs($0.y - 5.0) < 0.001 })
    }

    @Test func 直線を長さ4で正規化して5点にリサンプリング() {
        let line = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),  // 長さ1の直線
        ]

        // 正規化 + 5点にリサンプリング
        let resampled = line.normalizedResampled(to: 5, boundingBoxSide: 4)

        // 期待値
        let expectedX: [CGFloat] = [-2, -1, 0, 1, 2]
        let tolerance: CGFloat = 0.0001  // 浮動小数点誤差許容範囲

        #expect(resampled.count == 5)

        for (index, point) in resampled.enumerated() {
            #expect(
                abs(point.x - expectedX[index]) < tolerance,
                "点\(index)のx座標が期待値と異なります: \(point.x) != \(expectedX[index])"
            )
            #expect(
                abs(point.y) < tolerance,
                "点\(index)のy座標が0ではありません: \(point.y)"
            )
        }
    }

    @Test func 同一配列の形状距離は0() {
        let points1 = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 1),
        ]
        let points2 = points1
        #expect(SharkScoringEngine.shapeChannel(points1, points2) == 0.0)
    }

    @Test func 長さが異なる配列の形状距離はnil() {
        let points1 = [CGPoint(x: 0, y: 0)]
        let points2 = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 1),
        ]
        #expect(SharkScoringEngine.shapeChannel(points1, points2) == nil)
    }

    @Test func 形状距離の計算が正しい() {
        let points1 = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 1),
        ]
        let points2 = [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1),
        ]
        // (1² + 0² + 1² + 0²)/2 = 1.0
        #expect(SharkScoringEngine.shapeChannel(points1, points2) == 1.0)
    }
}
