import SwiftUI

public struct GestureKeyboardStyle {
    public var font: Font
    public var textColor: Color
    public var traceColor: Color
    public var traceLineWidth: CGFloat

    public init(
        font: Font = .system(size: 16, weight: .bold),
        textColor: Color = .white,
        traceColor: Color = .white.opacity(0.5),
        traceLineWidth: CGFloat = 6
    ) {
        self.font = font
        self.textColor = textColor
        self.traceColor = traceColor
        self.traceLineWidth = traceLineWidth
    }
}
