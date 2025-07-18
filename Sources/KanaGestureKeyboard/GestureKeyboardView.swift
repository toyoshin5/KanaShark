//
//  GestureKeyboardView.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/02.
//

import SwiftUI

// View
/// A SwiftUI view that provides a gesture-based Hiragana keyboard.
public struct GestureKeyboardView: View {
    @State private var vm: GestureKeyboardViewModel

    /// Creates a GestureKeyboardView.
    /// - Parameters:
    ///   - hiraganaPositions: The positions of Hiragana characters on the keyboard.
    ///   - minConfidence: The minimum confidence threshold for candidate generation.
    ///   - onGestureStarted: Callback when a gesture starts.
    ///   - onGestureEnded: Callback when a gesture ends.
    ///   - onCandidatesGenerated: Callback when candidates are generated.
    public init(
        hiraganaPositions: [HiraganaPosition],
        minConfidence: CGFloat = 0.001,
        onGestureStarted: @escaping (() -> Void) = {},
        onGestureEnded: @escaping (([CGPoint]) -> Void) = { _ in },
        onCandidatesGenerated: @escaping ([GestureKeyboardResult]) -> Void
    ) {
        vm = GestureKeyboardViewModel(
            hiraganaPositions: hiraganaPositions,
            minConfidence: minConfidence,
            onGestureStarted: onGestureStarted,
            onGestureEnded: onGestureEnded,
            onCandidatesGenerated: onCandidatesGenerated
        )
    }

    /// The content and layout of the gesture keyboard view.
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    path.addLines(vm.tracePoints)
                }
                .strokedPath(.init(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.white.opacity(0.5))

                // 全てのひらがなを配置
                ForEach(vm.hiraganaPositions, id: \.self) { position in
                    let shiin = position.shiin
                    Text(shiin.rawValue)
                        .font(.system(size: 16))
                        .bold()
                        .position(
                            x: position.x * geometry.size.width,
                            y: position.y * geometry.size.height
                        )
                }.onAppear {
                    vm.keyboardSize = geometry.size
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged(vm.onDragChanged)
                        .onEnded(vm.onDragEnded)
                ).blur(radius: vm.isShowLoading ? 10 : 0)
                .animation(.smooth, value: vm.isShowLoading)
                if vm.isShowLoading {
                    VStack {
                        ProgressView(value: vm.loadingProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 100, height: 10)
                        Text("\(vm.loadingProgress * 100, specifier: "%.0f")%")
                            .multilineTextAlignment(.center)
                            .font(.caption.monospacedDigit())
                    }
                }
            }
        }
        .task(vm.task)
    }
}

#Preview("Shiin") {
    let hiraganaPositions = [
        HiraganaPosition(shiin: .a, x: 1 / 6, y: 1 / 8),
        HiraganaPosition(shiin: .k, x: 3 / 6, y: 1 / 8),
        HiraganaPosition(shiin: .s, x: 5 / 6, y: 1 / 8),
        HiraganaPosition(shiin: .t, x: 1 / 6, y: 3 / 8),
        HiraganaPosition(shiin: .n, x: 3 / 6, y: 3 / 8),
        HiraganaPosition(shiin: .h, x: 5 / 6, y: 3 / 8),
        HiraganaPosition(shiin: .m, x: 1 / 6, y: 5 / 8),
        HiraganaPosition(shiin: .y, x: 3 / 6, y: 5 / 8),
        HiraganaPosition(shiin: .r, x: 5 / 6, y: 5 / 8),
        HiraganaPosition(shiin: .w, x: 3 / 6, y: 7 / 8),
    ]
    GestureKeyboardView(
        hiraganaPositions: hiraganaPositions,
        onCandidatesGenerated: { res in
            print("Result count: \(res.count)")
            for (index, result) in res.prefix(3).enumerated() {
                print("Result \(index): \(result.text), Confidence: \(result.confidence)")
            }
        }
    )
    .edgesIgnoringSafeArea(.all)
}
