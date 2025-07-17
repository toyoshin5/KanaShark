//
//  KanaShiin.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/04/21.
//

struct KanaShiinPair: Hashable, Sendable {
    let first: KanaShiin
    let lastShiin: KanaShiin
}

public enum KanaShiin: String, Hashable, Sendable {
    case a = "あ"
    case k = "か"
    case s = "さ"
    case t = "た"
    case n = "な"
    case h = "は"
    case m = "ま"
    case y = "や"
    case r = "ら"
    case w = "わ"

    static func fromKana(_ kana: String) -> KanaShiin? {
        return mapping[kana]
    }

    private static let mapping: [String: KanaShiin] = [
        // あ行
        "あ": .a, "い": .a, "う": .a, "え": .a, "お": .a,
        "ぁ": .a, "ぃ": .a, "ぅ": .a, "ぇ": .a, "ぉ": .a,
        "ゔ": .a,

        // か行
        "か": .k, "き": .k, "く": .k, "け": .k, "こ": .k,
        "が": .k, "ぎ": .k, "ぐ": .k, "げ": .k, "ご": .k,

        // さ行
        "さ": .s, "し": .s, "す": .s, "せ": .s, "そ": .s,
        "ざ": .s, "じ": .s, "ず": .s, "ぜ": .s, "ぞ": .s,

        // た行
        "た": .t, "ち": .t, "つ": .t, "て": .t, "と": .t,
        "だ": .t, "ぢ": .t, "づ": .t, "で": .t, "ど": .t,
        "っ": .t,

        // な行
        "な": .n, "に": .n, "ぬ": .n, "ね": .n, "の": .n,

        // は行
        "は": .h, "ひ": .h, "ふ": .h, "へ": .h, "ほ": .h,
        "ば": .h, "び": .h, "ぶ": .h, "べ": .h, "ぼ": .h,
        "ぱ": .h, "ぴ": .h, "ぷ": .h, "ぺ": .h, "ぽ": .h,

        // ま行
        "ま": .m, "み": .m, "む": .m, "め": .m, "も": .m,

        // や行
        "や": .y, "ゆ": .y, "よ": .y,
        "ゃ": .y, "ゅ": .y, "ょ": .y,

        // ら行
        "ら": .r, "り": .r, "る": .r, "れ": .r, "ろ": .r,

        // わ行
        "わ": .w, "を": .w, "ん": .w, "ー": .w,
    ]

    static func convertToShiinArray(word: String) -> [KanaShiin] {
        var result = [KanaShiin]()
        for char in word {
            let kana = String(char)
            if let shiin = KanaShiin.fromKana(kana) {
                result.append(shiin)
            }
        }
        return result
    }
}
