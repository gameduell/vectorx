#!/usr/bin/env bash

#remove invalid attribute
find . -name "*.cs" -print0 | xargs -0 sed -i '' \
 -e 's/\[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never)]/ /g'

#remove invalid type conversion
find . -name "StyledStringContext.cs" -print0 | xargs -0 sed -i '' \
 -e '/global::Array _/b' -e 's/(global::Array)/ /g'

mcs /noconfig /debug:full /debug+ /optimize- /out:bin/MainCs-Debug.dll src/lib/ha/aggx/rasterizer/ISpanIterator.cs \
src/lib/ha/svg/SVGPathParser.cs src/lib/ha/aggx/typography/TypefaceCache.cs src/lib/ha/aggx/renderer/BlenderBase.cs \
src/types/VerticalAlignment.cs src/cs/Boot.cs src/lib/ha/aggx/vectorial/generators/VcgenStroke.cs src/Std.cs \
src/lib/ha/rfpx/data/GlyphRecord.cs src/Xml.cs src/vectorx/svg/SvgContext.cs src/lib/ha/aggx/vectorial/BezierArcSvg.cs \
src/lib/ha/svg/SVGUseElement.cs src/haxe/Log.cs src/lib/ha/aggx/vectorial/VertexBlockStorage.cs \
src/lib/ha/aggx/rasterizer/Scanline.cs src/lib/ha/core/utils/ArrayUtil.cs src/lib/ha/core/geometry/ITransformer.cs \
src/lib/ha/aggx/renderer/IRenderer.cs src/lib/ha/svg/SVGColors.cs src/lib/ha/aggx/color/RgbaColor.cs src/Array.cs \
src/lib/ha/aggx/rasterizer/PixelCell.cs src/lib/ha/core/utils/Bits.cs src/cs/internal/Function.cs \
src/lib/ha/rfpx/data/NameRecord.cs src/vectorx/svg/SvgElementSerializer.cs src/lib/ha/aggx/color/GradientRadialFocus.cs \
src/types/DataTest.cs src/vectorx/font/StyledStringContext.cs src/types/RectF.cs src/lib/ha/rfpx/ContourSegment.cs \
src/lib/ha/core/geometry/Coord.cs src/lib/ha/core/memory/MemoryWriter.cs src/lib/ha/core/memory/MemoryBlock.cs \
src/vectorx/ColorStorage.cs src/lib/ha/rfpx/data/LocaTable.cs src/lib/ha/rfpx/data/Panose.cs \
src/lib/ha/aggx/renderer/ScanlineRenderer.cs src/vectorx/font/FontAliasesStorage.cs src/lib/ha/core/geometry/RectBox.cs \
src/lib/ha/rfpx/data/CmapFormat4.cs src/haxe/format/JsonParser.cs src/lib/ha/aggx/vectorial/converters/ConvContour.cs \
src/lib/ha/rfpx/data/TableTags.cs src/lib/ha/rfpx/Glyph.cs src/lib/ha/core/memory/Ref.cs \
src/lib/ha/aggx/rasterizer/ScanlineHitTest.cs src/lib/ha/aggx/vectorial/converters/ConvAdaptorVcgen.cs \
src/lib/ha/aggx/rasterizer/IGammaFunction.cs src/lib/ha/rfpx/data/CmapFormat0.cs src/vectorx/font/AttributedSpan.cs \
src/vectorx/font/FontAttachmentStorage.cs src/lib/ha/aggx/vectorial/InnerJoin.cs \
src/lib/ha/aggx/vectorial/generators/VcgenContour.cs src/haxe/io/Eof.cs src/lib/ha/rfpx/data/GlyphDescrSimple.cs \
src/lib/ha/rfpx/data/LongHorMetric.cs src/lib/ha/rfpx/TrueTypeCollection.cs src/lib/ha/core/utils/Debug.cs \
src/lib/ha/aggx/color/GammaLookupTable.cs src/lib/ha/core/memory/MemoryAccess.cs \
src/lib/ha/aggx/calculus/Dda2LineInterpolator.cs src/lib/ha/aggx/vectorial/converters/ConvDash.cs \
src/lib/ha/core/geometry/AffineTransformer.cs src/Type.cs src/lib/ha/aggx/rasterizer/ClippingScanlineRasterizer.cs \
src/lib/ha/core/geometry/RectBoxI.cs src/lib/ha/svg/XmlExtender.cs src/types/HorizontalAlignment.cs \
src/vectorx/font/FontAttachment.cs src/lib/ha/aggx/vectorial/converters/ConvTransform.cs \
src/vectorx/svg/SvgGradientSerializer.cs src/lib/ha/aggx/rasterizer/GammaPower.cs \
src/lib/ha/aggx/vectorial/QuadCurve.cs src/lib/ha/aggx/vectorial/generators/VcgenDash.cs \
src/lib/ha/aggx/RenderingBuffer.cs src/types/Color4F.cs src/lib/ha/core/memory/MemoryUtils.cs \
src/lib/ha/aggx/color/SpanInterpolatorLinear.cs src/lib/ha/aggx/color/GradientX.cs src/lib/ha/rfpx/data/Os2Table.cs \
src/lib/ha/rfpx/data/TableRecord.cs src/vectorx/font/StyledStringParser.cs src/lib/ha/aggx/color/RgbaColorF.cs \
src/lib/ha/aggx/vectorial/PathCommands.cs src/lib/ha/aggx/color/IGradientFunction.cs src/vectorx/font/FontContext.cs \
src/types/RectI.cs src/vectorx/font/TextLayout.cs src/vectorx/font/AttributedSpanStorage.cs src/StringTools.cs \
src/lib/ha/svg/SVGParser.cs src/types/Range.cs src/lib/ha/rfpx/data/PostTable.cs \
src/lib/ha/aggx/rasterizer/PixelCellRasterizer.cs src/Reflect.cs src/lib/ha/aggx/rasterizer/FillingRule.cs \
src/lib/ha/svg/SVGDataBuilder.cs src/vectorx/font/LayoutBehaviour.cs src/lib/ha/aggx/rasterizer/LiangBarskyClipper.cs \
src/lib/ha/core/utils/DataPointer.cs src/lib/ha/rfpx/data/HmtxTable.cs src/lib/ha/aggx/vectorial/LineCap.cs \
src/lib/ha/core/memory/MemoryReader.cs src/types/DataStringTools.cs src/lib/ha/aggx/renderer/PixelFormatRenderer.cs \
src/lib/ha/aggx/vectorial/VertexDistance.cs src/lib/ha/rfpx/data/GlyphRecordComp.cs \
src/lib/ha/aggx/renderer/InverseGammaApplier.cs src/haxe/Constraints.cs src/MainCs.cs src/haxe/ds/ObjectMap.cs \
src/lib/ha/rfpx/data/GlyphDescrComp.cs src/lib/ha/core/memory/RgbaReaderWriter.cs src/lib/ha/rfpx/GlyphPoint.cs \
src/vectorx/svg/SvgSerializer.cs src/haxe/ds/GenericStack.cs src/haxe/xml/Parser.cs \
src/types/Vector2.cs src/vectorx/svg/SvgVectorPathSerializer.cs src/lib/ha/aggx/vectorial/MathStroke.cs \
src/lib/ha/rfpx/data/CmapTable.cs src/haxe/ds/StringMap.cs src/lib/ha/rfpx/data/CmapFormat6.cs \
src/vectorx/font/FontShadow.cs src/lib/ha/core/memory/MemoryReaderEx.cs src/lib/ha/core/memory/MemoryManager.cs \
src/lib/ha/rfpx/SegmentIterator.cs src/lib/ha/aggx/renderer/SolidScanlineRenderer.cs \
src/lib/ha/aggx/typography/FontEngine.cs src/lib/ha/svg/SVGStringParsers.cs src/lib/ha/aggx/vectorial/NullMarkers.cs \
src/vectorx/font/TextLine.cs src/lib/ha/aggx/vectorial/PathUtils.cs src/lib/ha/svg/SVGData.cs \
src/lib/ha/aggx/color/SpanAllocator.cs src/vectorx/svg/SvgDataWrapper.cs src/lib/ha/rfpx/data/MaxpTable.cs \
src/lib/ha/rfpx/data/CmapFormat2.cs src/lib/ha/aggx/color/IColorFunction.cs src/lib/ha/svg/gradients/GradientManager.cs src/cs/internal/Iterator.cs src/lib/ha/aggx/vectorial/Ellipse.cs src/lib/ha/rfpx/data/EncodingRecord.cs src/lib/ha/aggx/vectorial/converters/ConvStroke.cs src/lib/ha/aggx/vectorial/CubicCurve.cs src/cs/internal/StringExt.cs src/cs/internal/Runtime.cs src/lib/ha/rfpx/data/GlyfTable.cs src/cs/Lib.cs src/lib/ha/aggx/color/ISpanAllocator.cs src/lib/ha/svg/SVGPathTokenizer.cs src/lib/ha/aggx/vectorial/CubicCurveFitterInc.cs src/lib/ha/svg/SVGPathBounds.cs src/lib/ha/aggx/rasterizer/SpanIterator.cs src/lib/ha/aggx/rasterizer/PixelCellDataExtensions.cs src/lib/ha/aggx/vectorial/VertexSequence.cs src/cs/internal/HxObject.cs src/types/DataType.cs src/cs/internal/Exceptions.cs src/lib/ha/aggx/vectorial/LineJoin.cs src/lib/ha/aggx/vectorial/IVertexSource.cs src/lib/ha/aggx/vectorial/QuadCurveFitterInc.cs src/vectorx/font/Font.cs src/Math.cs src/lib/ha/aggx/rasterizer/PolySubpixelScale.cs src/vectorx/font/AttributedRange.cs src/lib/ha/aggx/color/ISpanGenerator.cs src/haxe/lang/FieldLookup.cs src/lib/ha/aggx/color/SpanGradient.cs src/lib/ha/aggx/rasterizer/IRasterizer.cs src/lib/ha/rfpx/GlyphContour.cs src/lib/ha/rfpx/data/NameTable.cs src/vectorx/font/AttributedString.cs src/lib/ha/aggx/vectorial/CubicCurveFitterDiv.cs src/lib/ha/aggxtest/AATest.cs src/lib/ha/rfpx/data/OffsetTable.cs src/vectorx/font/FontCache.cs src/lib/ha/aggx/renderer/ClippingRenderer.cs src/lib/ha/aggx/typography/Typeface.cs src/lib/ha/core/math/Calc.cs src/lib/ha/svg/SVGRenderer.cs src/lib/ha/aggx/vectorial/QuadCurveFitterDiv.cs src/lib/ha/svg/gradients/SVGGradient.cs src/lib/ha/rfpx/data/TTCHeader.cs src/lib/ha/aggx/vectorial/PathFlags.cs src/lib/ha/rfpx/data/HheaTable.cs src/vectorx/font/StyledString.cs src/lib/ha/aggx/RowInfo.cs src/lib/ha/aggx/vectorial/VectorPath.cs src/lib/ha/aggx/vectorial/IDistanceProvider.cs src/lib/ha/aggx/rasterizer/Span.cs src/lib/ha/aggx/rasterizer/ScanlineRasterizer.cs src/lib/ha/aggx/renderer/DirectGammaApplier.cs src/lib/ha/svg/SVGElement.cs src/lib/ha/aggx/rasterizer/CoverScale.cs src/lib/ha/aggx/vectorial/converters/ConvCurve.cs src/lib/ha/aggx/vectorial/generators/ICurveGenerator.cs src/types/Data.cs src/lib/ha/aggx/color/ISpanInterpolator.cs src/haxe/ds/IntMap.cs src/lib/ha/rfpx/data/HeadTable.cs src/lib/ha/rfpx/data/LangTagRecord.cs src/lib/ha/rfpx/TrueTypeFont.cs src/haxe/CallStack.cs src/lib/ha/aggx/rasterizer/IScanline.cs src/lib/ha/aggx/vectorial/generators/IMarkerGenerator.cs src/StringBuf.cs \
/target:library \
/define:"DEBUG;TRACE" \
/platform:x86 \
/warn:4 \
/sdk:2.0