import lib.ha.aggx.renderer.SolidScanlineRenderer;
import lib.ha.aggx.renderer.ClippingRenderer;
import lib.ha.aggx.renderer.PixelFormatRenderer;
import lib.ha.aggx.RenderingBuffer;

class RenderingStack
{
    private var renderingBuffer: RenderingBuffer;
    private var pixelFormatRenderer: PixelFormatRenderer;
    private var clippingRenderer: ClippingRenderer;
    public var scanlineRenderer(default, null): SolidScanlineRenderer;

    public function new(width: Int, height: Int, stride: Int)
    {
        renderingBuffer = new RenderingBuffer(width, height, stride);
        pixelFormatRenderer = new PixelFormatRenderer(renderingBuffer);
        clippingRenderer = new ClippingRenderer(pixelFormatRenderer);
        scanlineRenderer = new SolidScanlineRenderer(clippingRenderer);
    }

    public function reconfigure(width: Int, height: Int, stride: Int)
    {
        renderingBuffer.attach(width, height, stride);
    }
}