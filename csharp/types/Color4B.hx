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

import types.Data;
import types.DataType;

class Color4B
{
    public var data(default, default): Data;
    public var dataOffset: Int;

    public function new(_data: Data = null, _dataOffset: Int = 0): Void
    {
        if (_data == null)
        {
            data = new Data(4);
        }
        else
        {
            data = _data;
        }

        dataOffset = _dataOffset;
    }

    public var r(get, set): Int;

    public function get_r(): Int
    {
        data.offset = dataOffset + 0;
        return data.readUInt8();
    }

    public function set_r(r: Int): Int
    {
        data.offset = dataOffset + 0;
        data.writeUInt8(r);
        return r;
    }

    public var g(get, set): Int;

    public function get_g(): Int
    {
        data.offset = dataOffset + 1;
        return data.readUInt8();
    }

    public function set_g(g: Int): Int
    {
        data.offset = dataOffset + 1;
        data.writeUInt8(g);
        return g;
    }

    public var b(get, set): Int;

    public function get_b(): Int
    {
        data.offset = dataOffset + 2;
        return data.readUInt8();
    }

    public function set_b(b: Int): Int
    {
        data.offset = dataOffset + 2;
        data.writeUInt8(b);
        return b;
    }

    public var a(get, set): Int;

    public function get_a(): Int
    {
        data.offset = dataOffset + 3;
        return data.readUInt8();
    }

    public function set_a(a: Int): Int
    {
        data.offset = dataOffset + 3;
        data.writeUInt8(a);
        return a;
    }

/// Helper Method

    public function setRGBA(_r: Int, _g: Int, _b: Int, _a: Int)
    {
        r = _r;
        g = _g;
        b = _b;
        a = _a;
    }

    public function toString(): String
    {
        var output = "";
        output += "[";

        data.offset = dataOffset;
        output += data.readUInt8();

        for (i in 1...4)
        {
            output += ", ";
            data.offset += 1;
            output += data.readUInt8();
        }

        output += "]";
        return output;
    }
}
