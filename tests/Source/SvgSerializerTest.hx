import haxe.Utf8;
import lib.ha.svg.gradients.SVGGradient.SVGStop;
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
}
