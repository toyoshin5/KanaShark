//
//  Array+Extension.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/21.
//

import CoreGraphics

extension [CGPoint] {
    func resampled(to n: Int) -> [CGPoint] {
        guard n >= 1 else { return [] }
        guard !self.isEmpty else { return [] }
        let totalLength = self.dropFirst().reduce(0) { sum, point in
            sum + point.distance(to: self[0])
        }

        if totalLength == 0 {
            return Array(repeating: self[0], count: n)
        }

        guard self.count >= 2 else {
            return Array(repeating: self.first ?? .zero, count: n)
        }

        var distances: [CGFloat] = []
        var runningTotal: CGFloat = 0
        for i in 1..<self.count {
            let d = self[i].distance(to: self[i - 1])
            distances.append(d)
            runningTotal += d
        }

        let interval = runningTotal / CGFloat(n - 1)

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

        if let last = self.last {
            result.append(last)
        }

        while result.count < n {
            result.append(self.last ?? .zero)
        }

        return result
    }

    /// Normalizes after equidistant resampling (scaling + centroid translation).
    /// - Parameters:
    ///   - n: Number of points for resampling
    ///   - boundingBoxSide: Scale the larger side of the bounding box to this length
    /// - Returns: Array of n points, scale normalized, centered at origin
    func normalizedResampled(to n: Int, boundingBoxSide: CGFloat) -> [CGPoint] {
        let pts = resampled(to: n)
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
        let scaled = pts.map { CGPoint(x: $0.x * scale, y: $0.y * scale) }
        let cx = scaled.map { $0.x }.reduce(0, +) / CGFloat(scaled.count)
        let cy = scaled.map { $0.y }.reduce(0, +) / CGFloat(scaled.count)
        return scaled.map { CGPoint(x: $0.x - cx, y: $0.y - cy) }
    }
}
