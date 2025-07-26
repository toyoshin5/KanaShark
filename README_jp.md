# KanaShark

KanaSharkは、iOSやwatchOSなどの小型画面向けに新しい日本語入力方式を実装したSwiftPMパッケージです。子音をなぞるジェスチャ操作に対してSHARK2に基づく単語予測を用いることで、高速な日本語入力を可能にします。

## 背景

小型タッチスクリーンでは日本語入力が困難で、音声入力や候補選択に頼ることが多くなります。フリックキーボードもキーが小さいため「ファットフィンガー問題」が発生します。ジェスチャ入力は、単語全体を一筆書きで入力できる効率的な方法として注目されています。本研究では、子音をなぞるアプローチにSHARK2技術を組み合わせて日本語入力に応用します。

## 処理の流れ

1. ジェスチャ入力後、軌跡に基づき辞書内各単語の尤度を計算
2. 尤度が一定以上の単語候補を尤度順に返す

## 辞書

- [日本語Webコーパス2010](https://www.s-yata.jp/corpus/nwc2010/)を使用
- 頻度1000以上のファイル: [file list](https://s3-ap-northeast-1.amazonaws.com/nwc2010-ngrams/word/over999/filelist)
- 1-gram/2-gram各10万件、3-gram/4-gram各2万件、5-gram1万件の計25万語
- Mecabで読みを生成
- 4-gram/5-gramは定型文用

## 参考文献

- SHARK2: [ACM論文](https://dl.acm.org/doi/10.1145/1029632.1029640)

---
## 使い方

SwiftUIでGestureKeyboardViewを表示するだけで日本語ジェスチャ入力が利用できます。
入力したジェスチャに基づいて、候補を`onCandidatesGenerated`コールバックで受け取ることができます。

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

動作例


各引数の説明:

- `hiraganaPositions`: キーボード上のひらがな配置（デフォルト推奨）
- `minConfidence`: 候補生成の信頼度しきい値（小さいほど多くの候補）
- `style`: キーボードの見た目（フォント・色・線幅など）
- `onGestureStarted`: ジェスチャ開始時のコールバック
- `onGestureEnded`: ジェスチャ終了時のコールバック（軌跡座標配列）
- `onCandidatesGenerated`: 候補生成時のコールバック（結果配列）
