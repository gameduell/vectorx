package vectorx.font;

import aggx.core.math.Calc;
import aggx.core.utils.Debug;

class AttributedSpanStorage
{
    public var spans(default, null): Array<AttributedSpan> = [];
    private var tempSpan: AttributedSpan;

    public function new()
    {
        tempSpan = new AttributedSpan("");
    }

    public function addSpan(newSpan: AttributedSpan): Void
    {
        //trace('AttributedSpanStorage::addSpan $newSpan');

        if (spans.length == 0)
        {
            spans.push(newSpan);
            return;
        }

        var generatedSpans: Array<AttributedSpan> = [];
        var newSpanRange: AttributedRange = newSpan.range;

        for (span in spans)
        {
            //trace('cur span: $span');

            var spanRange: AttributedRange = span.range;
            var spanRightBound: Int = spanRange.index + spanRange.length;
            var newSpanRightBound: Int = newSpanRange.index + newSpanRange.length;

            /*trace('spanRange: $spanRange');
            trace('newSpanRange: $newSpanRange');
            trace('spanRightBound: $spanRightBound');
            trace('newSpanRightBound: $newSpanRightBound');*/

            if (newSpanRange.index > spanRightBound)
            {
                //trace('new span after current span');
                continue;
            }

            if (newSpanRightBound < spanRange.index)
            {
                //trace('new span before current span');
                break;
            }

            //trace('newSpanRightBound($newSpanRightBound) >=  spanRange.index(${spanRange.index}) && newSpanRightBound($newSpanRightBound) < spanRightBound($spanRightBound) && newSpanRange.index(${newSpanRange.index}) < spanRange.index(${spanRange.index})');
            if (newSpanRightBound >  spanRange.index && newSpanRightBound < spanRightBound && newSpanRange.index <= spanRange.index)
            {
                //trace('new span cover current partially from left side');
                var coverLength: Int = newSpanRightBound - spanRange.index;

                spanRange.length = spanRange.length - coverLength;
                var coverSpan: AttributedSpan = new AttributedSpan(span.baseString, spanRange.index, coverLength);
                spanRange.index = newSpanRightBound;

                coverSpan.apply(span);
                coverSpan.apply(newSpan);
                generatedSpans.push(coverSpan);
                span.updateString();
                continue;
            }


            if (newSpanRange.index <= spanRange.index && newSpanRightBound >= spanRightBound)
            {
                //trace('new span fully covers current one');
                span.apply(newSpan);
                continue;
            }

            if (newSpanRange.index > spanRange.index && newSpanRange.index < spanRightBound && newSpanRightBound >= spanRightBound)
            {
                //trace('new span covers current partially from right side');
                var coverLenght: Int = spanRightBound - newSpanRange.index;
                spanRange.length -= coverLenght;
                var coverSpan: AttributedSpan = new AttributedSpan(span.baseString, newSpanRange.index, coverLenght);
                coverSpan.apply(span);
                span.attachment = null;
                span.attachmentId = null;
                coverSpan.apply(newSpan);
                generatedSpans.push(coverSpan);
                span.updateString();
                continue;
            }

            if (newSpanRange.index > spanRange.index && newSpanRightBound < spanRightBound)
            {
                //('new span area is fully inside current span');
                var tempSpan = new AttributedSpan("");
                tempSpan.setFromSpan(newSpan);
                tempSpan.applyBefore(span);
                tempSpan.attachment = null;
                tempSpan.attachmentId = null;
                //trace(tempSpan);
                generatedSpans.push(tempSpan);
                //generatedSpans.push(newSpan);
                var spanRangeLength = newSpanRange.index - spanRange.index;
                var remainderSpan: AttributedSpan = new AttributedSpan(span.baseString, newSpanRightBound, spanRange.length - spanRangeLength - newSpanRange.length);
                //trace('remainderSpan: $remainderSpan');
                spanRange.length = spanRangeLength;
                remainderSpan.apply(span);
                span.attachment = null;
                span.attachmentId = null;
                generatedSpans.push(remainderSpan);
                span.updateString();
                continue;
            }

            //trace('should not get here');
        }

        //trace('adding generated spans: $generatedSpans');

        spans = spans.concat(generatedSpans);

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
        });

        //trace('result spans: $spans');
    }

    public function iterator(): Iterator<AttributedSpan>
    {
        return spans.iterator();
    }

    public function toString(): String
    {
        var buf = new StringBuf();
        buf.add("[");
        for (span in spans)
        {
            buf.add('$span\n');
        }
        buf.add("]");

        return buf.toString();
    }
}
