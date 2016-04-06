package vectorx;

import types.Color4B;
import vectorx.ColorStorage;

class ColorStorageAccessor
{
    public var width(default, null): Int;
    public var height(default, null): Int;

    private var storage: ColorStorage;
    private var stride: Int;
    public var transposed: Bool;


    public function new()
    {

    }

    public function transpose(): Void
    {
        transposed = !transposed;
        var oldWidth = width;
        width = height;
        height = oldWidth;
    }

    public function set(storage: ColorStorage)
    {
        this.storage = storage;
        if (storage != null)
        {
            stride = storage.width * ColorStorage.COMPONENTS;
        }

        width = storage.width;
        height = storage.height;

        transposed = false;
    }

    public function getPixel(x: UInt, y: UInt, output: Color4B): Void
    {
        var addr: UInt = addr(x, y);
        storage.data.offset = addr;

        var value = storage.data.readUInt32();

        output.b = value & 0xFF;
        value = value >> 8;

        output.g = value & 0xFF;
        value = value >> 8;

        output.r = value & 0xFF;
        value = value >> 8;

        output.a = value & 0xFF;
    }

    public function setPixel(x: UInt, y: UInt, color: Color4B): Void
    {
        var addr: Int = addr(x, y);
        storage.data.offset = addr;
        storage.data.writeUInt32(color.a << 24 | color.r << 16 | color.g << 8 | color.b);
    }

    private inline function addr(x: UInt, y: UInt): UInt
    {
        if (transposed)
        {
            return stride * x + y * ColorStorage.COMPONENTS;
        }
        else
        {
            return stride * y + x * ColorStorage.COMPONENTS;
        }
    }
}