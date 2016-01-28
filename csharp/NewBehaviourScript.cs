using UnityEngine;
using System.Collections;
using types;

public class NewBehaviourScript : MonoBehaviour 
{
	public TextAsset svgXml;

	void Awake()
	{
		
	}

	void TestFloat()
	{
		float f = 1.1f;
		var stream = new System.IO.MemoryStream (16);
		var reader = new System.IO.BinaryReader (stream);
		var writer = new System.IO.BinaryWriter (stream);
		writer.Write (f);
		stream.Seek (0, System.IO.SeekOrigin.Begin);
		float f2 = reader.ReadSingle ();

		stream.Seek (0, System.IO.SeekOrigin.Begin);
		string str = "";
		for (int i = 0; i < 4; i++)
		{
			str  += reader.ReadByte().ToString("X") + " ";
		}

		System.Console.Write ("");
	}

	/*public virtual void writeFloat32(double @value) 
	{

		seek();
		float tmp = (float)value;
		writer.Write(value);

	}*/

	void TestData()
	{
		var data = new types.Data (4);
		data.writeFloat32 (1.1);
		data.memory.Seek (0, System.IO.SeekOrigin.Begin);
		string str = "";
		for (int i = 0; i < 4; i++)
		{
			str  += data.reader.ReadByte().ToString("X") + " ";
		}
		System.Console.Write (str);
	}

	Texture2D createTexture(vectorx.ColorStorage storage)
	{
		var texture = new Texture2D(storage.width, storage.height, TextureFormat.RGBA32, false);
		storage.data.memory.Seek (0, System.IO.SeekOrigin.Begin);
		var bytes = storage.data.reader.ReadBytes (storage.data.allocedLength);
		texture.LoadRawTextureData (bytes);
		texture.Apply ();
		return texture;
	}

	void TestColorStorage()
	{
		var colorStorage = new vectorx.ColorStorage (8, 8, null);
		//System.UInt32 value = 0xff0000ff;
		System.UInt32 value32 = 0xff0000ff;
		System.Byte value8 = 0xff;
		colorStorage.data.memory.Seek (0, System.IO.SeekOrigin.Begin);
		for (int i = 0; i < colorStorage.data.allocedLength/4; i++) 
		{
			//colorStorage.data.offset = i;
			//colorStorage.data.writeUInt8 (value8);
			colorStorage.data.writer.Write(value32);
		}

		colorStorage.data.dump ();

		var texture = createTexture (colorStorage);
		GetComponent<Renderer> ().material.mainTexture = texture;
		System.Console.Write ("");
	}

	void TestPixelFormatRenderer()
	{
		Debug.Log ("TestPixelFormatRenderer");
		var colorStorage = new vectorx.ColorStorage (8, 8, null);
		Debug.Log ("allocated: " + colorStorage.data.allocedLength);
		lib.ha.core.memory.MemoryAccess.domainMemory = colorStorage.data;

		for (uint i = 0; i < colorStorage.data.allocedLength; i+=4) 
		{
			Debug.Log (i / 4);
			lib.ha.aggx.renderer.PixelFormatRenderer.copyOrBlendPix2 (i, 255, 0, 0, 255);
			colorStorage.data.dump ();
		}

		var texture = createTexture (colorStorage);
		GetComponent<Renderer> ().material.mainTexture = texture;
		System.Console.Write ("");
	}

	void TestSvg()
	{
		var xml = Xml.parse (svgXml.text);
		var svg = vectorx.svg.SvgContext.parseSvg (xml);


		//var svgBinData = new Data (1024);
		//vectorx.svg.SvgContext.convertSvgToVectorBin (xml, svgBinData);
		//svgBinData.offset = 0;
		//var svg = new lib.ha.svg.SVGData();
		//vectorx.svg.SvgContext.deserializeVectorBin (svgBinData, svg);

		var colorStorage = new vectorx.ColorStorage (512, 512, null);
		System.Byte value8 = 0xff;
		colorStorage.data.memory.Seek (0, System.IO.SeekOrigin.Begin);
		for (int i = 0; i < colorStorage.data.allocedLength; i++) 
		{
			//colorStorage.data.writer.Write(value8);
		}

		var context = new vectorx.svg.SvgContext ();
		var transform = lib.ha.core.geometry.AffineTransformer.translator(0, 0);
		context.renderVectorBinToColorStorage (svg, colorStorage, transform);

		//colorStorage.data.dump ();

		var texture = createTexture (colorStorage);
		GetComponent<Renderer> ().material.mainTexture = texture;
		System.Console.Write ("");
	}

	void Start () 
	{
		UnitySystemConsoleRedirector.Redirect();
		System.Console.WriteLine ("Start () ");
		//TestFloat ();
		//TestData();
		TestSvg();
		//TestColorStorage();
		//TestPixelFormatRenderer();

		//DataTest.testAll ();
	}
	
	// Update is called once per frame
	void Update () 
	{
	
	}
}
