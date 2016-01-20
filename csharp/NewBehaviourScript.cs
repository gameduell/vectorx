using UnityEngine;
using System.Collections;
using types;

public class NewBehaviourScript : MonoBehaviour {

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
		//data.writeFloat32 (1.1);
		float tmp = (float)1.1;
		data.writer.Write(value);
		data.dump ();
		data.memory.Seek (0, System.IO.SeekOrigin.Begin);
		string str = "";
		for (int i = 0; i < 4; i++)
		{
			str  += data.reader.ReadByte().ToString("X") + " ";
		}
		System.Console.Write (str);
	}
	void Start () 
	{
		UnitySystemConsoleRedirector.Redirect();
		System.Console.WriteLine ("Start () ");
		//TestFloat ();
		TestData();

		DataTest.testAll ();
		var svgData = new lib.ha.svg.SVGData ();
		var colorStorage = new vectorx.ColorStorage (512, 512, null);
		var context = new vectorx.svg.SvgContext ();
		var transform = lib.ha.core.geometry.AffineTransformer.translator(0, 0);
		context.renderVectorBinToColorStorage (svgData, colorStorage, transform);

		var arr = new System.Collections.Generic.List<System.Byte>();
		var stream = new System.IO.MemoryStream (512);

		var reader = new System.IO.BinaryReader (stream);
		var writer = new System.IO.BinaryWriter (stream);

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
