import Foundation

extension Array where Element == HiraganaPosition {
    /// デフォルトのひらがなポジション配列
    public static var `default`: [HiraganaPosition] {
        [
            HiraganaPosition(shiin: .a, x: 1.0 / 6.0, y: 1.0 / 8.0),
            HiraganaPosition(shiin: .k, x: 3.0 / 6.0, y: 1.0 / 8.0),
            HiraganaPosition(shiin: .s, x: 5.0 / 6.0, y: 1.0 / 8.0),
            HiraganaPosition(shiin: .t, x: 1.0 / 6.0, y: 3.0 / 8.0),
            HiraganaPosition(shiin: .n, x: 3.0 / 6.0, y: 3.0 / 8.0),
            HiraganaPosition(shiin: .h, x: 5.0 / 6.0, y: 3.0 / 8.0),
            HiraganaPosition(shiin: .m, x: 1.0 / 6.0, y: 5.0 / 8.0),
            HiraganaPosition(shiin: .y, x: 3.0 / 6.0, y: 5.0 / 8.0),
            HiraganaPosition(shiin: .r, x: 5.0 / 6.0, y: 5.0 / 8.0),
            HiraganaPosition(shiin: .w, x: 3.0 / 6.0, y: 7.0 / 8.0),
        ]
    }
}
