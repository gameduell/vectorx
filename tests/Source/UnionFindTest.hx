import vectorx.misc.UnionFind;

@:access(vectorx.misc.UnionFind)
class UnionFindTest extends unittest.TestCase
{
    public function testSimple(): Void
    {
        var uf = new UnionFind(10);
        uf.unite(1, 2);
        uf.unite(2, 3);

        uf.unite(5, 6);
        uf.unite(6, 7);

        assertTrue(uf.find(1, 3));
        assertTrue(!uf.find(1, 7));
    }

    public function testTreeBalance(): Void
    {
        var uf = new UnionFind(10);

        uf.unite(1, 2);
        uf.unite(1, 3);

        var biggerRoot = uf.root(1);

        uf.unite(3, 4);

        assertTrue(uf.root(4) == biggerRoot);
    }
}