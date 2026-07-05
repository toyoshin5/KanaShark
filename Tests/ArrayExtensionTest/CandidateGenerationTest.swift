//
//  CandidateGenerationTest.swift
//  KanaShark
//
//  keyboardSize 確定前に前処理が走ると候補が生成されない問題の回帰テスト
//

import CoreGraphics
import SwiftUI
import Testing

@testable import KanaShark

struct CandidateGenerationTest {

    /// キー中心を結ぶ直線を細かく補間して指のなぞりを模擬する
    private func makeTrace(shiins: [KanaShiin], size: CGSize) -> [CGPoint] {
        let keys: [CGPoint] = shiins.map { s in
            let p = [HiraganaPosition].default.first { $0.shiin == s }!
            return CGPoint(x: p.x * size.width, y: p.y * size.height)
        }
        var trace: [CGPoint] = []
        for i in 0..<(keys.count - 1) {
            for t in stride(from: 0.0, to: 1.0, by: 0.05) {
                trace.append(
                    CGPoint(
                        x: keys[i].x + (keys[i + 1].x - keys[i].x) * t,
                        y: keys[i].y + (keys[i + 1].y - keys[i].y) * t
                    ))
            }
        }
        trace.append(keys.last!)
        return trace
    }

    @MainActor
    private func makeVM() -> GestureKeyboardViewModel {
        GestureKeyboardViewModel(
            hiraganaPositions: .default,
            minConfidence: 0.001,
            onGestureStarted: nil,
            onGestureEnded: nil,
            onCandidatesGenerated: { _ in }
        )
    }

    @MainActor
    private func waitForVocabularies(_ vm: GestureKeyboardViewModel) async throws {
        var waited = 0
        while vm.vocabularies.isEmpty && waited < 200 {
            try await Task.sleep(nanoseconds: 50_000_000)
            waited += 1
        }
    }

    @Test @MainActor
    func キーボードサイズ設定済みなら候補が出る() async throws {
        let size = CGSize(width: 190, height: 170)
        let vm = makeVM()
        vm.keyboardSize = size
        await vm.task()
        try await waitForVocabularies(vm)

        // みかん = 子音「まかわ」をなぞる
        let trace = makeTrace(shiins: [.m, .k, .w], size: size)
        let results = await vm.findCandidates(
            tracePoints: trace,
            vocabularies: vm.vocabularies,
            hiraganaPositions: vm.hiraganaPositions
        )
        #expect(!results.isEmpty)
        #expect(results.prefix(5).map(\.text).contains("みかん"))
    }

    @Test @MainActor
    func taskがonAppearより先に走ってもサイズ設定後に候補が出る() async throws {
        let vm = makeVM()
        // .onAppear (keyboardSize の設定) より先に .task が走ったケースを模擬
        let taskHandle = Task { await vm.task() }
        try await Task.sleep(nanoseconds: 200_000_000)
        // 遅れて onAppear がサイズを設定する
        let size = CGSize(width: 190, height: 170)
        vm.keyboardSize = size
        await taskHandle.value
        try await waitForVocabularies(vm)

        let trace = makeTrace(shiins: [.m, .k, .w], size: size)
        let results = await vm.findCandidates(
            tracePoints: trace,
            vocabularies: vm.vocabularies,
            hiraganaPositions: vm.hiraganaPositions
        )
        #expect(!results.isEmpty)
        #expect(results.prefix(5).map(\.text).contains("みかん"))
    }
}
