package vectorx.font;

import lib.ha.core.utils.Debug;
import types.Range;
class AttributedSpanStorage
{
    private var spans: Array<AttributedSpan> = [];

    public function new()
    {
    }

    public function addSpan(newSpan: AttributedSpan): Void
    {
        if (spans.length == 0)
        {
            spans.push(newSpan);
            return;
        }

        var generatedSpans: Array<AttributedSpan> = [];
        var newSpanRange: Range = newSpan.range;

        for (span in spans)
        {
            var spanRange: Range = newSpan.range;
            var spanRightBound: Int = spanRange.index + spanRange.length;
            var newSpanRightBound: Int = newSpanRange.index + newSpanRange.length;

            //new span before current span
            if (newSpanRightBound < spanRange.index + spanRange.length)
            {
                continue;
            }

            //new span after current span
            if (spanRange.index > newSpanRightBound)
            {
                break;
            }

            //new span cover current partially from left side
            if (newSpanRightBound >=  spanRange.index && newSpanRightBound < spanRightBound)
            {
                var coverLength: Int = newSpanRightBound - spanRange.index;

                spanRange.length = spanRange.length - coverLength;
                var coverSpan: AttributedSpan = new AttributedSpan(new Range(spanRange.index, coverLength));
                spanRange.index = newSpanRightBound;

                coverSpan.apply(span);
                coverSpan.apply(newSpan);
                generatedSpans.push(coverSpan);

                continue;
            }

            //new span fully covers current one
            if (newSpanRange.index < spanRange.index && newSpanRightBound > spanRightBound)
            {
                span.apply(newSpan);
                continue;
            }

            //new span covers current partially from right side
            if (!(newSpanRange.index > spanRange.index && newSpanRightBound > spanRightBound))
            {
                Debug.brk();
            }

            var coverLenght: Int = spanRightBound - newSpanRange.index;
            spanRange.length -= coverLenght;
            var coverSpan: AttributedSpan = new AttributedSpan(new Range(newSpanRange.index, coverLenght));
            coverSpan.apply(span);
            coverSpan.apply(newSpan);
            generatedSpans.push(coverSpan);

        }

        spans.concat(generatedSpans);

        spans.sort(function(a: AttributedSpan, b: AttributedSpan)
        {
            if (a.range.index == b.range.index)
            {
                return 0;
            }

            if (a.range.index > b.range.index)
            {
                return 1;
            }

            return -1;
        })
    }
}
