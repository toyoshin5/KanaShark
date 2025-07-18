//
//  Untitled.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/02.
//
import SwiftUI
// ViewModel
@Observable @MainActor
class GestureKeyboardViewModel {
    let minConfidence: CGFloat
    let onGestureStarted: (() -> Void)?
    let onGestureEnded: (([CGPoint]) -> Void)?
    let onCandidatesGenerated: ([GestureKeyboardResult]) -> Void
    var hiraganaPositions: [HiraganaPosition]
    var tracePoints: [CGPoint] = []
    var vocabularies: [KanaShiinPair: [SharkVocabulary]] = [:]
    var keyboardSize: CGSize = .zero
    var isShowLoading: Bool = false
    var loadingProgress: CGFloat = 0

    init(
        hiraganaPositions: [HiraganaPosition],
        minConfidence: CGFloat,
        onGestureStarted: (() -> Void)?,
        onGestureEnded: (([CGPoint]) -> Void)?,
        onCandidatesGenerated: @escaping (([GestureKeyboardResult]) -> Void),
    ) {
        self.hiraganaPositions = hiraganaPositions
        self.minConfidence = minConfidence
        self.onGestureStarted = onGestureStarted
        self.onGestureEnded = onGestureEnded
        self.onCandidatesGenerated = onCandidatesGenerated
    }

    @Sendable func task() async {
        for i in 0..<hiraganaPositions.count {
            hiraganaPositions[i].setAbsPosition(keyboardSize: keyboardSize)
        }
        isShowLoading = true
        await loadVocabularies()
        isShowLoading = false
    }

    nonisolated private func loadVocabularies(filename: String = "vocabulary.txt") async {
        guard
            let fileURL = Bundle.module.url(forResource: filename, withExtension: nil)
            let content = try? String(contentsOf: fileURL, encoding: .utf8)
        else {
            print("Failed to load vocabulary file: \(filename)")
            return
        }
        let hiraganaPositions = await self.hiraganaPositions
        let lines = content.split(whereSeparator: \.isNewline)
        var tempVocabularies: [KanaShiinPair: [SharkVocabulary]] = [:]

        for (i, raw) in lines.enumerated() {
            if i % 100 == 0 {
                Task { @MainActor in
                    self.loadingProgress = CGFloat(i) / CGFloat(lines.count)
                }
            }
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            let components = line.split(separator: ",")
            guard
                components.count > 1,
                let freq = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
            else {
                continue
            }

            let kana = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let word = ((components.count >= 3) ? components[2] : components[0]).trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let vocab: SharkVocabulary = .init(
                kana: kana,
                word: word,
                frequency: freq,
                hiraganaPositions: hiraganaPositions,
            )
            let vocabKey = KanaShiinPair(
                first: vocab.shiinArray.first ?? .a,
                lastShiin: vocab.shiinArray.last ?? .a
            )
            tempVocabularies[vocabKey, default: []].append(vocab)
        }

        // 4. MainActor 上でまとめて代入
        Task { @MainActor in
            self.vocabularies = tempVocabularies
        }
    }

    func onDragChanged(_ value: DragGesture.Value) {
        if tracePoints.isEmpty {
            self.onGestureStarted?()
        }
        tracePoints.append(value.location)
    }

    func onDragEnded(_ value: DragGesture.Value) {
        self.onGestureEnded?(tracePoints)
        Task {
            let conversions = await findCandidates(
                tracePoints: tracePoints,
                vocabularies: vocabularies,
                hiraganaPositions: hiraganaPositions
            )
            onCandidatesGenerated(conversions)
            self.tracePoints.removeAll()
        }
    }

