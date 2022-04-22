// Simplified Diffuse shader. Differences from regular Diffuse one:
// - no Main Color
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "Custom/FastDiffuse" 
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		CGPROGRAM
		#pragma surface surf Lambert exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv

		uniform sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
			float4 Color : COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * IN.Color.rgb;
			o.Alpha = c.a * IN.Color.a;
		}
		ENDCG
	}
}
