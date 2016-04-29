package vectorx.svg;

import aggx.core.StreamInterface;
import aggx.svg.SVGElement;
import aggx.svg.SVGData;
import aggx.core.geometry.AffineTransformer;
import aggx.core.memory.Ref;
import aggx.color.GradientRadialFocus;
import aggx.color.SpanGradient.SpreadMethod;
import aggx.color.RgbaColor;
import aggx.color.ColorArray;
import haxe.Utf8;
import aggx.core.math.Calc;
import aggx.svg.gradients.SVGGradient;

class SvgSerializer
{
    private static var header: Int = 0x5643424e;//VCBN
    private static var currentVersion: Int = 1;

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

    public static function writeString(data: StreamInterface, value: String): Void
    {
        if (value == null)
        {
            data.writeUInt16(0);
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

        for (i in 0 ... encoded.length)
        {
            var char: Int = encoded.charCodeAt(i);
            data.writeUInt8(char);
        }
    }

    public static function readString(data: StreamInterface): String
    {
        var len = data.readUInt16();

        var buf: StringBuf = new StringBuf();

        for (i in 0 ... len)
        {
            var char: UInt = data.readUInt8();
            buf.addChar(char);
        }

        #if !cpp
            return utf8Decode(buf.toString());
        #else
            return buf.toString();
        #end
    }

    public static function writeRgbaColor(data: StreamInterface, value: RgbaColor): Void
    {
        data.writeUInt8(value.r);
        data.writeUInt8(value.g);
        data.writeUInt8(value.b);
        data.writeUInt8(value.a);
    }

    public static function readRgbaColor(data: StreamInterface, value: RgbaColor): Void
    {
        value.r = data.readUInt8();
        value.g = data.readUInt8();
        value.b = data.readUInt8();
        value.a = data.readUInt8();
    }

    public static function writeColorArray(data: StreamInterface, value: ColorArray): Void
    {
        data.writeUInt16(value.size);
        for (i in 0 ... value.size)
        {
            writeRgbaColor(data, value.get(i));
        }
    }

    public static function readColorArray(data: StreamInterface): ColorArray
    {
        var size: Int = data.readUInt16();
        var value = new ColorArray(size);

        for (i in 0 ... value.size)
        {
            var color = new RgbaColor();
            readRgbaColor(data, color);
            value.set(color, i);
        }

        return value;
    }

    public static function writeAffineTransformer(data: StreamInterface, value: AffineTransformer): Void
    {

        data.writeFloat32(value.sx);
        data.writeFloat32(value.shy);
        data.writeFloat32(value.shx);
        data.writeFloat32(value.sy);
        data.writeFloat32(value.tx);
        data.writeFloat32(value.ty);
    }

    public static function readAffineTransformer(data: StreamInterface, value: AffineTransformer): Void
    {
        value.sx = data.readFloat32();
        value.shy = data.readFloat32();
        value.shx = data.readFloat32();
        value.sy = data.readFloat32();
        value.tx = data.readFloat32();
        value.ty = data.readFloat32();
    }

    public static function writeSvgData(data: StreamInterface, value: SVGData): Void
    {
        data.writeUInt32(header);
        data.writeUInt32(currentVersion);
        SvgVectorPathSerializer.writeVectorPath(data, value.storage);
        data.writeUInt32(value.elementStorage.length);
        for(i in 0 ... value.elementStorage.length)
        {
            SvgElementSerializer.writeSVGElement(data, value.elementStorage[i]);
        }

        data.writeUInt32(value.gradientManager.getCount());
        for (grad in value.gradientManager)
        {
            SvgGradientSerializer.writeGradient(data, grad);
        }

        data.writeFloat32(value.expandValue);

        data.writeFloat32(value.width);
        data.writeFloat32(value.height);
    }

    public static function readSvgData(data: StreamInterface, value: SVGData): Void
    {
        if (data.readUInt32() != header)
        {
            throw "Invalid file, wrong header";
        }

        var version = data.readUInt32();
        if (currentVersion != version)
        {
            throw "Invalid file, invalid version $version (expected $currentVersion)";
        }

        SvgVectorPathSerializer.readVectorData(data, value.storage);

        var elements: Int = data.readUInt32();

        value.elementStorage = [];
        for (i in 0 ... elements)
        {
            var element = SVGElement.create();
            element.calculateBoundingBox(value.storage);
            SvgElementSerializer.readSVGElement(data, element);
            value.elementStorage.push(element);
        }

        var gradients: Int = data.readUInt32();

        value.gradientManager.removeAll();

        for (i in 0 ... gradients)
        {
            var gradient = new SVGGradient();
            SvgGradientSerializer.readGradient(data, gradient);
            value.gradientManager.addGradient(gradient);
        }

        value.expandValue = data.readFloat32();

        value.width = data.readFloat32();
        value.height = data.readFloat32();
    }
}
