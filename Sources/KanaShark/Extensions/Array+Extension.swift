//
//  Array+Extension.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/21.
//

import CoreGraphics

// tracePoints
extension [CGPoint] {
    /// 軌跡を n 点に等間隔で再サンプリングする（n >= 2）
    func resampled(to n: Int) -> [CGPoint] {
        guard n >= 1 else { return [] }

        // 入力が空の場合は空配列を返す
        guard !self.isEmpty else { return [] }

        // 全ての点が同じ場合（距離の合計が0）、同じ点をn個返す
        let totalLength = self.dropFirst().reduce(0) { sum, point in
            sum + point.distance(to: self[0])
        }

        if totalLength == 0 {
            return Array(repeating: self[0], count: n)
        }

        // 通常のリサンプリング処理
        guard self.count >= 2 else {
            return Array(repeating: self.first ?? .zero, count: n)
        }

        // 1. 各区間の長さを計算
        var distances: [CGFloat] = []
        var runningTotal: CGFloat = 0
        for i in 1..<self.count {
            let d = self[i].distance(to: self[i - 1])
            distances.append(d)
            runningTotal += d
        }

        // 2. 等間隔長さ D を算出
        let interval = runningTotal / CGFloat(n - 1)

        // 3. 再サンプリング処理
        var result: [CGPoint] = [self[0]]
        var currentIndex = 1
        var currentPos = self[0]
        var accumulated: CGFloat = 0

        while result.count < n - 1 {
            guard currentIndex < self.count else { break }
            let nextPoint = self[currentIndex]
            let segmentLength = currentPos.distance(to: nextPoint)

            if segmentLength == 0 {
                currentIndex += 1
                continue
            }

            if accumulated + segmentLength >= interval {
                let remain = interval - accumulated
                let t = remain / segmentLength
                let interpolated = currentPos.interpolate(to: nextPoint, t: t)
                result.append(interpolated)
                currentPos = interpolated
                accumulated = 0
            } else {
                accumulated += segmentLength
                currentPos = nextPoint
                currentIndex += 1
            }
        }

        // 最後の点を明示的に追加
        if let last = self.last {
            result.append(last)
        }

        // 結果が不足している場合、最後の点で埋める
        while result.count < n {
            result.append(self.last ?? .zero)
        }

        return result
    }

    /// 等間隔再サンプリング後に正規化（スケーリング＋重心移動）
    /// - Parameters:
    ///   - n: 再サンプリングの点数
    ///   - boundingBoxSide: バウンディングボックスの大辺をこの長さにスケーリング
    /// - Returns: 中心が原点、スケール正規化された n 点の配列
    func normalizedResampled(to n: Int, boundingBoxSide: CGFloat) -> [CGPoint] {
        // 1. 等間隔再サンプリング
        let pts = resampled(to: n)
        // 2. バウンディングボックス取得
        let xs = pts.map { $0.x }
        let ys = pts.map { $0.y }
        guard let minX = xs.min(), let maxX = xs.max(),
            let minY = ys.min(), let maxY = ys.max()
        else {
            return pts
        }
        let width = maxX - minX
        let height = maxY - minY
        let scale: CGFloat
        if width > 0 || height > 0 {
            scale = boundingBoxSide / Swift.max(width, height)
        } else {
            scale = 1
        }
        // 3. スケーリング
        let scaled = pts.map { CGPoint(x: $0.x * scale, y: $0.y * scale) }
        // 4. 重心計算
        let cx = scaled.map { $0.x }.reduce(0, +) / CGFloat(scaled.count)
        let cy = scaled.map { $0.y }.reduce(0, +) / CGFloat(scaled.count)
        // 5. 平行移動（中心を原点へ）
        return scaled.map { CGPoint(x: $0.x - cx, y: $0.y - cy) }
    }
}
