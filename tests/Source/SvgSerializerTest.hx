import vectorx.svg.SvgDataWrapper;
import vectorx.svg.SvgGradientSerializer;
import aggx.vectorial.VertexBlockStorage;
import vectorx.svg.SvgElementSerializer;
import aggx.svg.SVGElement;
import aggx.core.geometry.AffineTransformer;
import aggx.core.memory.Ref;
import aggx.color.SpanGradient.SpreadMethod;
import aggx.color.RgbaColor;
import haxe.Utf8;
import aggx.svg.gradients.SVGGradient.SVGStop;
import aggx.svg.gradients.SVGGradient;
import aggx.svg.SVGData;
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
        var data = new SvgDataWrapper(new Data(1024));

        SvgSerializer.writeString(data, srcString);

        data.data.offset = 0;
        var dstString = SvgSerializer.readString(data);

        assertEquals(srcString, dstString);
    }

    private function assertEqualColors(a: RgbaColor, b: RgbaColor)
    {
        assertEquals(a.r, b.r);
        assertEquals(a.g, b.g);
        assertEquals(a.b, b.b);
        assertEquals(a.a, b.a);
    }

    private function assertEqualStops(a: SVGStop, b: SVGStop)
    {
        assertEqualColors(a.color, b.color);
        assertEquals(a.offset, b.offset);
    }

    private function assertEqualsFloat(a: Float, b: Float)
    {
        if (Math.abs(a - b) > 0.000001)
        {
            trace('$a is not equals $b');
        }

        assertTrue(Math.abs(a - b) < 0.000001);
    }

    private function assertEqualsTransform(transform1: AffineTransformer, transform2: AffineTransformer)
    {
        assertEqualsFloat(transform1.sx, transform2.sx);
        assertEqualsFloat(transform1.shy, transform2.shy);
        assertEqualsFloat(transform1.shx, transform2.shx);
        assertEqualsFloat(transform1.sy, transform2.sy);
        assertEqualsFloat(transform1.tx, transform2.tx);
        assertEqualsFloat(transform1.ty, transform2.ty);
    }

    public function testAffineTransformer(): Void
    {
        var data = new SvgDataWrapper(new Data(1024));
        ////return '{$sx, $shy, $shx, $sy, $tx, $ty}';
        var transform1 = new AffineTransformer(0.1, 0.2, 0.3, 0.4, 0.5, 0.6);
        SvgSerializer.writeAffineTransformer(data, transform1);

        data.data.offset = 0;

        var transform2 = new AffineTransformer();
        SvgSerializer.readAffineTransformer(data, transform2);

        assertEqualsTransform(transform1, transform2);
    }

    public function testGradients(): Void
    {
        var data = new SvgDataWrapper(new Data(1024));

        var stop1: SVGStop = new SVGStop();
        stop1.offset = 0.1;
        stop1.color = new RgbaColor(50, 100, 150, 200);

        var stop2: SVGStop = new SVGStop();
        stop2.offset = 0.1;
        stop2.color = new RgbaColor(20, 30, 40, 50);

        var gradient1: SVGGradient = new SVGGradient();
        gradient1.type = GradientType.Linear;
        gradient1.transform = new AffineTransformer(0.1, 0.2, 0.3, 0.4, 0.5, 0.6);
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
        gradient2.transform = new AffineTransformer(0.7, 0.8, 0.9, 1, 1.1, 1.2);
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

        SvgGradientSerializer.writeGradient(data, gradient1);
        SvgGradientSerializer.writeGradient(data, gradient2);

        data.data.offset = 0;

        var gradient3: SVGGradient = new SVGGradient();
        var gradient4: SVGGradient = new SVGGradient();

        SvgGradientSerializer.readGradient(data, gradient3);
        SvgGradientSerializer.readGradient(data, gradient4);

        assertEquals(gradient1.type, gradient3.type);
        assertEquals(gradient1.id, gradient3.id);
        assertEquals(gradient1.userSpace, gradient3.userSpace);
        assertEquals(gradient1.spreadMethod, gradient3.spreadMethod);
        assertEqualStops(gradient1.stops[0], stop1);
        assertEqualStops(gradient1.stops[1], stop2);

        assertEqualsTransform(gradient1.transform, gradient3.transform);

        assertEqualsFloat(gradient1.gradientVector[0].value, gradient3.gradientVector[0].value);
        assertEqualsFloat(gradient1.gradientVector[1].value, gradient3.gradientVector[1].value);
        assertEqualsFloat(gradient1.gradientVector[2].value, gradient3.gradientVector[2].value);
        assertEqualsFloat(gradient1.gradientVector[3].value, gradient3.gradientVector[3].value);

        assertEquals(gradient2.type, gradient4.type);
        assertEquals(gradient2.id, gradient4.id);
        assertEquals(gradient2.link, gradient4.link);
        assertEquals(gradient2.userSpace, gradient4.userSpace);
        assertEquals(gradient2.spreadMethod, gradient4.spreadMethod);
        assertEqualStops(gradient2.stops[0], stop1);
        assertEqualStops(gradient2.stops[1], stop2);

        assertEqualsTransform(gradient2.transform, gradient4.transform);

        assertEqualsFloat(gradient2.focalGradientParameters[0].value, gradient4.focalGradientParameters[0].value);
        assertEqualsFloat(gradient2.focalGradientParameters[1].value, gradient4.focalGradientParameters[1].value);
        assertEqualsFloat(gradient2.focalGradientParameters[2].value, gradient4.focalGradientParameters[2].value);
        assertEqualsFloat(gradient2.focalGradientParameters[3].value, gradient4.focalGradientParameters[3].value);
        assertEqualsFloat(gradient2.focalGradientParameters[4].value, gradient4.focalGradientParameters[4].value);
    }

    public function assertEqualsElement(a: SVGElement, b: SVGElement)
    {
        assertEquals(a.index, b.index);
        assertEqualsTransform(a.transform, b.transform);
        assertEquals(a.gradientId, b.gradientId);

        assertEquals(a.fill_flag, b.fill_flag);
        if (a.fill_flag)
        {
            assertEqualColors(a.fill_color, b.fill_color);
            assertEqualsFloat(a.fill_opacity, b.fill_opacity);
        }

        if (a.stroke_flag)
        {
            assertEqualColors(a.stroke_color, b.stroke_color);
            assertEqualsFloat(a.stroke_width, b.stroke_width);
        }

        assertEquals(a.even_odd_flag, b.even_odd_flag);
        assertEquals(a.line_join, b.line_join);
        assertEquals(a.line_cap, b.line_cap);
        assertEqualsFloat(a.miter_limit, b.miter_limit);
    }

    public function testElements(): Void
    {
        var data = new SvgDataWrapper(new Data(1024));

        var element1 = SVGElement.create();
        element1.index = 11;
        element1.transform = new AffineTransformer(0.1, 0.2, 0.3, 0.4, 0.5, 0.6);
        element1.gradientId = "g1";
        element1.fill(new RgbaColor(10, 20, 30, 40));
        element1.stroke(new RgbaColor(50, 60, 70, 80));
        element1.stroke_width = 0.2;
        element1.even_odd_flag = true;
        element1.line_join = 1;
        element1.line_cap = 2;
        element1.miter_limit = 0.5;

        SvgElementSerializer.writeSVGElement(data, element1);

        var element2 = SVGElement.create();

        data.data.offset = 0;
        SvgElementSerializer.readSVGElement(data, element2);

        assertEqualsElement(element1, element2);
    }

    public function testVertexBlockStorage(): Void
    {
        var data = new Data(1024);
        var wrap = new SvgDataWrapper();
        wrap.data = data;

        var storage = new VertexBlockStorage();
        storage.addVertex(0.1, 0.2, 0);
        storage.addVertex(0.2, 0.4, 1);
        storage.addVertex(0.3, 0.6, 2);
        storage.addVertex(0.4, 0.8, 3);

        storage.save(wrap);
        data.offset = 0;

        var storage2 = new VertexBlockStorage();
        storage2.load(wrap);

        assertEquals(storage.verticesCount, storage2.verticesCount);

        var x1: FloatRef = Ref.getFloat();
        var y1: FloatRef = Ref.getFloat();
        var x2: FloatRef = Ref.getFloat();
        var y2: FloatRef = Ref.getFloat();
        var cmd1: Int = 0;
        var cmd2: Int = 0;

        for (i in 0 ... storage.verticesCount)
        {
            cmd1 = storage.getVertex(i, x1, y1);
            cmd2 = storage2.getVertex(i, x2, y2);
            assertEquals(cmd1, cmd2);
            assertEqualsFloat(x1.value, x2.value);
            assertEqualsFloat(y1.value, y2.value);
        }

        Ref.putFloat(x1);
        Ref.putFloat(y1);
        Ref.putFloat(x2);
        Ref.putFloat(y2);
    }
}
