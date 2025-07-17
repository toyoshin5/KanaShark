import CoreGraphics
// SharkScoringEngine.swift
import Foundation

struct SharkScoringEngine {

    /// チャンネルスコア（形状・位置）を統合して候補ごとの信頼度スコアを返す
    ///
    /// - Parameters:
    ///   - shapeDistances: [word: shape distance] （小さいほど良い）
    ///   - locationDistances: [word: location distance]
    ///   - sigmaShape: 形状チャンネルのσ
    ///   - sigmaLocation: 位置チャンネルのσ
    /// - Returns: [word: 統合スコア c(w)]（0〜1、合計1）
    static func integrateChannels(
        shapeDistances: [String: CGFloat],
        locationDistances: [String: CGFloat],
        frequency: [String: Double],
        sigmaShape: CGFloat,
        sigmaLocation: CGFloat
    ) -> [String: CGFloat] {
        var jointProbs: [String: CGFloat] = [:]

        for word in shapeDistances.keys {
            guard let ds = shapeDistances[word], let dl = locationDistances[word] else { continue }

            let ps = gaussianPDF(x: ds, sigma: sigmaShape)
            let pl = gaussianPDF(x: dl, sigma: sigmaLocation)
            let frequency = frequency[word] ?? 1.0
            jointProbs[word] = ps * pl * frequency
        }

        let total = jointProbs.values.reduce(0, +)
        guard total > 0 else { return [:] }

        return jointProbs.mapValues { $0 / total }
    }

    /// 速度に応じて位置チャンネルの σ を補正（SHARK2に基づく）
    static func adjustedSigma(
        idealTime: CGFloat,
        actualTime: CGFloat,
        baseSigma: CGFloat,
        gamma: CGFloat
    ) -> CGFloat {
        guard actualTime > 0 else { return baseSigma }
        let ratio = max(idealTime / actualTime, 0.01)
        let factor = 1 + gamma * log2(ratio)
        return baseSigma * factor
    }

    /// 2つの形状の距離を計算する関数 (SHARK2のShape Channelに基づく)
    static func shapeChannel(_ a: [CGPoint], _ b: [CGPoint]) -> CGFloat? {
        guard a.count == b.count, a.count > 0 else {
            return nil
        }
        let sumSq = zip(a, b).reduce(CGFloat(0)) { acc, pair in
            let dx = pair.0.x - pair.1.x
            let dy = pair.0.y - pair.1.y
            return acc + dx * dx + dy * dy
        }
        return sumSq / CGFloat(a.count)
    }

    /// トンネルスコアを計算する関数（SHARK2のLocation Channelに基づく）
    static func locationChannel(_ u: [CGPoint], _ t: [CGPoint], radius: CGFloat) -> CGFloat? {
        guard u.count > 0, t.count > 0 else { return nil }

        let N = u.count
        var score: CGFloat = 0.0

        for i in 0..<N {
            let ui = u[i]
            let minDist = t.map { ui.distance(to: $0) }.min() ?? .greatestFiniteMagnitude
            let delta: CGFloat = (minDist <= radius) ? 0 : minDist
            let alpha = weight(at: i, total: N)
            score += alpha * delta
        }

        return score
    }

    /// トンネルスコアに使う重み関数（始点・終点に高い重みをかける）
    private static func weight(at i: Int, total N: Int) -> CGFloat {
        let pos = CGFloat(i) / CGFloat(N - 1)
        return abs(pos - 0.2) * 2  // 端が最大（1.0）、中央が最小（0.6）
    }
    /// 正規分布に基づく確率密度関数
    private static func gaussianPDF(x: CGFloat, sigma: CGFloat) -> CGFloat {
        let coeff = 1 / (sqrt(2 * .pi) * sigma)
        let exponent = -((x * x) / (2 * sigma * sigma))
        return coeff * exp(exponent)
    }
}
