package vectorx.svg;

import aggx.core.StreamInterface;
import aggx.svg.SVGData;
import aggx.vectorial.VectorPath;

class SvgVectorPathSerializer
{
    public static function writeVectorPath(data: StreamInterface, value: VectorPath): Void
    {
        value.save(data);
    }

    public static function readVectorData(data: StreamInterface, value: VectorPath): Void
    {
        value.load(data);
    }
}