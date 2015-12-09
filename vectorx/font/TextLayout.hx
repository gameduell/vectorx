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
    public var pixelRatio(default, null): Float;

    public function new(string: AttributedString, layoutConfing: TextLayoutConfig, rect: RectI)
    {
        this.config = layoutConfing;
        this.rect = rect;
        this.pixelRatio = config.pointsToPixelRatio;

        lines = TextLine.calculate(string, rect.width, config.pointsToPixelRatio);
        height = calculateTextHeight(lines, string.string);

        if (config.layoutBehaviour == LayoutBehaviour.AlwaysFit)
        {
            fitPixelRatio(string);
        }
    }

    private function fitPixelRatio(string: AttributedString)
    {
        //trace('fitPixelRatio');
        if (textFits(lines, height, rect))
        {
            //trace('already fits');
            return;
        }

        //trace('initial ratio: $pixelRatio');

        var begin: Float = 0;
        var end: Float = pixelRatio;
        var iteration: Int = 0;
        var lastRatio: Float = 0;
        while(end - begin > 0.05)
        {
            lastRatio = (begin + end) / 2;
            var lines = TextLine.calculate(string, rect.width, lastRatio);
            var height = calculateTextHeight(lines, string.string);

            if (textFits(lines, height, rect))
            {
                //trace('begin: $lastRatio');
                begin = lastRatio;
                this.lines = lines;
                this.height = height;
                pixelRatio = begin;
            }
            else
            {
                //trace('end: $lastRatio');
                end = lastRatio;
            }

            iteration++;
        }

        //trace('found ratio: $pixelRatio in $iteration');
    }

    private static function textFits(lines: Array<TextLine>, height: Float, rect: RectI): Bool
    {
        if (lines.length > 1)
        {
            //trace('height: $height rectHeight: ${rect.height}');
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

    private static function calculateTextHeight(lines: Array<TextLine>, string: String)
    {
        var height: Float = 0;
        for (line in lines)
        {
            height += line.maxBgHeight;
            //trace('line: ${string.substr(line.begin, line.lenght)} lineHeight: ${line.maxBgHeight} total: $height}');
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
