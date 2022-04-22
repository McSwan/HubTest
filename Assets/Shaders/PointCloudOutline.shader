Shader "Custom/PointCloudOutline" 
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "" {}
		_Exponent("Exponent", Float) = 0.5
	}

	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			Stencil
			{
				Ref 1
				Comp Equal
			}

			CGPROGRAM
			#pragma target 3.0   
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv[2] : TEXCOORD0;
			};

			sampler2D _MainTex;
			uniform half4 _Color;
			uniform float4 _MainTex_TexelSize;

			sampler2D_float _CameraDepthTexture;

			uniform half4 _BgColor;
			uniform half _BgFade;
			uniform half _SampleDistance;
			uniform float _Exponent;

			uniform float _Threshold;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float2 uv = v.texcoord.xy;
				o.uv[0] = uv;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0.0)
				{
					uv.y = 1.0 - uv.y;
				}
				#endif

				o.uv[1] = uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				// inspired by borderlands implementation of popular "sobel filter"
				_SampleDistance = 1.0;

				float centerDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv[1]));
				float4 depthsDiag;
				float4 depthsAxis;

				float2 uvDist = _SampleDistance * _MainTex_TexelSize.xy;

				depthsDiag.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] + uvDist)); // TR
				depthsDiag.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] + uvDist * float2(-1,1))); // TL
				depthsDiag.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] - uvDist * float2(-1,1))); // BR
				depthsDiag.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] - uvDist)); // BL

				depthsAxis.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] + uvDist * float2(0,1))); // T
				depthsAxis.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] - uvDist * float2(1,0))); // L
				depthsAxis.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] + uvDist * float2(1,0))); // R
				depthsAxis.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv[1] - uvDist * float2(0,1))); // B

				depthsDiag -= centerDepth;
				depthsAxis /= centerDepth;

				const float4 HorizDiagCoeff = float4(1,1,-1,-1);
				const float4 VertDiagCoeff = float4(-1,1,-1,1);
				const float4 HorizAxisCoeff = float4(1,0,0,-1);
				const float4 VertAxisCoeff = float4(0,1,-1,0);

				float4 SobelH = depthsDiag * HorizDiagCoeff + depthsAxis * HorizAxisCoeff;
				float4 SobelV = depthsDiag * VertDiagCoeff + depthsAxis * VertAxisCoeff;

				float SobelX = dot(SobelH, float4(1,1,1,1));
				float SobelY = dot(SobelV, float4(1,1,1,1));
				float Sobel = sqrt(SobelX * SobelX + SobelY * SobelY);

				Sobel = 1.0 - pow(saturate(Sobel), _Exponent);
				return Sobel * tex2D(_MainTex, i.uv[0].xy);
			}
			ENDCG
		}
	}

	Fallback off
}