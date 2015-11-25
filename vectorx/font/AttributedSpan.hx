package vectorx.font;

import vectorx.font.AttributedString.StringAttributes;
import types.Range;

class AttributedSpan
{
    public var range(default, null): Range;
    public var font: Font = null;
    public var id: Int;
    private static var nextId: Int = 0;

    public function new(range: Range)
    {
        this.range = range;
        id = nextId++;
    }

    public function toString(): String
    {
        return 'AttributedSpan: {id: $id, index: ${range.index} length: ${range.length}}';
    }

    public function apply(span: AttributedSpan)
    {
        if (span.font != null)
        {
            font = span.font;
        }
    }

    public function applyAttributes(attributes: StringAttributes)
    {
        if (attributes.font != null)
        {
            font = attributes.font;
        }
    }
}
