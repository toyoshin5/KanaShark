//
//  KanaBoin.swift
//  WatchTyping
//
//  Created by Shingo Toyoda on 2025/05/08.
//

enum KanaBoin: String, Hashable {
    case a = "あ"
    case i = "い"
    case u = "う"
    case e = "え"
    case o = "お"

    static func fromKana(_ kana: String) -> KanaBoin? {
        return mapping[kana]
    }

    private static let mapping: [String: KanaBoin] = [
        // あ段
        "あ": .a, "か": .a, "が": .a, "さ": .a, "ざ": .a,
        "た": .a, "だ": .a, "な": .a, "は": .a, "ば": .a, "ぱ": .a,
        "ま": .a, "や": .a, "ゃ": .a, "ら": .a, "わ": .a, "ぁ": .a,

        // い段
        "い": .i, "き": .i, "ぎ": .i, "し": .i, "じ": .i,
        "ち": .i, "ぢ": .i, "に": .i, "ひ": .i, "び": .i, "ぴ": .i,
        "み": .i, "り": .i, "ぃ": .i, "を": .i,

        // う段
        "う": .u, "く": .u, "ぐ": .u, "す": .u, "ず": .u,
        "つ": .u, "づ": .u, "っ": .u, "ぬ": .u, "ふ": .u, "ぶ": .u, "ぷ": .u,
        "む": .u, "ゆ": .u, "ゅ": .u, "る": .u, "ゔ": .u, "ぅ": .u, "ん": .u,

        // え段
        "え": .e, "け": .e, "げ": .e, "せ": .e, "ぜ": .e,
        "て": .e, "で": .e, "ね": .e, "へ": .e, "べ": .e, "ぺ": .e,
        "め": .e, "れ": .e, "ぇ": .e, "ー": .e,

        // お段
        "お": .o, "こ": .o, "ご": .o, "そ": .o, "ぞ": .o,
        "と": .o, "ど": .o, "の": .o, "ほ": .o, "ぼ": .o, "ぽ": .o,
        "も": .o, "よ": .o, "ょ": .o, "ろ": .o, "ぉ": .o,
    ]
}
