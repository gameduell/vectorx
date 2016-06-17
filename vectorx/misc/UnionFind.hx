package vectorx.misc;

import haxe.ds.Vector;

class UnionFind
{
    private var data: Vector<Int>;
    private var sizes: Vector<Int>;

    public function new (size: Int)
    {
        data = new Vector<Int>(size);
        sizes = new Vector<Int>(size);

        for (i in 0 ... data.length)
        {
            data[i] = i;
            sizes[i] = 1;
        }
    }

    private function root(id: Int): Int
    {
        var i = id;
        while (i != data[i])
        {
            i = data[i];
        }

        var root = i;
        while (i != data[i])
        {
            var prev = i;
            i = data[i];
            data[prev] = root;
        }

        trace('id: $id root: $root');
        return root;
    }

    public function find(a: Int, b: Int): Bool
    {
        return root(a) == root(b);
    }

    public function unite(a: Int, b: Int): Void
    {

        var rootA = root(a);
        var rootB = root(b);
        trace('ra: $rootA rb: $rootB');
        var sizeA = sizes[rootA];
        var sizeB = sizes[rootB];

        if (sizeB > sizeA)
        {
            data[rootB] = rootA;
            sizes[rootA] += sizes[rootB];
        }
        else
        {
            data[rootA] = rootB;
            sizes[rootB] += sizes[rootA];
        }
    }
}