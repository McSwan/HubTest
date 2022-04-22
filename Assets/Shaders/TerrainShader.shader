Shader "Custom/TerrainShader" 
{
	Properties
	{
		_ColourMap("ColourMap", 2D) = "black" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_MainTex1("BaseImagery", 2D) = "black" {}
		_ContourMap("ContourMap", 2D) = "black" {}
		_MainTex2("OverlayImagery", 2D) = "black" {}
		_MinRange("MinRange", Range(-1000000, 1000000)) = -1000000
		_MaxRange("MaxRange", Range(-1000000, 1000000)) = 1000000
	}
	SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" }

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#pragma multi_compile __ HEIGHTMAP_ACTIVE
		#pragma multi_compile __ CONTOURS_ACTIVE
		#include "CustomTerrainShader.cginc"

		sampler2D _MainTex1;
		sampler2D _MainTex2;
		int _MainTex1Custom;
		int _MainTex2Custom;
		sampler2D _BumpMap;
		sampler2D _ColourMap;
		sampler2D _ContourMap;

		float _MinRange;
		float _MaxRange;
		uniform float _AbsoluteHeight;
		uniform float _ContourStepping = 10.0;
		uniform fixed4 _ContourColour = fixed4(0.5, 0.5, 1.0, 1.0);

		struct Input 
		{
			float2 uv_HeightMap : TEXCOORD0;
			float2 uv_MainTex1 : TEXCOORD1;
			float2 uv_MainTex2 : TEXCOORD2;
			float2 uv_BumpMap : TEXCOORD3;
			float2 uv2_ColourMap; //Use to store mercator scale factor
			float viewDistance;
			float vertexHeight;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float3 viewPos = UnityObjectToViewPos(v.vertex);
			o.viewDistance = -viewPos.z - _ProjectionParams.y;
			v.tangent = float4(1.0, 0.0, 0.0, -1.0);
			v.normal = float3(0.0, 1.0, 0.0);			
			o.vertexHeight = mul(unity_ObjectToWorld, v.vertex).y;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 overlay = tex2D(_MainTex2, IN.uv_MainTex2);
			if (_MainTex2Custom == 1) overlay = CustomTerrainFrag(overlay);

			float height = (_AbsoluteHeight + IN.vertexHeight) * 100.0 * IN.uv2_ColourMap;

			#ifndef HEIGHTMAP_ACTIVE
				fixed4 base = tex2D(_MainTex1, IN.uv_MainTex1);
				if (_MainTex1Custom == 1) base = CustomTerrainFrag(base);

				if (overlay.r + overlay.g + overlay.b + overlay.a > 0.0)
				{
					o.Albedo = overlay.rgb * overlay.a + (1 - overlay.a) * base.rgb;
				}
				else
				{
					o.Albedo = base.rgb;
				}
			#else
			o.Albedo = float4 (0.3, 0.3, 0.3, 0.3);
			#endif
			
			o.Alpha = 1;
			fixed3 n = tex2D(_BumpMap, IN.uv_BumpMap).rgb;
			fixed4 normalFixed = float4(n.g, n.g, n.g, n.r);
			o.Normal = UnpackNormal(normalFixed);
			
			#ifdef CONTOURS_ACTIVE		
				float levels = 10;
				float steppedHeight = height / levels / _ContourStepping;
				float fmodHeight = fmod(steppedHeight, 1);
				float stepAmount = min(sqrt(0.0001 * IN.viewDistance), 0.05);
				float sep = step(1.0 - fmodHeight, stepAmount);
				float viewLimit = 25;
				if (sep > 0.1)
				{
					viewLimit += 75;
				}
				float alphaScale = 0.25 + sep * 0.75;
				if (IN.viewDistance > 25)
				{
					alphaScale = max(0.0, 0.25 - (IN.viewDistance - viewLimit) * 0.01);
				}

				float ddxy = abs(ddx(steppedHeight)) + abs(ddy(steppedHeight)) * 3;				
				float contour = frac(levels * steppedHeight);
				float contourSub = frac(-levels * steppedHeight);
				
				sep = clamp(sep * levels, 4, 8);
				float sepDdxy = ddxy * sep;
			
				float smoothedLine = smoothstep(ddxy, sepDdxy, contour);
				float smoothedLineSub = smoothstep(ddxy, sepDdxy, contourSub);
				
				float combinedLine = 1.0 - smoothedLine * smoothedLineSub;
				
				fixed contourMap = tex2D(_ContourMap, IN.uv_MainTex1).r;
				
				if (contourMap > 0.01 && contourMap < 0.99)
				{
					o.Albedo = fixed3(contourMap, contourMap, contourMap);
				}
				else
				{
					o.Albedo = lerp(o.Albedo, _ContourColour.rgb, combinedLine * alphaScale);
				}

			#endif
		}
		ENDCG
	}
	FallBack "Diffuse"
}
