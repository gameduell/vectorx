package vectorx.svg;

import lib.ha.core.geometry.AffineTransformer;
import lib.ha.svg.SVGStringParsers;
import lib.ha.aggx.color.RgbaColor;
import lib.ha.svg.SVGElement;
import types.Data;
class SvgElementSerializer
{
    private static var flagFill: Int = 1  << 0;
    private static var flagFillOpacity: Int = 1 << 1;
    private static var flagStroke: Int = 1 << 2;
    private static var flagEvenOdd: Int = 1 << 3;

    public static function writeSVGElement(data: Data, element: SVGElement)
    {
        //trace('writeSVGElement');
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
        data.offset += 1;

        data.writeInt32(element.index);
        data.offset += 4;

        //trace('off: ${data.offset} flags: $flags, index: ${element.index}');

        SvgSerializer.writeAffineTransformer(data, element.transform);
        SvgSerializer.writeString(data, element.gradientId);

        //trace('off: ${data.offset} grad: ${element.gradientId}}');

        if (element.fill_flag)
        {
            SvgSerializer.writeRgbaColor(data, element.fill_color);

            //trace('off: ${data.offset} fill_color: ${element.fill_color}}');

            if (element.fill_opacity != null)
            {
                SvgSerializer.writeFloat(data, element.fill_opacity);
            }
        }

        if (element.stroke_flag)
        {
            SvgSerializer.writeRgbaColor(data, element.stroke_color);
            SvgSerializer.writeFloat(data, element.stroke_width);
        }

        data.writeUInt8(element.line_join);
        data.offset++;

        data.writeUInt8(element.line_cap);
        data.offset++;

        SvgSerializer.writeFloat(data, element.miter_limit);
    }

    public static function readSVGElement(data: Data, element: SVGElement)
    {
        //trace('readSVGElement');
        var flags: Int = 0;
        flags = data.readUInt8();
        data.offset += 1;

        element.index = data.readUInt32();
        data.offset += 4;

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

        //trace('off: ${data.offset} grad: ${element.gradientId}');

        if (flags & flagFill != 0)
        {
            trace('fill');
            element.fill_flag = true;

            if (element.fill_color == null)
            {
                element.fill_color = new RgbaColor();
            }

            SvgSerializer.readRgbaColor(data, element.fill_color);

            //trace('off: ${data.offset} fill_color: ${element.fill_color}');

            if (flags & flagFillOpacity != 0)
            {
                element.fill_opacity = SvgSerializer.readFloat(data);
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
            element.stroke_width = SvgSerializer.readFloat(data);
        }
        else
        {
            element.stroke_flag = false;
        }

        element.line_join = data.readUInt8();
        data.offset++;

        element.line_cap = data.readUInt8();
        data.offset++;

        element.miter_limit = SvgSerializer.readFloat(data);
    }

}
