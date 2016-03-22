package vectorx.svg;

import aggx.svg.SVGData;
import aggx.vectorial.VectorPath;
import types.Data;

class SvgVectorPathSerializer
{
    public static function writeVectorPath(data: SvgDataWrapper, value: VectorPath): Void
    {
        value.save(data.data);
    }

    public static function readVectorData(data: SvgDataWrapper, value: VectorPath): Void
    {
        value.load(data.data);
    }
}