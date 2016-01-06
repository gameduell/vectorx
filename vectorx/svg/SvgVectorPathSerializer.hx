package vectorx.svg;

import lib.ha.aggx.vectorial.VectorPath;
import types.Data;

class SvgVectorPathSerializer
{
    public static function writeVectorPath(data: Data, value: VectorPath): Void
    {
        value.save(data);
    }

    public static function readVectorData(data: Data, value: VectorPath): Void
    {
        value.load(data);
    }
}