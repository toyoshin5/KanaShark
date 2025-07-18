# KanaGestureKeyboard

KanaGestureKeyboard is a SwiftPM package that implements a novel Japanese text input method for small screens, such as iOS and watchOS devices. It combines consonant gesture tracing with SHARK2-based word prediction to enable fast and accurate Japanese input, even on limited display areas.

## Overview

This project proposes a new input method for Japanese text entry on small screens, where traditional input methods struggle due to limited space. By tracing the consonants of a word as a single gesture and leveraging SHARK2's probabilistic word prediction, users can input Japanese more efficiently compared to conventional flick or tap-based methods.

## Background

Small touchscreens make Japanese text input difficult, often leading users to rely on voice input or candidate selection. While flick keyboards are common, small keys cause "fat finger" issues. Gesture-based input methods, which allow users to input entire words with a single gesture, offer a promising solution. This project adapts such approaches for Japanese by combining consonant tracing with SHARK2 technology.

## Proposed Method

- **Consonant Gesture Input**:  
  Users trace the consonant sequence of the desired word as a single stroke on the screen.  
  - Example: "らわか" → "りんご", "リンク", "論議", "リング"  
  - Example: "はたかさ" → "施す", "ホトトギス"  
  - Example: "めわかわ" → "民間", "メーカー"  
  Long vowels are treated as "wa" row.

- **Full Gesture Input** (not used in experiments):  
  Combines consonant tracing with short gestures toward vowel directions for each character, similar to smartphone flick input. This was found to be difficult and excluded from experiments.

## System Environment

- Supported platforms: iOS, watchOS
- Development: Xcode 16.4

## Processing Flow

1. After gesture input, the system calculates the likelihood of each word in the dictionary based on the traced path, following SHARK2's method (considering path shape, position, and word frequency).
2. Words with likelihood above 0.1% are displayed in hiragana order.
3. Users select the desired word from the candidates to confirm input. If not found, they can retry.

## Dictionary

- Based on [Japanese Web Corpus 2010](https://www.s-yata.jp/corpus/nwc2010/)
- Uses files with frequency ≥ 1000: [file list](https://s3-ap-northeast-1.amazonaws.com/nwc2010-ngrams/word/over999/filelist)
- 250,000 words: top 100,000 from 1-gram and 2-gram, 20,000 from 3-gram and 4-gram, 10,000 from 5-gram
- Readings generated using Mecab
- 4-gram and 5-gram are mainly for fixed phrases

## Reference

- SHARK2: [ACM Paper](https://dl.acm.org/doi/10.1145/1029632.1029640)

---

# KanaGestureKeyboard

KanaGestureKeyboardは、iOSやwatchOSなどの小型画面向けに新しい日本語入力方式を実装したSwiftPMパッケージです。子音をなぞるジェスチャ操作とSHARK2に基づく単語予測を組み合わせることで、限られた画面でも高速かつ正確な日本語入力を可能にします。

## 概要

本プロジェクトは、小型画面で従来の入力方式が困難な課題を解決するため、単語の子音列を一筆書きでなぞり、SHARK2の確率的単語予測を活用する新しい日本語入力方式を提案します。従来のフリック入力やタップ入力と比較し、より効率的な入力を目指します。

## 背景

小型タッチスクリーンでは日本語入力が困難で、音声入力や候補選択に頼ることが多くなります。フリックキーボードもキーが小さいため「ファットフィンガー問題」が発生します。ジェスチャ入力は、単語全体を一筆書きで入力できる効率的な方法として注目されています。本研究では、子音をなぞるアプローチにSHARK2技術を組み合わせて日本語入力に応用します。

## 提案手法

- **子音ジェスチャ入力**  
  入力したい単語の子音列を画面上で一筆書きでなぞる  
  - 例:「らわか」→「りんご」「リンク」「論議」「リング」  
  - 例:「はたかさ」→「施す」「ホトトギス」  
  - 例:「めわかわ」→「民間」「メーカー」  
  長音は「わ行」として扱う

- **フルジェスチャ入力**（実験では未使用）  
  子音ジェスチャに加え、各文字ごとに母音方向への短いジェスチャを加える方式。操作が難しく、実験では除外。

## 実行環境

- 対応プラットフォーム: iOS, watchOS
- 開発環境: Xcode 16.4

## 処理の流れ

1. ジェスチャ入力後、軌跡に基づき辞書内各単語の尤度を計算（SHARK2方式：軌跡形状・位置・出現頻度を考慮）
2. 尤度0.1%以上の単語候補をひらがな順で表示
3. 候補から選択して入力確定。なければ再入力可能

## 辞書

- [日本語Webコーパス2010](https://www.s-yata.jp/corpus/nwc2010/)を使用
- 頻度1000以上のファイル: [file list](https://s3-ap-northeast-1.amazonaws.com/nwc2010-ngrams/word/over999/filelist)
- 1-gram/2-gram各10万件、3-gram/4-gram各2万件、5-gram1万件の計25万語
- Mecabで読みを生成
- 4-gram/5-gramは定型文用

## 参考文献

- SHARK2: [ACM論文](https://dl.acm.org/doi/10.1145/1029632.1029640)

---
