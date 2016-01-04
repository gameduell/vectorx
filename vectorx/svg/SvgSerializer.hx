package vectorx.svg;

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

    public static function writeSvgStop(data: Data, value: SVGStop): Void
    {
        writeRgbaColor(data, value.color);
        data.writeFloat32(value.offset);

        data.offset += 4;
    }

    public static function readSvgStop(data: Data, value: SVGStop): Void
    {
        if (value.color == null)
        {
            value.color = new RgbaColor();
        }
        readRgbaColor(data, value.color);
        value.offset = data.readFloat32();
        data.offset += 4;
    }

    public static function writeAffineTransformer(data: Data, value: AffineTransformer): Void
    {
        data.writeFloat32(value.sx);
        data.offset += 4;
        data.writeFloat32(value.shy);
        data.offset += 4;
        data.writeFloat32(value.shx);
        data.offset += 4;
        data.writeFloat32(value.sy);
        data.offset += 4;
        data.writeFloat32(value.tx);
        data.offset += 4;
        data.writeFloat32(value.ty);
        data.offset += 4;
    }

    public static function readAffineTransformer(data: Data, value: AffineTransformer): Void
    {
        value.sx = data.readFloat32();
        data.offset += 4;
        value.shy = data.readFloat32();
        data.offset += 4;
        value.shx = data.readFloat32();
        data.offset += 4;
        value.sy = data.readFloat32();
        data.offset += 4;
        value.tx = data.readFloat32();
        data.offset += 4;
        value.ty = data.readFloat32();
        data.offset += 4;
    }

    private static var isRadialGradient: Int = 1;
    private static var isPad: Int = 1 << 1;
    private static var isReflect: Int = 1 << 2;
    private static var isRepeat: Int = 1 << 3;
    private static var isUserSpace: Int = 1 << 4;

    public static function writeGradient(data: Data, value: SVGGradient): Void
    {
        //trace('writeGradient()');
        var flags: Int = 0;
        if (value.type == GradientType.Radial)
        {
            flags |= isRadialGradient;
        }

        if (value.userSpace == true)
        {
            flags |= isUserSpace;
        }

        switch (value.spreadMethod)
        {
            case SpreadMethod.Pad: flags |= isPad;
            case SpreadMethod.Repeat: flags |= isRepeat;
            case SpreadMethod.Reflect: flags |= isReflect;
        }

        //trace('offset: ${data.offset} flags: $flags');
        data.writeUInt8(flags);
        data.offset++;

        //trace('offset: ${data.offset} id: ${value.id}');
        writeString(data, value.id);

        //trace('offset: ${data.offset} link: ${value.link}');
        writeString(data, value.link);

        //trace('offset: ${data.offset} stops: ${value.stops}');
        data.writeInt16(value.stops.length);
        data.offset += 2;

        for (i in value.stops)
        {
            writeSvgStop(data, i);
        }

        //trace('offset: ${data.offset} stops: ${value.transform}');
        writeAffineTransformer(data, value.transform);

        if (value.type == GradientType.Radial)
        {
            //trace('focal ${value.focalGradientParameters}');
            for (i in value.focalGradientParameters)
            {
                data.writeFloat32(i.value);
                data.offset += 4;
            }
        }
        else if (value.type == GradientType.Linear)
        {
            //trace('linear ${value.gradientVector}');
            for (i in value.gradientVector)
            {
                data.writeFloat32(i.value);
                data.offset += 4;
            }
        }
    }

    public static function readGradient(data: Data, value: SVGGradient)
    {
        //trace('readGradient()');
        var flags: Int = data.readUInt8();
        //trace('offset: ${data.offset} flags: ${flags}');
        data.offset++;

        if (flags & isRadialGradient != 0)
        {
            value.type = GradientType.Radial;
        }
        else
        {
            value.type = GradientType.Linear;
        }

        value.userSpace = flags & isUserSpace != 0;

        if (flags & isPad != 0)
        {
            value.spreadMethod = SpreadMethod.Pad;
        }
        else if (flags & isRepeat != 0)
        {
            value.spreadMethod = SpreadMethod.Repeat;
        }
        else if (flags & isReflect != 0)
        {
            value.spreadMethod = SpreadMethod.Reflect;
        }

        //trace('offset: ${data.offset} id:');
        value.id = readString(data);
        //trace(value.id);
        //trace('offset: ${data.offset} link:');
        value.link = readString(data);
        //trace(value.link);

        //trace('offset: ${data.offset} stops:');
        var stops: Int = data.readInt16();
        data.offset += 2;
        //trace('$stops');

        for (i in 0 ... stops)
        {
            var stop = new SVGStop();
            readSvgStop(data, stop);
            value.stops.push(stop);
        }
        //trace('stops: ${value.stops}');


        //trace('offset: ${data.offset} transform:');
        if (value.transform == null)
        {
            value.transform = new AffineTransformer();
        }
        readAffineTransformer(data, value.transform);
        //trace(value.transform);

        if (value.type == GradientType.Radial)
        {
            for (i in 0 ... value.focalGradientParameters.length)
            {
                if (value.focalGradientParameters[i] == null)
                {
                    value.focalGradientParameters[i] = Ref.getFloat();
                }

                value.focalGradientParameters[i].value = data.readFloat32();
                data.offset += 4;
            }

            //trace('focal ${value.focalGradientParameters}');
        }
        else if (value.type == GradientType.Linear)
        {
            for (i in 0 ... value.gradientVector.length)
            {
                if (value.gradientVector[i] == null)
                {
                    value.gradientVector[i] = Ref.getFloat();
                }

                value.gradientVector[i].value = data.readFloat32();
                data.offset += 4;
            }

            //trace('linear ${value.gradientVector}');
        }

        value.calculateColorArray(value.stops);
    }
}
