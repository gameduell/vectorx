package vectorx.svg;

import aggx.core.StreamInterface;
import aggx.core.geometry.AffineTransformer;
import aggx.svg.SVGStringParsers;
import aggx.color.RgbaColor;
import aggx.svg.SVGElement;

import types.Data;

class SvgElementSerializer
{
    private static var flagFill: Int = 1  << 0;
    private static var flagFillOpacity: Int = 1 << 1;
    private static var flagStroke: Int = 1 << 2;
    private static var flagEvenOdd: Int = 1 << 3;

    public static function writeSVGElement(data: StreamInterface, element: SVGElement)
    {
        var flags: Int = 0;

        if (element.fill_flag)
        {
            flags |= flagFill;

            if (element.fill_opacity != null)
            {
                flags |= flagFillOpacity;
            }
        }

        if (element.stroke_flag)
        {
            flags |= flagStroke;
        }

        if (element.even_odd_flag)
        {
            flags |= flagEvenOdd;
        }

        data.writeUInt8(flags);

        data.writeUInt32(element.index);

        //intentionally left for debugging
        //trace('off: ${data.offset} flags: $flags, index: ${element.index}');

        SvgSerializer.writeAffineTransformer(data, element.transform);
        SvgSerializer.writeString(data, element.gradientId);

        //intentionally left for debugging
        //trace('off: ${data.offset} grad: ${element.gradientId}}');

        if (element.fill_flag)
        {
            SvgSerializer.writeRgbaColor(data, element.fill_color);

            //intentionally left for debugging
            //trace('off: ${data.offset} fill_color: ${element.fill_color}}');

            if (element.fill_opacity != null)
            {
                data.writeFloat32(element.fill_opacity);
            }
        }

        if (element.stroke_flag)
        {
            SvgSerializer.writeRgbaColor(data, element.stroke_color);
            data.writeFloat32(element.stroke_width);
        }

        data.writeUInt8(element.line_join);
        data.writeUInt8(element.line_cap);
        data.writeFloat32(element.miter_limit);
    }

    public static function readSVGElement(data: StreamInterface, element: SVGElement)
    {
        var flags: Int = 0;
        flags = data.readUInt8();

        element.index = data.readUInt32();

        //intentionally left for debugging
        //trace('off: ${data.offset} flags: $flags, index: ${element.index}');

        if (flags & flagEvenOdd != 0)
        {
            element.even_odd_flag = true;
        }
        else
        {
            element.even_odd_flag = false;
        }

        if (element.transform == null)
        {
            element.transform = new AffineTransformer();
        }

        SvgSerializer.readAffineTransformer(data, element.transform);
        element.gradientId = SvgSerializer.readString(data);

        if (flags & flagFill != 0)
        {
            element.fill_flag = true;

            if (element.fill_color == null)
            {
                element.fill_color = new RgbaColor();
            }

            SvgSerializer.readRgbaColor(data, element.fill_color);

            if (flags & flagFillOpacity != 0)
            {
                element.fill_opacity = data.readFloat32();
            }

            else
            {
                element.fill_opacity = null;
            }
        }
        else
        {
            element.fill_flag = false;
        }

        if (flags & flagStroke != 0)
        {
            element.stroke_flag = true;
            if (element.stroke_color == null)
            {
                element.stroke_color = new RgbaColor();
            }

            SvgSerializer.readRgbaColor(data, element.stroke_color);
            element.stroke_width = data.readFloat32();
        }
        else
        {
            element.stroke_flag = false;
        }

        element.line_join = data.readUInt8();
        element.line_cap = data.readUInt8();
        element.miter_limit = data.readFloat32();
    }

}
