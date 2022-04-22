Shader "Custom/TerrainOverlay" 
{
	Properties
	{
		_MainTex1("Overlay 1", 2D) = "black" {}
		_MainTex2("Overlay 2", 2D) = "black" {}
		_MainTex3("Overlay 3", 2D) = "black" {}
		_MainTex4("Overlay 4", 2D) = "black" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		Lighting Off
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert decal:blend vertex:vert exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#include "CustomTerrainShader.cginc"

		sampler2D _MainTex1;
		sampler2D _MainTex2;
		sampler2D _MainTex3;
		sampler2D _MainTex4;
		int _MainTex1Custom;
		int _MainTex2Custom;
		int _MainTex3Custom;
		int _MainTex4Custom;
		sampler2D _BumpMap;

		struct Input 
		{
			float2 uv_MainTex1 : TEXCOORD0;
			float2 uv_MainTex2 : TEXCOORD1;
			float2 uv_MainTex3 : TEXCOORD2;
			float2 uv_MainTex4: TEXCOORD3;
			float2 uv_BumpMap : TEXCOORD4;
		};

		void vert(inout appdata_full v)
        {
            v.tangent = float4(1.0, 0.0, 0.0, -1.0);
            v.normal = float3(0.0, 1.0, 0.0);
        }

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c1 = tex2D(_MainTex1, IN.uv_MainTex1);
			fixed4 c2 = tex2D(_MainTex2, IN.uv_MainTex2);
			fixed4 c3 = tex2D(_MainTex3, IN.uv_MainTex3);
			fixed4 c4 = tex2D(_MainTex4, IN.uv_MainTex4);

			if (_MainTex1Custom == 1) c1 = CustomTerrainFrag(c1);
			if (_MainTex2Custom == 2) c2 = CustomTerrainFrag(c2);
			if (_MainTex3Custom == 3) c3 = CustomTerrainFrag(c3);
			if (_MainTex4Custom == 4) c4 = CustomTerrainFrag(c4);
			
			o.Albedo = lerp(o.Albedo, c1.rgb, c1.a);
			o.Albedo = lerp(o.Albedo, c2.rgb, c2.a);
			o.Albedo = lerp(o.Albedo, c3.rgb, c3.a);
			o.Albedo = lerp(o.Albedo, c4.rgb, c4.a);
			o.Alpha = c1.a + c2.a + c3.a + c4.a;
			
			fixed3 n = tex2D(_BumpMap, IN.uv_BumpMap).rgb;
			fixed4 normalFixed = float4(n.g, n.g, n.g, n.r);
			o.Normal = UnpackNormal(normalFixed);
		}
		ENDCG
	}
}