    nonisolated private func findCandidates(
        tracePoints: [CGPoint],
        vocabularies: [KanaShiinPair: [SharkVocabulary]],
        hiraganaPositions: [HiraganaPosition]
    ) async -> [GestureKeyboardResult] {
        let normalizedTrace = tracePoints.normalizedResampled(to: 20, boundingBoxSide: 1)
        let resampledTrace = tracePoints.resampled(to: 20)

        // キャッシュ用辞書
        var locationCache: [Int: CGFloat] = [:]
        // 結果を格納
        var shapeDistances: [String: CGFloat] = [:]
        var locationDistances: [String: CGFloat] = [:]
        var frequencies: [String: Double] = [:]
        // 最も近い子音
        let narrowedVocabularies = getNarrowedVocabularies(
            tracePoints: tracePoints,
            hiraganaPositions: hiraganaPositions,
            vocabularies: vocabularies,
        )

        for v in narrowedVocabularies {
            let locKey = v.traceId

            // Shape チャネル
            let d1 = SharkScoringEngine.shapeChannel(
                normalizedTrace,
                v.normalizedTracePoints
            )

            let d2 =
                locationCache[locKey]
                ?? {
                    let d = SharkScoringEngine.locationChannel(
                        resampledTrace,
                        v.tracePoints,
                        radius: 15
                    )
                    locationCache[locKey] = d
                    return d
                }()

            shapeDistances[v.word] = d1
            locationDistances[v.word] = d2
            frequencies[v.word] = v.frequency
        }

        // チャネル統合
        let scoreDict = SharkScoringEngine.integrateChannels(
            shapeDistances: shapeDistances,
            locationDistances: locationDistances,
            frequency: frequencies,
            sigmaShape: 0.008,
            sigmaLocation: 12,
        )
        return
            narrowedVocabularies
            .compactMap { vocab -> SharkVocabulary? in
                guard let score: CGFloat = scoreDict[vocab.word],
                    score > minConfidence
                else {
                    return nil
                }
                var v: SharkVocabulary = vocab
                v.accuracy = Double(score)
                return v
            }
            .sorted { a, b in
                (a.accuracy) > (b.accuracy)
            }
            .map {
                .init(text: $0.word, confidence: $0.accuracy)
            }
    }

    nonisolated private func getNarrowedVocabularies(
        tracePoints: [CGPoint],
        hiraganaPositions: [HiraganaPosition],
        vocabularies: [KanaShiinPair: [SharkVocabulary]],
        radius: CGFloat = 50
    ) -> [SharkVocabulary] {
        let startPoint = tracePoints.first ?? .zero
        let endPoint = tracePoints.last ?? .zero

        let startShiin = getNearestShiin(point: startPoint, hiraganaPositions: hiraganaPositions)
        let endShiin = calculateEndShiinBoinPairs(
            endPoint: endPoint,
            hiraganaPositions: hiraganaPositions,
            radius: radius
        )

        return endShiin.flatMap { shiin in
            let key = KanaShiinPair(
                first: startShiin,
                lastShiin: shiin
            )
            return vocabularies[key] ?? []
        }
    }

    nonisolated private func calculateEndShiinBoinPairs(
        endPoint: CGPoint,
        hiraganaPositions: [HiraganaPosition],
        radius: CGFloat
    ) -> [KanaShiin] {

        return hiraganaPositions.compactMap { position in
            let x = (position.absX ?? 0)
            let y = (position.absY ?? 0)
            let targetPoint = CGPoint(x: x, y: y)

            return endPoint.distance(to: targetPoint) < radius
                ? position.shiin
                : nil
        }
    }

    nonisolated private func getNearestShiin(
        point: CGPoint,
        hiraganaPositions: [HiraganaPosition]
    ) -> KanaShiin {
        let nearest = hiraganaPositions.min { (a, b) -> Bool in
            let distanceA = CGPoint(x: a.absX ?? 0, y: a.absY ?? 0).distance(to: point)
            let distanceB = CGPoint(x: b.absX ?? 0, y: b.absY ?? 0).distance(to: point)
            return distanceA < distanceB
        }
        return nearest?.shiin ?? .a
    }
}
