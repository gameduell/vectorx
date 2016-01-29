package vectorx.font;

import types.RectF;
import types.VerticalAlignment;
import types.HorizontalAlignment;
import vectorx.font.AttributedString;
import types.RectI;
import vectorx.font.FontContext.TextLayoutConfig;

class TextLayout
{
    public var lines(default, null): Array<TextLine>;
    public var outputRect(default, null): RectF;
    public var config(default,  null): TextLayoutConfig;
    public var rect(default, null): RectI;
    public var pixelRatio(default, null): Float;

    public function new(string: AttributedString, layoutConfing: TextLayoutConfig, rect: RectI, attachmentResolver: String -> Float -> FontAttachment)
    {
        this.outputRect = new RectF();
        outputRect.x = rect.width;
        outputRect.y = rect.height;
        this.config = layoutConfing;
        this.rect = rect;
        this.pixelRatio = config.scale;

        lines = TextLine.calculate(string, rect.width, attachmentResolver, config.scale);
        outputRect.height = calculateTextHeight(lines, string.string);

        if (config.layoutBehaviour == LayoutBehaviour.AlwaysFit)
        {
            fitPixelRatio(string, attachmentResolver);
        }

        calculateTextWidth(lines, string.string);
        outputRect.y = alignY();
    }

    private function fitPixelRatio(string: AttributedString, attachmentResolver: String -> Float -> FontAttachment)
    {
        //trace('fitPixelRatio');
        if (textFits(lines, outputRect.height, rect))
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
            var lines = TextLine.calculate(string, rect.width, attachmentResolver, lastRatio);
            var height = calculateTextHeight(lines, string.string);

            if (textFits(lines, height, rect))
            {
                //trace('begin: $lastRatio');
                begin = lastRatio;
                this.lines = lines;
                this.outputRect.height = height;
                pixelRatio = begin;
            }
            else
            {
                //trace('end: $lastRatio');
                end = lastRatio;
            }

            iteration++;
        }

        trace('found ratio: $pixelRatio in $iteration');
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

    private static function calculateTextHeight(lines: Array<TextLine>, string: String): Float
    {
        var height: Float = 0;
        for (line in lines)
        {
            height += line.maxBgHeight;
            //trace('line: ${string.substr(line.begin, line.lenght)} lineHeight: ${line.maxBgHeight} total: $height}');
        }

        return height;
    }

    private function calculateTextWidth(lines: Array<TextLine>, string: String): Void
    {
        for (line in lines)
        {
            if (line.width > outputRect.width)
            {
                outputRect.width = line.width;
                outputRect.x = alignX(line);
            }
        }
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
                    return rect.y + rect.height - outputRect.height;
                }
            case VerticalAlignment.Middle:
                {
                    return rect.y + (rect.height - outputRect.height) / 2;
                }
        }
    }
}
