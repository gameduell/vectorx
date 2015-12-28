import lib.ha.svg.gradients.SVGGradient.SVGStop;
import lib.ha.svg.SVGData;
import vectorx.svg.SvgSerializer;
import types.Data;

class SvgSerializerTest extends unittest.TestCase
{
    public function testBasic(): Void
    {
        testDecode();

        var srcString = "абвгдеёжзийклмнопрстуфхчцэюя";
        var data: Data = new Data(1024);

        var utf = SvgSerializer.utf8Encode(srcString);
        var dbg: Array<Int> = [];
        for (i in 0 ... utf.length)
        {
            dbg.push(utf.charCodeAt(i));
        }
        trace('[${dbg.join(",")}]');
        trace(utf);

        trace(SvgSerializer.utf8Decode(utf));

        SvgSerializer.writeString(data, srcString);

        data.offset = 0;
        var dstString = SvgSerializer.readString(data);

        trace('dst: $dstString');
        assertTrue(srcString == dstString);
    }

    private function testDecode(): Void
    {
        var buf: StringBuf = new StringBuf();
        var dbgCodes: Array<Int> = [208,176,208,177,208,178,208,179,208,180,208,181,209,145,208,182,208,183,208,184,208,185,208,186,208,187,208,188,208,189,208,190,208,191,209,128,209,129,209,130,209,131,209,132,209,133,209,135,209,134,209,141,209,142,209,143];

        for (i in 0 ... dbgCodes.length)
        {
            buf.addChar(dbgCodes[i]);
        }

        trace(buf);
    }
}
