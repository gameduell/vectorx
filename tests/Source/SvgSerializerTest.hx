import vectorx.svg.SvgSerializer;
import types.Data;

class SvgSerializerTest extends unittest.TestCase
{
    public function testBasic(): Void
    {
        var srcString = "абвгдеёжзийклмнопрстуфхчцэюя";
        var data: Data = new Data(1024);

        SvgSerializer.writeString(data, srcString);

        data.offset = 0;
        var dstString = SvgSerializer.readString(data);

        trace('dst: $dstString');
        assertTrue(srcString == dstString);
    }
}
