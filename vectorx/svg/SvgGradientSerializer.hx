package vectorx.svg;

import aggx.core.memory.Ref;
import aggx.core.geometry.AffineTransformer;
import vectorx.svg.SvgSerializer;
import aggx.color.RgbaColor;
import vectorx.svg.SvgSerializer;
import aggx.color.SpanGradient.SpreadMethod;
import aggx.svg.gradients.SVGGradient;

import types.Data;

class SvgGradientSerializer
{
    private static var isRadialGradient: Int = 1;
    private static var isPad: Int = 1 << 1;
    private static var isReflect: Int = 1 << 2;
    private static var isRepeat: Int = 1 << 3;
    private static var isUserSpace: Int = 1 << 4;

    public static function writeSvgStop(data: SvgDataWrapper, value: SVGStop): Void
    {
        SvgSerializer.writeRgbaColor(data, value.color);
        data.writeFloat32(value.offset);
    }

    public static function readSvgStop(data: SvgDataWrapper, value: SVGStop): Void
    {
        if (value.color == null)
        {
            value.color = new RgbaColor();
        }

        SvgSerializer.readRgbaColor(data, value.color);
        value.offset = data.readFloat32();
    }

    public static function writeGradient(data: SvgDataWrapper, value: SVGGradient): Void
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

        //trace('offset: ${data.offset} id: ${value.id}');
        SvgSerializer.writeString(data, value.id);

        //trace('offset: ${data.offset} link: ${value.link}');
        SvgSerializer.writeString(data, value.link);

        //trace('offset: ${data.offset} stops: ${value.stops}');
        data.writeUInt16(value.stops.length);

        for (i in value.stops)
        {
            writeSvgStop(data, i);
        }

        //trace('offset: ${data.offset} stops: ${value.transform}');
        SvgSerializer.writeAffineTransformer(data, value.transform);

        if (value.type == GradientType.Radial)
        {
            //trace('focal ${value.focalGradientParameters}');
            for (i in value.focalGradientParameters)
            {
                data.writeFloat32(i.value);
            }
        }
        else if (value.type == GradientType.Linear)
        {
            //trace('linear ${value.gradientVector}');
            for (i in value.gradientVector)
            {
                data.writeFloat32(i.value);
            }
        }
    }

    public static function readGradient(data: SvgDataWrapper, value: SVGGradient)
    {
        //trace('readGradient()');
        var flags: Int = data.readUInt8();
        //trace('offset: ${data.offset} flags: ${flags}');

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
        value.id = SvgSerializer.readString(data);
        //trace(value.id);
        //trace('offset: ${data.offset} link:');
        value.link = SvgSerializer.readString(data);
        //trace(value.link);

        //trace('offset: ${data.offset} stops:');
        var stops: Int = data.readUInt16();
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
        SvgSerializer.readAffineTransformer(data, value.transform);
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
            }

            //trace('linear ${value.gradientVector}');
        }

        value.calculateColorArray(value.stops);
    }
}
