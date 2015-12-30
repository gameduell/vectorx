import lib.ha.core.memory.Ref;
import lib.ha.aggx.color.SpanGradient.SpreadMethod;
import lib.ha.aggx.color.RgbaColor;
import haxe.Utf8;
import lib.ha.svg.gradients.SVGGradient.SVGStop;
import lib.ha.svg.gradients.SVGGradient;
import lib.ha.svg.SVGData;
import vectorx.svg.SvgSerializer;
import types.Data;

class SvgSerializerTest extends unittest.TestCase
{
    public function testUtf(): Void
    {
        var srcString = "абвгдеёжзийклмнопрстуфхчцэюя";
        var utf = SvgSerializer.utf8Encode(srcString);
        assertEquals(srcString, SvgSerializer.utf8Decode(utf));
    }

    public function testBasicString(): Void
    {
        var srcString = "абвгдеёжзийклмнопрстуфхчцэюя";
        var data: Data = new Data(1024);

        SvgSerializer.writeString(data, srcString);

        data.offset = 0;
        var dstString = SvgSerializer.readString(data);

        assertEquals(srcString, dstString);
    }

    private function colorsEuals(a: RgbaColor, b: RgbaColor)
    {
        assertEquals(a.r, b.r);
        assertEquals(a.g, b.g);
        assertEquals(a.b, b.b);
        assertEquals(a.a, b.a);
    }

    private function stopsEquals(a: SVGStop, b: SVGStop)
    {
        colorsEuals(a.color, b.color);
        assertEquals(a.offset, b.offset);
    }

    public function testGradients(): Void
    {
        var data: Data = new Data(2048);

        var stop1: SVGStop = new SVGStop();
        stop1.offset = 0.1;
        stop1.color = new RgbaColor(50, 100, 150, 200);

        var stop2: SVGStop = new SVGStop();
        stop2.offset = 0.1;
        stop2.color = new RgbaColor(20, 30, 40, 50);

        var gradient1: SVGGradient = new SVGGradient();
        gradient1.type = GradientType.Linear;
        gradient1.stops.push(stop1);
        gradient1.stops.push(stop2);
        gradient1.id = "gradient1";
        gradient1.userSpace = true;
        gradient1.spreadMethod = SpreadMethod.Reflect;
        for (i in 0 ... gradient1.gradientVector.length)
        {
            var ref = Ref.getFloat();
            ref.value = 0.1;
            gradient1.gradientVector[i] = ref;
        }

        var gradient2: SVGGradient = new SVGGradient();
        gradient2.type = GradientType.Radial;
        gradient2.stops.push(stop1);
        gradient2.stops.push(stop2);
        gradient2.id = "gradient2";
        gradient2.link = "gradient1";
        gradient2.userSpace = true;
        gradient2.spreadMethod = SpreadMethod.Repeat;
        for (i in 0 ... gradient2.focalGradientParameters.length)
        {
            var ref = Ref.getFloat();
            ref.value = 0.1;
            gradient2.focalGradientParameters[i] = ref;
        }

        SvgSerializer.writeGradient(data, gradient1);
        SvgSerializer.writeGradient(data, gradient2);

        data.offset = 0;

        var gradient3: SVGGradient = new SVGGradient();
        var gradient4: SVGGradient = new SVGGradient();

        SvgSerializer.readGradient(data, gradient3);
        SvgSerializer.readGradient(data, gradient4);

        assertEquals(gradient1.type, gradient3.type);
        assertEquals(gradient1.id, gradient3.id);
        assertEquals(gradient1.userSpace, gradient3.userSpace);
        assertEquals(gradient1.spreadMethod, gradient3.spreadMethod);
        assertEquals(gradient1.gradientVector[0], gradient3.gradientVector[0]);
        assertEquals(gradient1.gradientVector[1], gradient3.gradientVector[1]);
        assertEquals(gradient1.gradientVector[2], gradient3.gradientVector[2]);
        stopsEquals(gradient1.stops[0], stop1);
        stopsEquals(gradient1.stops[1], stop2);

        assertEquals(gradient2.type, gradient4.type);
        assertEquals(gradient2.id, gradient4.id);
        assertEquals(gradient2.link, gradient4.link);
        assertEquals(gradient2.userSpace, gradient4.userSpace);
        assertEquals(gradient2.spreadMethod, gradient4.spreadMethod);
        assertEquals(gradient2.gradientVector[0], gradient4.gradientVector[0]);
        assertEquals(gradient2.gradientVector[1], gradient4.gradientVector[1]);
        assertEquals(gradient2.gradientVector[2], gradient4.gradientVector[2]);
        stopsEquals(gradient2.stops[0], stop1);
        stopsEquals(gradient2.stops[1], stop2);
    }
}
