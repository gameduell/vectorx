package vectorx.svg;

import lib.ha.svg.SVGElement;
import lib.ha.svg.SVGData;
import lib.ha.core.geometry.AffineTransformer;
import lib.ha.core.memory.Ref;
import lib.ha.aggx.color.GradientRadialFocus;
import lib.ha.aggx.color.SpanGradient.SpreadMethod;
import lib.ha.aggx.color.RgbaColor;
import lib.ha.aggxtest.AATest.ColorArray;
import haxe.Utf8;
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
        if (value == null)
        {
            data.writeUInt16(0);
            data.offset += 2;
            return;
        }

        if (value.length > 0xfffe)
        {
            throw "String is too long";
        }

        #if !cpp
            var encoded: String = utf8Encode(value);
        #else
            var encoded: String = value;
        #end

        data.writeUInt16(encoded.length);
        data.offset += 2;

        for (i in 0 ... encoded.length)
        {
            var char: Int = encoded.charCodeAt(i);
            data.writeUInt8(char);
            data.offset++;
        }
    }

    public static function readString(data: Data): String
    {
        var len = data.readInt16();
        data.offset += 2;

        var buf: StringBuf = new StringBuf();

        for (i in 0 ... len)
        {
            var char: UInt = data.readUInt8();
            data.offset++;

            buf.addChar(char);
        }

        #if !cpp
            return utf8Decode(buf.toString());
        #else
            return buf.toString();
        #end
    }

    public static inline function writeFloat(data: Data, value: Float)
    {
        data.writeFloat32(value);
        data.offset += 4;
    }

    public static inline function readFloat(data: Data): Float
    {
        var ret = data.readFloat32();
        data.offset += 4;
        return ret;
    }

    public static function writeRgbaColor(data: Data, value: RgbaColor): Void
    {
        data.writeUInt8(value.r);
        data.offset++;
        data.writeUInt8(value.g);
        data.offset++;
        data.writeUInt8(value.b);
        data.offset++;
        data.writeUInt8(value.a);
        data.offset++;
    }

    public static function readRgbaColor(data: Data, value: RgbaColor): Void
    {
        value.r = data.readUInt8();
        data.offset++;
        value.g = data.readUInt8();
        data.offset++;
        value.b = data.readUInt8();
        data.offset++;
        value.a = data.readUInt8();
        data.offset++;
    }

    public static function writeColorArray(data: Data, value: ColorArray): Void
    {
        data.writeUInt16(value.size);
        data.offset += 2;
        for (i in 0 ... value.size)
        {
            writeRgbaColor(data, value.get(i));
        }
    }

    public static function readColorArray(data: Data): ColorArray
    {
        var size: Int = data.readInt16();
        data.offset += 2;
        var value = new ColorArray(size);

        for (i in 0 ... value.size)
        {
            var color = new RgbaColor();
            readRgbaColor(data, color);
            value.set(color, i);
        }

        return value;
    }

    public static function writeAffineTransformer(data: Data, value: AffineTransformer): Void
    {
        writeFloat(data, value.sx);
        writeFloat(data, value.shy);
        writeFloat(data, value.shx);
        writeFloat(data, value.sy);
        writeFloat(data, value.tx);
        writeFloat(data, value.ty);
    }

    public static function readAffineTransformer(data: Data, value: AffineTransformer): Void
    {
        value.sx = readFloat(data);
        value.shy = readFloat(data);
        value.shx = readFloat(data);
        value.sy = readFloat(data);
        value.tx = readFloat(data);
        value.ty = readFloat(data);
    }

    public static function writeSvgData(data: Data, value: SVGData): Void
    {
        SvgVectorPathSerializer.writeVectorPath(value.storage);
        data.writeUInt32(value.elementStorage.length);
        data.offset += 4;
        for(i in 0 ... value.elementStorage.length)
        {
            SvgElementSerializer.writeSVGElement(data, value.elementStorage[i]);
        }

        data.writeUInt32(value.gradientManager.getCount());
        data.offset += 4;
        for (grad in value.gradientManager)
        {
            SvgGradientSerializer.writeGradient(data, grad);
        }

        data.writeInt32(value.expandValue);
        data.offset += 4;
    }

    public static function readSvgData(data: Data, value: SVGData): Void
    {
        SvgVectorPathSerializer.readVectorData(value.storage);
        var elements: Int = data.readUInt32();
        data.offset += 4;

        value.elementStorage = [];
        for (i in 0 ... elements)
        {
            var element = new SVGElement();
            SvgElementSerializer.readSVGElement(data, elements);
            value.elementStorage.push(element);
        }

        var gradients: Int = data.readUInt32();
        data.offset += 4;

        value.gradientManager.removeAll();

        for (i in 0 ... gradients)
        {
            var gradient = new SVGGradient();
            SvgGradientSerializer.readGradient(data, gradient);
            value.gradientManager.addGradient(gradient);
        }

        value.expandValue = data.readInt32();
        data.offset += 4;
    }
}
