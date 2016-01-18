/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package types;

import types.DataType;
//System.Collections.Generic
import cs.system.io.MemoryStream;
import cs.system.io.BinaryReader;
import cs.system.io.BinaryWriter;
import cs.system.io.SeekOrigin;

class Data
{
    inline static public var SIZE_OF_INT8: Int = 1;
    inline static public var SIZE_OF_UINT8: Int = 1;
    inline static public var SIZE_OF_INT16: Int = 2;
    inline static public var SIZE_OF_UINT16: Int = 2;
    inline static public var SIZE_OF_INT32: Int = 4;
    inline static public var SIZE_OF_UINT32: Int = 4;
    inline static public var SIZE_OF_FLOAT32: Int = 4;
    inline static public var SIZE_OF_FLOAT64: Int = 8;

    var memory: MemoryStream;
    var reader: BinaryReader;
    var writer: BinaryWriter;

    public function new(sizeInBytes: Int): Void /// if 0, empty data, does not create the underlying memory. Can be set externally.
    {
        allocedLength = sizeInBytes;
        memory = new MemoryStream(sizeInBytes);
        reader = new BinaryReader(memory);
        writer = new BinaryWriter(memory);
    }

    public function writeData(data: Data): Void
    {
        data.memory.Seek(0, SeekOrigin.Begin);
        memory.Seek(0, SeekOrigin.Begin);
        data.memory.WriteTo(memory);
    }

// Int write and read functions

    public function writeInt(value: Int, targetDataType: DataType): Void
    {
        switch(targetDataType)
        {
            case DataType.DataTypeInt8: writeInt8(value);
            case DataType.DataTypeUInt8: writeUInt8(value);
            case DataType.DataTypeInt16: writeInt16(value);
            case DataType.DataTypeUInt16: writeUInt16(value);
            case DataType.DataTypeInt32: writeInt32(value);
            case DataType.DataTypeUInt32: writeUInt32(value);
            case DataType.DataTypeFloat32: writeFloat32(value);
            case DataType.DataTypeFloat64: writeFloat64(value);
        }
    }

    public function writeIntArray(array: Array<Int>, dataType: DataType): Void
    {

    }

    private inline function seek(): Void
    {
        memory.Seek(offset, SeekOrigin.Begin);
    }
    public function writeInt8(value: Int): Void
    {
        seek();
        var tmp: cs.types.Int8 = (value);
        writer.Write(tmp);
    }

    public function writeUInt8(value: Int): Void
    {

    }

    public function writeInt16(value: Int): Void
    {

    }

    public function writeUInt16(value: Int): Void
    {

    }

    public function writeInt32(value: Int): Void
    {

    }

    public function writeUInt32(value: Int): Void
    {

    }

    public function readInt(targetDataType: DataType): Int
    {
        switch(targetDataType)
        {
            case DataType.DataTypeInt8: return readInt8();
            case DataType.DataTypeUInt8: return readUInt8();
            case DataType.DataTypeInt16: return readInt16();
            case DataType.DataTypeUInt16: return readUInt16();
            case DataType.DataTypeInt32: return readInt32();
            case DataType.DataTypeUInt32: return readUInt32();
            case DataType.DataTypeFloat32: return Std.int(readFloat32());
            case DataType.DataTypeFloat64: return Std.int(readFloat64());
        }
    }

    public function readIntArray(count: Int, dataType: DataType): Array<Int>
    {
        return [];
    }

    public function readInt8(): Int
    {
        return 0;
    }

    public function readUInt8(): Int
    {
        return 0;
    }

    public function readInt16(): Int
    {
        return 0;
    }

    public function readUInt16(): Int
    {
        return 0;
    }

    public function readInt32(): Int
    {
        return 0;
    }

    public function readUInt32(): Int
    {
        return 0;
    }

// Float write and read functions

    public function writeFloat(value: Float, targetDataType: DataType): Void
    {

    }

    public function writeFloatArray(array: Array<Float>, dataType: DataType): Void
    {

    }

    public function writeFloat32(value: Float): Void
    {

    }

    public function writeFloat64(value: Float): Void
    {

    }

    public function readFloat(targetDataType: DataType): Float
    {
        return 0;
    }

    public function readFloatArray(count: Int, dataType: DataType): Array<Float>
    {
        return [];
    }

    public function readFloat32(): Float
    {
        return 0;
    }

    public function readFloat64(): Float
    {
        return 0;
    }

    public function toString(?dataType: DataType): String
    {
        return "";
    }

/// offset view, all uses of data should start at offset and use up to offset length
    public var offset: Int;
    public var offsetLength: Int;
    public function resetOffset(): Void /// makes offset 0 and offsetLength be allocedLength
    {
        offset = 0;
        offsetLength = allocedLength;
    }

/// should not be used for reading and writing on the data
    public var allocedLength: Int;

/// if underlying pointer is set externally a new pointer will be created with a copy of that external pointer's memory.
    public function resize(newSize: Int): Void
    {
        memory.SetLength(newSize);
        allocedLength = newSize;
    }

/// makes the part pointed by offset and offset length become the full length of the data
/// by resizing the data fit exactly that.
    public function trim(): Void
    {

    }
}
