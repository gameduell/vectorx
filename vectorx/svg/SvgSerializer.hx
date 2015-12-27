package vectorx.svg;

import haxe.Utf8;
import lib.ha.svg.gradients.SVGGradient;
import types.Data;
import types.DataStringTools;

class SvgSerializer
{
    public static function isUtf8String(value: String): Bool
    {
        for (i in 0 ... value.length)
        {
            if (value.charCodeAt(i) > 255)
            {
                return false;
            }
        }

        return true;
    }

    public static function writeString(data: Data, value: String): Void
    {
        if (value.length > 0xfffe)
        {
            throw "String is too long";
        }

        var isUtf8: Bool = isUtf8String(value);

        data.writeUInt8(isUtf8String ? 1 : 0);
        data.offset += 2;

        data.writeUInt16(value.length);
        data.offset += 2;

        if (isUtf8String)
        {
            for (i in 0 ... value.length)
            {
                var char: Int = value.charCodeAt(i);
                trace('[$i] = $char');
                data.writeUInt8(char);
                data.offset++;
            }
        }
        else
        {

        }

        //DataStringTools.writeString(data, utf8String);
        data.offset += utf8String.length;
    }

    public static function readString(data: Data): String
    {
        var len = data.readInt16();
        data.offset += 2;

        trace('len: $len');

        var buf: StringBuf = new StringBuf();

        for (i in 0 ... len)
        {
            trace(i);
            var char: UInt = data.readUInt8();
            trace('char $char');
            data.offset++;

            buf.addChar(char);
        }

        return buf.toString();
    }

    /*public static function readGradient(data: Data, value: SVGGradient): SVGGradient
    {

    }

    public static function writeGradient(data: Data, value: SVGGradient): Void
    {

    }*/
}
