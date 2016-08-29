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
    public var outputRectI(default, null): RectI;
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
        outputRect.height = calculateTextHeight(lines, string.string, config.scale);

        if (config.layoutBehaviour == LayoutBehaviour.AlwaysFit)
        {
            fitPixelRatio(string, attachmentResolver);
        }

        calculateTextWidth(lines, string.string);
        outputRect.y = alignY();

        outputRectI = new RectI();
        outputRectI.x = Math.floor(outputRect.x);
        outputRectI.y = Math.floor(outputRect.y);
        outputRectI.width = Math.ceil(outputRect.width);
        outputRectI.height = Math.ceil(outputRect.height);
    }

    private function fitPixelRatio(string: AttributedString, attachmentResolver: String -> Float -> FontAttachment)
    {
        trace('out_h: ${outputRect.height}');

        if (textFits(lines, outputRect.height, rect) == 0)
        {
            return;
        }

        var begin: Float = 0;
        var end: Float = pixelRatio;
        var error = outputRect.height;
        var iteration: Int = 0;
        var lastRatio: Float = 0;
        var lines: Array<TextLine> = [];
        var height: Float = 0;

        while(error > 2)
        {
            lastRatio = (begin + end) / 2;
            trace('ratio: $lastRatio');
            lines = TextLine.calculate(string, rect.width, attachmentResolver, lastRatio);
            height = calculateTextHeight(lines, string.string, lastRatio);

            var cur = textFits(lines, height, rect);
            if (cur == 0)
            {
                trace('begin = $lastRatio');
                begin = lastRatio;
                this.lines = lines;
                this.outputRect.height = height;
                pixelRatio = begin;
            }
            else
            {
                trace('end = $lastRatio');
                end = lastRatio;
                error = cur;
            }

            iteration++;
        }

        //does not fits, but with low margin
        if (textFits(lines, height, rect) > 0)
        {
            this.lines = lines;
            this.outputRect.height = height;
            pixelRatio = lastRatio;
            trace('$pixelRatio');
        }

        pixelRatio = begin;
        //intentionally left for debugging
        trace('found ratio: $pixelRatio in $iteration');
    }

    private static function textFits(lines: Array<TextLine>, height: Float, rect: RectI): Int
    {
        trace('textFits() height: $height rectHeight: ${rect.height}');
        if (height > rect.height)
        {
            trace('height does not fit');
            return Math.floor(height - rect.height);
        }

        for (line in lines)
        {
            if (line.width > rect.width)
            {
                trace('lineWidth: ${line.width} rectHeight: ${rect.height}');
                return Math.floor(line.width - rect.width);
            }
        }

        trace('fits');
        return 0;
    }

    private static function calculateTextHeight(lines: Array<TextLine>, string: String, pixelRatio: Float): Float
    {
        if (lines.length == 0)
        {
            return 0;
        }

        var height: Float = 0;

        for (i in 0 ... lines.length)
        {
            var line: TextLine = lines[i];
            var isLastLine: Bool = i == lines.length - 1;
            var isFirstLine: Bool = i == 0;

            if (isLastLine)
            {
                height += line.maxBgHeightWithShadow;
            }
            else
            {
                height += line.maxBgHeight;
            }

            if(!isFirstLine && line.spans.length > 0)
            {
                var span = line.spans[0];
                if (span.extraLineSpacing != null)
                {
                    height += span.extraLineSpacing * pixelRatio;
                }
            }

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
