Shader "Custom/Cube"
{
	Properties
	{
		  _MainTex("Lookup Texture", 2D) = "white" {}
	}

	SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert noshadow exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv

		struct Input
		{
			fixed3 normal;
			fixed3 cubeColour;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;

		void vert(inout appdata_full v, out Input o) 
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			v.normal = v.tangent.xyz;
			o.cubeColour = tex2Dlod(_MainTex, float4(v.tangent.w * _MainTex_TexelSize.x, 0.0, 1.0, 1.0));
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = IN.cubeColour;
		}
		ENDCG
	}

	Fallback off
}