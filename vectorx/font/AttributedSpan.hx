package vectorx.font;

import types.Range;

class AttributedSpan
{
    public var range(default, null): Range;
    public var font: Font;

    public function new(range: Range)
    {
        this.range = range;
    }

    public function apply(span: AttributedSpan)
    {
        if (span.font != null)
        {
            font = span.font;
        }
    }
}
