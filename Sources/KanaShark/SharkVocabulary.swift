//
//  Vocabulary.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/03.
//

import CoreGraphics

struct SharkVocabulary: Sendable {
    let kana: String
    let word: String
    let frequency: Double
    let tracePoints: [CGPoint]
    let normalizedTracePoints: [CGPoint]
    let traceId: Int
    let shiinArray: [KanaShiin]
    let boinArray: [KanaBoin]
    var accuracy: Double = 0

    // hiraganaPositionsは絶対座標
    init(
        kana: String,
        word: String,
        frequency: Double,
        hiraganaPositions: [HiraganaPosition]
    ) {
        self.kana = kana
        self.word = word
        self.frequency = frequency
        shiinArray = SharkVocabulary.convertToShiinArray(word: kana)
        boinArray = SharkVocabulary.convertToBoinArray(word: kana)
        let (p, np) = SharkVocabulary.calcShiinTracePoint(
            shiin: shiinArray,
            hiraganaPositions: hiraganaPositions,
        )
        (self.tracePoints, self.normalizedTracePoints) = (p, np)
        self.traceId = SharkVocabulary.makeHashFromCGPintArray(tracePoints)
    }

    private static func makeHashFromCGPintArray(_ points: [CGPoint]) -> Int {
        let hash = points.reduce(0) { (result, point) in
            result ^ (point.x.hashValue ^ point.y.hashValue)
        }
        return hash
    }

    private static func convertToShiinArray(word: String) -> [KanaShiin] {
        var result = [KanaShiin]()
        for char in word {
            let kana = String(char)
            if let shiin = KanaShiin.fromKana(kana) {
                result.append(shiin)
            }
        }
        return result
    }

    private static func convertToBoinArray(word: String) -> [KanaBoin] {
        var result = [KanaBoin]()
        for char in word {
            let kana = String(char)
            if let boin = KanaBoin.fromKana(kana) {
                result.append(boin)
            }
        }
        return result
    }

    private static func calcShiinTracePoint(
        shiin: [KanaShiin],
        hiraganaPositions: [HiraganaPosition]
    )
        -> ([CGPoint], [CGPoint])
    {
        let positions: [CGPoint] = shiin.map { s in
            if let pos = hiraganaPositions.first(where: { $0.shiin == s }) {
                return CGPoint(x: pos.absX!, y: pos.absY!)
            }
            return nil
        }.compactMap { $0 }
        let resampled = positions.resampled(to: 20)
        let normalizedResampled = positions.normalizedResampled(to: 20, boundingBoxSide: 1)
        return (resampled, normalizedResampled)
    }

    private static func calcFullTracePoint(
        shiin: [KanaShiin],
        boin: [KanaBoin],
        hiraganaPositions: [HiraganaPosition]
    )
        -> ([CGPoint], [CGPoint])
    {
        var positions: [CGPoint] = []

        for i in 0..<shiin.count {
            if let pos = hiraganaPositions.first(where: { $0.shiin == shiin[i] }) {
                let basePoint = CGPoint(x: pos.absX!, y: pos.absY!)
                positions.append(basePoint)
                // 母音に応じて追加のポイントを生成
                let offset: CGFloat = 30

                switch boin[i] {
                case .i:
                    positions.append(CGPoint(x: basePoint.x - offset, y: basePoint.y))
                case .u:
                    positions.append(CGPoint(x: basePoint.x, y: basePoint.y - offset))
                case .e:
                    positions.append(CGPoint(x: basePoint.x + offset, y: basePoint.y))
                case .o:
                    positions.append(CGPoint(x: basePoint.x, y: basePoint.y + offset))
                case .a:
                    break  // あ段は追加のポイントなし
                }
            }
        }

        let resampled = positions.resampled(to: 20)
        let normalizedResampled = positions.normalizedResampled(to: 20, boundingBoxSide: 1)
        return (resampled, normalizedResampled)
    }

}
