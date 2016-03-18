package vectorx.font;

import game_engine.systems.VectorTextSystem.RenderedNode;
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

    public static function initialise(renderingStack: RenderingStack, width: Int, height: Int, stride: Int): RenderingStack
    {
        if (renderingStack == null)
        {
            renderingStack = new RenderingStack(width, height, stride);
        }
        else
        {
            renderingStack.reconfigure(width, height, stride);
        }

        return renderingStack;
    }
}