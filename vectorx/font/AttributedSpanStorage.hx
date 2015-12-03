package vectorx.font;

import lib.ha.core.math.Calc;
import lib.ha.core.utils.Debug;

class AttributedSpanStorage
{
    private var spans: Array<AttributedSpan> = [];
    private var tempSpan: AttributedSpan;

    public function new()
    {
        tempSpan = new AttributedSpan(new AttributedRange(), "");
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

            //trace('spanRange: $spanRange');
            //trace('spanRightBound: $spanRightBound');
            //trace('newSpanRightBound: $newSpanRightBound');

            //trace('newSpanRightBound($newSpanRightBound) <= spanRange.index(${spanRange.index})');
            if (newSpanRightBound <= spanRange.index)
            {
                //trace('new span before current span');
                continue;
            }

            if (spanRange.index > newSpanRightBound)
            {
                //trace('new span after current span');
                break;
            }

            //trace('newSpanRightBound($newSpanRightBound) >=  spanRange.index(${spanRange.index}) && newSpanRightBound($newSpanRightBound) < spanRightBound($spanRightBound) && newSpanRange.index(${newSpanRange.index}) < spanRange.index(${spanRange.index})');
            if (newSpanRightBound >  spanRange.index && newSpanRightBound < spanRightBound && newSpanRange.index < spanRange.index)
            {
                //trace('new span cover current partially from left side');
                var coverLength: Int = newSpanRightBound - spanRange.index;

                spanRange.length = spanRange.length - coverLength;
                var coverSpanRange = new AttributedRange(spanRange.index, coverLength);
                var coverSpan: AttributedSpan = new AttributedSpan(coverSpanRange, span.baseString);
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

            if (newSpanRange.index > spanRange.index && newSpanRange.index < spanRightBound && newSpanRightBound > spanRightBound)
            {
                //trace('new span covers current partially from right side');
                var coverLenght: Int = spanRightBound - newSpanRange.index;
                spanRange.length -= coverLenght;
                var coverSpanRange = new AttributedRange(newSpanRange.index, coverLenght);
                var coverSpan: AttributedSpan = new AttributedSpan(coverSpanRange, span.baseString);
                coverSpan.apply(span);
                coverSpan.apply(newSpan);
                generatedSpans.push(coverSpan);
                span.updateString();
                continue;
            }

            if (newSpanRange.index > spanRange.index && newSpanRightBound < spanRightBound)
            {
                //trace('new span area is fully inside current span');
                generatedSpans.push(newSpan);
                var spanRangeLength = newSpanRange.index - spanRange.index;
                var remainderSpanRange = new AttributedRange(newSpanRightBound, spanRange.length - spanRangeLength);
                var remainderSpan: AttributedSpan = new AttributedSpan(remainderSpanRange, span.baseString);
                spanRange.length = spanRangeLength;
                remainderSpan.apply(span);
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

    public function eachSpanInRange(cbk: AttributedSpan -> Void, begin: Int = 0, len: Int = -1): Void
    {
        if (spans.length == 0)
        {
            return;
        }

        if (len == -1)
        {
            len = spans[0].baseString.length - begin;
        }

        var end = begin + len;

        for (span in spans)
        {
            var spanRange = span.range;
            var spanBegin = spanRange.index;
            var spanEnd = spanRange.index +spanRange.length;

            if (end < spanBegin)
            {
                return;
            }

            if (begin > spanEnd)
            {
                continue;
            }

            if (begin <= spanBegin && end >= spanEnd)
            {
                cbk(span);
                continue;
            }

            var leftSegmentLen = begin - spanBegin;
            if (leftSegmentLen > 0)
            {
                tempSpan.setFromSpan(span);
                tempSpan.range.length = leftSegmentLen;
                tempSpan.updateString();
                cbk(tempSpan);
            }

            var middleSegmentBegin: Int = Calc.max(begin, spanBegin);
            var middleSegmentLen: Int = Calc.min(end, spanEnd) - middleSegmentBegin;
            if (middleSegmentLen > 0)
            {
                tempSpan.setFromSpan(span);
                tempSpan.range.index = middleSegmentBegin;
                tempSpan.range.length = middleSegmentLen;
                tempSpan.updateString();
                cbk(tempSpan);
            }

            var rightSegmentLen = spanEnd - end;
            if (rightSegmentLen > 0)
            {
                tempSpan.setFromSpan(span);
                tempSpan.range.index = end;
                tempSpan.range.length = rightSegmentLen;
                tempSpan.updateString();
                cbk(tempSpan);
            }
        }
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
