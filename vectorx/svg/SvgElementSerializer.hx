package vectorx.svg;

import lib.ha.aggx.color.RgbaColor;
import lib.ha.svg.SVGElement;
import types.Data;
class SvgElementSerializer
{
    private var flagFill: Int = 1  << 0;
    private var flagFillOpacity: Int = 1 << 1;
    private var flagStroke: Int = 1 << 2;
    private var flagEvenOdd: Int = 1 << 3;

    public static function writeSVGElement(data: Data, element: SVGElement)
    {
        var flags: Int = 0;

        if (element.fill_flag)
        {
            flags |= flagFill;

            if (element.fill_opacity)
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

        data.writeInt8(flags);
        data.offset += 1;

        data.writeInt32(element.index);
        data.offset += 4;

        if (element.fill_flag)
        {
            SvgSerializer.writeRgbaColor(data, element.fill_color);
            if (element.fill_opacity != null)
            {
                data.writeFloat32(element.fill_opacity);
                data.offset += 4;
            }
        }
    }

    public static function readSVGElement(data: Data, element: SVGElement)
    {
        var flags: Int = 0;
        flags = data.readUInt8();
        data.offset += 1;

        element.index = data.readInt32();
        data.offset += 4;

        if (flags & flagFill != 0)
        {
            element.fill_flag = true;
            if (element.fill_color == null)
            {
                element.fill_color = new RgbaColor();
                SvgSerializer.readRgbaColor(element.fill_color);
                if (flags & flagFillOpacity != 0)
                {
                    element.fill_opacity = data.readFloat32();
                    data.offset += 4;
                }
            }
            else
            {
                element.fill_opacity = null;
            }
        }
    }

}
