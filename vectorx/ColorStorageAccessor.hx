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
        //TODO debug
        if (x % 2 == 0)
        {
            output.setRGBA(255, 0, 0, 255);
        }
        else
        {
            output.setRGBA(0, 0, 255, 255);
        }
        output.setRGBA(128, 128, 128, 255);
        //return;

        var addr: UInt = addr(x, y);
        storage.data.offset = addr;

        //var value = storage.data.readUInt32();
        var value = 0xff808080;

        output.b = value & 0xFF;
        value = value >> 8;

        output.g = value & 0xFF;
        value = value >> 8;

        output.r = value & 0xFF;
        value = value >> 8;

        output.a = value & 0xFF;

        trace('output: $output');
    }

    public function setPixel(x: UInt, y: UInt, color: Color4B): Void
    {
        var addr: Int = addr(x, y);
        storage.data.offset = addr;
        storage.data.writeUInt32(color.a << 24 | color.r << 16 | color.g << 8 | color.b);
        //storage.data.writeUInt32(255 << 24 | 128 << 16 | 128 << 8 | 128);
        //storage.data.writeUInt32(0xff808080);
        //storage.data.writeUInt32(0xffffffff);
    }

    private inline function addr(x: UInt, y: UInt): Int
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