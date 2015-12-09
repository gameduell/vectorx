package vectorx.font;

import types.VerticalAlignment;
import types.HorizontalAlignment;
import vectorx.font.AttributedString;
import types.RectI;
import vectorx.font.FontContext.TextLayoutConfig;

class TextLayout
{
    public var lines(default, null): Array<TextLine>;
    public var height(default, null): Float = 0;
    public var config(default,  null): TextLayoutConfig;
    public var rect(default, null): RectI;

    public function new(string: AttributedString, layoutConfing: TextLayoutConfig, rect: RectI)
    {
        this.config = layoutConfing;
        this.rect = rect;
        lines = TextLine.calculate(string, rect.width, config.pointsToPixelRatio);
        height = calculateTextHeight(lines);
    }

    private static function textFits(lines: Array<TextLine>, height: Float, rect: RectI): Bool
    {
        if (lines.length > 1)
        {
            if (height >= rect.height)
            {
                return false;
            }
        }

        if (lines[0].width >= rect.width)
        {
            return false;
        }

        return true;
    }

    private static function calculateTextHeight(lines: Array<TextLine>)
    {
        var height: Float = 0;
        for (line in lines)
        {
            height += line.maxBgHeight;
        }

        return height;
    }

    public function alignX(line: TextLine): Float
    {
        switch (config.horizontalAlignment)
        {
            case null | HorizontalAlignment.Left:
                {
                    return rect.x;
                }
            case HorizontalAlignment.Right:
                {
                    return rect.x + rect.width - line.width;
                }
            case HorizontalAlignment.Center:
                {
                    return rect.x + (rect.width - line.width) / 2;
                }
        }
    }

    public function alignY(): Float
    {
        switch (config.verticalAlignment)
        {
            case null | VerticalAlignment.Top:
                {
                    return rect.y;
                }
            case VerticalAlignment.Bottom:
                {
                    return rect.y + rect.height - height;
                }
            case VerticalAlignment.Middle:
                {
                    return rect.y + (rect.height - height) / 2;
                }
        }
    }
}
