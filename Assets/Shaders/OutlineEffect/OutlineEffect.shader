// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Hidden/OutlineEffect"
{
	/*
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.01
	}

	SubShader
	{
		CGINCLUDE
		struct Input
		{
			float4 position : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct Varying
		{
			float4 position : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		Varying vertex(Input input)
		{
			Varying output;

			output.position = UnityObjectToClipPos(input.position);
			output.uv = input.uv;
			return output;
		}
		ENDCG

		Tags { "RenderType" = "Opaque" }

		// #0: first blur pass, horizontal or vertical
		// uses the objects brightest channel for all chanels and spreads that out
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vertex
			#pragma fragment fragment
			#pragma target 3.0
			#include "UnityCG.cginc"

			float2 _BlurDirection;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			// 9-tap Gaussian kernel, that blurs green & blue channels,
			// keeps red & alpha intact.
			static const half4 kCurveWeights[9] = {
				half4(0,0.0204001988,0.0204001988,0),
				half4(0,0.0577929595,0.0577929595,0),
				half4(0,0.1215916882,0.1215916882,0),
				half4(0,0.1899858519,0.1899858519,0),
				half4(1,0.2204586031,0.2204586031,1),
				half4(0,0.1899858519,0.1899858519,0),
				half4(0,0.1215916882,0.1215916882,0),
				half4(0,0.0577929595,0.0577929595,0),
				half4(0,0.0204001988,0.0204001988,0)
			};

			half4 fragment(Varying i) : SV_Target
			{
				float2 step = _MainTex_TexelSize.xy * _BlurDirection;
				float2 uv = i.uv - step * 4;
				half4 col = 0;
				for (int tap = 0; tap < 9; ++tap)
				{
					half4 val = tex2D(_MainTex, uv);
					half maxVal = max(val.r, max(val.g, max(val.b, val.a)));
					val = half4(maxVal, maxVal, maxVal, maxVal);
					col += val * kCurveWeights[tap];
					uv += step;
				}
				return col;
			}
			ENDCG
		}

		// #1: second blur pass, either horizontal or vertical
		// spreads the results of the previous pass
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vertex
			#pragma fragment fragment
			#pragma target 3.0
			#include "UnityCG.cginc"

			float2 _BlurDirection;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			// 9-tap Gaussian kernel, that blurs green & blue channels,
			// keeps red & alpha intact.
			static const half4 kCurveWeights[9] = {
				half4(0,0.0204001988,0.0204001988,0),
				half4(0,0.0577929595,0.0577929595,0),
				half4(0,0.1215916882,0.1215916882,0),
				half4(0,0.1899858519,0.1899858519,0),
				half4(1,0.2204586031,0.2204586031,1),
				half4(0,0.1899858519,0.1899858519,0),
				half4(0,0.1215916882,0.1215916882,0),
				half4(0,0.0577929595,0.0577929595,0),
				half4(0,0.0204001988,0.0204001988,0)
			};

			half4 fragment(Varying i) : SV_Target
			{
				float2 step = _MainTex_TexelSize.xy * _BlurDirection;
				float2 uv = i.uv - step * 4;
				half4 col = 0;
				for (int tap = 0; tap < 9; ++tap)
				{
					col += tex2D(_MainTex, uv) * kCurveWeights[tap];
					uv += step;
				}
				return col;
			}
			ENDCG
		}

		// #2: final postprocessing pass
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vertex
			#pragma fragment fragment
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			half4 _OutlineColor;
			float _BlurBoost;

			half4 fragment(Varying i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);

				bool isSelected = col.a > 0.9;
				bool inFront = col.g > 0.0;
				bool backMask = col.r == 0.0;

				float alpha = saturate(col.b * _BlurBoost);
				if (isSelected)
				{
					// _OutlineColor alpha controls how much tint the whole object gets
					alpha = _OutlineColor.a;
					if (any(i.uv - _MainTex_TexelSize.xy * 2 < 0) || any(i.uv + _MainTex_TexelSize.xy * 2 > 1))
						alpha = 1;
				}

				if (!inFront)
				{
					alpha *= 0.3;
				}

				if (backMask && isSelected)
				{
					alpha = 0;
				}

				float4 OutlineEffectColor = float4(_OutlineColor.rgb,alpha);
				return OutlineEffectColor;
			}
			ENDCG
		}
	}
	*/
}