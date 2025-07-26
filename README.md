# KanaShark

KanaShark is a SwiftPM package that implements a new Japanese input method for small screens such as iOS and watchOS. By using SHARK2-based word prediction for gesture operations tracing consonants, it enables fast Japanese text input.

## Background

Japanese input on small touchscreens is challenging, often relying on voice input or candidate selection. Flick keyboards also suffer from the "fat finger problem" due to small keys. Gesture input, which allows entering entire words with a single stroke, is attracting attention as an efficient method. This project applies a consonant-tracing approach combined with SHARK2 technology to Japanese input.

## Swift Package Manager (SPM) Integration

You can add KanaShark as a dependency using Swift Package Manager in two ways:

**Method 1: Using Xcode**

1. Go to `File → Add Package Dependencies...`
2. Enter the following URL:
   ```
   https://github.com/toyoshin5/SystemUsabilityScaleJP
   ```
3. Click `Add Package`

**Method 2: Edit Package.swift Directly**

Add the following to your `dependencies` array:

```swift
.dependencies: [
    .package(url: "https://github.com/toyoshin5/SystemUsabilityScaleJP", from: "0.1.0")
]
```
---
## Usage

You can use Japanese gesture input simply by displaying GestureKeyboardView in SwiftUI.

```swift
import KanaShark

struct ContentView: View {
    var body: some View {
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
}
```

![2025-07-24 16 51 42](https://github.com/user-attachments/assets/fb06565d-5833-420c-a7aa-fa6b8d428029)


Arguments:

- `hiraganaPositions`: Hiragana layout on the keyboard (default recommended)
- `minConfidence`: Confidence threshold for candidate generation (smaller = more candidates)
- `style`: Keyboard appearance (font, color, line width, etc.)
- `onGestureStarted`: Callback when gesture starts
- `onGestureEnded`: Callback when gesture ends (array of trace points)
- `onCandidatesGenerated`: Callback when candidates are generated (result array)

## Processing Flow

1. After gesture input, calculate the likelihood of each word in the dictionary based on the trajectory
2. Return word candidates with likelihood above a threshold, sorted by likelihood

## Dictionary

- Uses [Japanese Web Corpus 2010](https://www.s-yata.jp/corpus/nwc2010/)
- 100,000 entries each for 1-gram/2-gram, 20,000 each for 3-gram/4-gram, 10,000 for 5-gram, totaling 250,000 words
- Readings generated with Mecab
- 4-gram/5-gram words are for fixed phrases

## References

- SHARK2: [ACM Paper](https://dl.acm.org/doi/10.1145/1029632.1029640)
