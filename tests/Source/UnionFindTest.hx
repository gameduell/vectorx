import vectorx.misc.UnionFind;

@:access(vectorx.misc.UnionFind)
class UnionFindTest extends unittest.TestCase
{
    public function testUnion(): Void
    {
        var uf = new UnionFind(10);

        uf.unite(1, 2);
        trace(uf.data);
        uf.unite(3, 4);
        trace(uf.data);
        uf.unite(4, 5);
        trace(uf.data);
        uf.unite(1, 5);
        trace(uf.data);

        trace(uf.data);
        trace(uf.sizes);
        assertTrue(uf.sizes[uf.root(2)] == 4);
    }
}