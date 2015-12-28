package vectorx.svg;

import lib.ha.core.math.Calc;
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

    public static function utf8Encode(value: String): String
    {
        var buf: StringBuf = new StringBuf();

        for (i in 0 ... value.length)
        {
            var charCode: Int = value.charCodeAt(i);

            if (charCode < 128)
            {
                buf.addChar(charCode);
            }
            else if (charCode < 2048)
            {
                buf.addChar(192 + Calc.intDiv(charCode, 64));
                buf.addChar(128 + charCode % 64);
            }
            else if (charCode < 65536)
            {
                //(224 + (ch / 4096));
                buf.addChar(224 + Calc.intDiv(charCode, 4096));

                //(128 + ((ch / 64) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 64) % 64);

                //(128 + (ch % 64));
                buf.addChar(128 + charCode % 64);
            }
            else if (charCode < 2097152)
            {
                //(240 + (ch / 262144));
                buf.addChar(240 + Calc.intDiv(charCode, 262144));

                //(128 + ((ch / 4096) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 4096) % 64);

                //(128 + ((ch / 64) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 64) % 64);

                //(128 + (ch % 64));
                buf.addChar(128 + charCode % 64);
            }
            else if (charCode < 67108864)
            {
                //(248 + (ch / 16777216));
                buf.addChar(248 + Calc.intDiv(charCode, 16777216));

                //(128 + (ch / 262144) % 64);
                buf.addChar(128 + Calc.intDiv(charCode, 262144) % 64);

                //(128 + ((ch / 4096) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 4096) % 64);

                //(128 + ((ch / 64) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 64) % 64);

                //(128 + (ch % 64));
                buf.addChar(128 + charCode % 64);
            }
            else
            {
                //(252 + (ch / 1073741824)
                buf.addChar(252 + Calc.intDiv(charCode, 1073741824));

                //(128 + (ch / 16777216) % 64);
                buf.addChar(128 + Calc.intDiv(charCode, 16777216) % 64);

                //(128 + (ch / 262144) % 64);
                buf.addChar(128 + Calc.intDiv(charCode, 262144) % 64);

                //(128 + ((ch / 4096) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 4096) % 64);

                //(128 + ((ch / 64) % 64));
                buf.addChar(128 + Calc.intDiv(charCode, 64) % 64);

                //(128 + (ch % 64));
                buf.addChar(128 + charCode % 64);
            }
        }

        return buf.toString();
    }

    public static function utf8Decode(value: String): String
    {
        var buf: StringBuf = new StringBuf();
        var i: Int = 0;
        while(i < value.length)
        {
            var char: Int = value.charCodeAt(i);

            if (char < 127)
            {
                buf.addChar(char);
                i++;
            }
            else if (char >= 192 && char <= 223)
            {
                var char2: Int = value.charCodeAt(++i);
                //(z-192)*64 + (y-128)
                buf.addChar((char - 192) * 64 + (char2 - 128));
                i++;
            }
            else if (char >= 224 && char <= 239)
            {
                var char2: Int = value.charCodeAt(++i);
                var char3: Int = value.charCodeAt(++i);
                //(z-224)*4096 + (y-128)*64 + (x-128)
                buf.addChar((char - 224) * 4096 + (char2 - 128) * 64 + (char3 - 128));
                i++;
            }
            else if (char >= 240 && char <= 247)
            {
                var char2: Int = value.charCodeAt(++i);
                var char3: Int = value.charCodeAt(++i);
                var char4: Int = value.charCodeAt(++i);

                //(z-240)*262144 + (y-128)*4096 +(x-128)*64 + (w-128)
                buf.addChar((char - 224) * 262144 + (char2 - 128) * 4096 + (char3 - 128) * 64 + (char4 - 128));
                i++;
            }
            else if (char >= 248 && char <= 251)
            {
                var char2: Int = value.charCodeAt(++i);
                var char3: Int = value.charCodeAt(++i);
                var char4: Int = value.charCodeAt(++i);
                var char5: Int = value.charCodeAt(++i);

                // (z-248)*16777216 + (y-128)*262144 +(x-128)*4096 + (w-128)*64 + (v-128)
                buf.addChar((char - 224) * 16777216 + (char2 - 128) * 262144 + (char3 - 128) * 4096 + (char4 - 128) * 64 + (char5 - 128));
                i++;
            }
            else if (char >= 252 && char <= 253)
            {
                var char2: Int = value.charCodeAt(++i);
                var char3: Int = value.charCodeAt(++i);
                var char4: Int = value.charCodeAt(++i);
                var char5: Int = value.charCodeAt(++i);
                var char6: Int = value.charCodeAt(++i);

                //(z-252)*1073741824 + (y-128)*16777216 + (x-128)*262144 + (w-128)*4096 + (v-128)*64 + (u-128)
                buf.addChar((char - 224) * 1073741824 + (char2 - 128) * 16777216 + (char3 - 128) * 262144 + (char4 - 128) * 4096 + (char5 - 128) * 64 + (char6 - 128));
                i++;
            }
        }

        return buf.toString();
    }

    public static function writeString(data: Data, value: String): Void
    {
/*        if (value.length > 0xfffe)
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
        data.offset += utf8String.length;*/
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
