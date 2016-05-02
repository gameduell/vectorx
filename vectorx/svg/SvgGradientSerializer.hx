package vectorx.svg;

import aggx.core.StreamInterface;
import aggx.core.memory.Ref;
import aggx.core.geometry.AffineTransformer;
import aggx.color.RgbaColor;
import vectorx.svg.SvgSerializer;
import aggx.color.SpanGradient.SpreadMethod;
import aggx.svg.gradients.SVGGradient;

class SvgGradientSerializer
{
    private static var isRadialGradient: Int = 1;
    private static var isPad: Int = 1 << 1;
    private static var isReflect: Int = 1 << 2;
    private static var isRepeat: Int = 1 << 3;
    private static var isUserSpace: Int = 1 << 4;

    public static function writeSvgStop(data: StreamInterface, value: SVGStop): Void
    {
        SvgSerializer.writeRgbaColor(data, value.color);
        data.writeFloat32(value.offset);
    }

    public static function readSvgStop(data: StreamInterface, value: SVGStop): Void
    {
        if (value.color == null)
        {
            value.color = new RgbaColor();
        }

        SvgSerializer.readRgbaColor(data, value.color);
        value.offset = data.readFloat32();
    }

    public static function writeGradient(data: StreamInterface, value: SVGGradient): Void
    {
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

        data.writeUInt8(flags);
        SvgSerializer.writeString(data, value.id);
        SvgSerializer.writeString(data, value.link);

        data.writeUInt16(value.stops.length);
        for (i in value.stops)
        {
            writeSvgStop(data, i);
        }

        SvgSerializer.writeAffineTransformer(data, value.transform);

        if (value.type == GradientType.Radial)
        {
            for (i in value.focalGradientParameters)
            {
                data.writeFloat32(i.value);
            }
        }
        else if (value.type == GradientType.Linear)
        {
            for (i in value.gradientVector)
            {
                data.writeFloat32(i.value);
            }
        }
    }

    public static function readGradient(data: StreamInterface, value: SVGGradient)
    {
        var flags: Int = data.readUInt8();

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

        value.id = SvgSerializer.readString(data);
        value.link = SvgSerializer.readString(data);

        var stops: Int = data.readUInt16();
        for (i in 0 ... stops)
        {
            var stop = new SVGStop();
            readSvgStop(data, stop);
            value.stops.push(stop);
        }

        if (value.transform == null)
        {
            value.transform = new AffineTransformer();
        }
        SvgSerializer.readAffineTransformer(data, value.transform);

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
        }

        value.calculateColorArray(value.stops);
    }
}
