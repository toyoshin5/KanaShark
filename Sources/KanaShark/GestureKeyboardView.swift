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
        hiraganaPositions: [HiraganaPosition] = .default,
        minConfidence: CGFloat = 0.001,
        style: GestureKeyboardStyle = GestureKeyboardStyle(),
        onGestureStarted: @escaping (() -> Void) = {},
        onGestureEnded: @escaping (([CGPoint]) -> Void) = { _ in },
        onCandidatesGenerated: @escaping ([GestureKeyboardResult]) -> Void
    ) {
        vm = GestureKeyboardViewModel(
            hiraganaPositions: hiraganaPositions,
            minConfidence: minConfidence,
            style: style,
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
                .strokedPath(.init(lineWidth: vm.style.traceLineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(vm.style.traceColor)

                // 全てのひらがなを配置
                ForEach(vm.hiraganaPositions, id: \.self) { position in
                    let shiin = position.shiin
                    Text(shiin.rawValue)
                        .font(vm.style.font)
                        .foregroundColor(vm.style.textColor)
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
                    .tint(vm.style.loadingIndicatorColor)
                    .foregroundStyle(vm.style.loadingIndicatorColor)
                }
            }
        }
        .task(vm.task)
    }
}

#Preview("Shiin") {
    GestureKeyboardView(
        hiraganaPositions: .default, // Hiragana layout (default recommended)
        minConfidence: 0.001,        // Confidence threshold for candidate generation
        style: GestureKeyboardStyle( // Keyboard appearance
            font: .system(size: 18, weight: .bold),
            textColor: .primary,
            traceColor: .primary.opacity(0.5),
            traceLineWidth: 8,
            loadingIndicatorColor: .primary
        ),
        onGestureStarted: {
            // Callback when gesture starts
        },
        onGestureEnded: { points in
            // Callback when gesture ends (receives array of trace points)
        },
        onCandidatesGenerated: { results in
            // Receives candidate results (array of GestureKeyboardResult)
            for (index, result) in results.prefix(10).enumerated() {
                print("Result \(index): \(result.text), Confidence: \(result.confidence)")
            }
        }
    ).frame(width: 200, height: 200)
}
