Shader "Custom/OrthoGrid"
{
	Properties 
	{
		_LineWidth ("Line Pixel Width", Float) = 1.0
		_MinorColour ("Minor Colour", Color) = (0.5, 0.5, 0.5, 1.0)
		_MajorColour ("Major Colour", Color) = (1.0, 1.0, 1.0, 1.0)
		_OrthoSize ("Orthographic Size", Float) = 1.0
		_WorldSpacing ("World Spacing", Float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Background-1001"
		}

		Pass
		{
			ZTest LEqual
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			
			uniform float _OrthoSize;
			uniform float _WorldSpacing;
			uniform float _LineWidth;
			uniform float4 _MinorColour;
			uniform float4 _MajorColour;
			uniform float4 _Offset;

			struct appdata
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 texelSize : TEXCOORD1;
				float2 orthoAndInverseAspect : TEXCOORD2;
				float2 pixelWorldDist : TEXCOORD3;
				float2 lineWidth : TEXCOORD4;
				float2 halfScreenParams : TEXCOORD5;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = v.uv;
				o.orthoAndInverseAspect.x = 1.0 / (_OrthoSize * 2.0);
				o.orthoAndInverseAspect.y = o.orthoAndInverseAspect.x * _ScreenParams.y / _ScreenParams.x;

				// Calculate texel offset and world spacing.
				float ScreenToWorld = _ScreenParams.y * o.orthoAndInverseAspect.x;
				o.texelSize = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
				o.pixelWorldDist = o.texelSize * ScreenToWorld * _WorldSpacing;
				o.lineWidth = o.texelSize * _LineWidth;
				o.halfScreenParams = _ScreenParams.xy * 0.5;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float orthoDouble = i.orthoAndInverseAspect.x;
				float inverseAspect = i.orthoAndInverseAspect.y;

				// Calculate lines.
				float2 offset = float2(i.uv.x + _Offset.x * inverseAspect, i.uv.y + _Offset.y * orthoDouble);
				float2 halfUv = offset - ceil(i.halfScreenParams) * i.texelSize;

				float2 minor = abs(fmod(halfUv, i.pixelWorldDist));
				float2 major = abs(fmod(halfUv, i.pixelWorldDist * 5));

				// Fix centre line being thicker.
				bool centre = abs(halfUv.x) < i.lineWidth.x || abs(halfUv.y) < i.lineWidth.y;
				if (centre)
				{
					i.lineWidth = (i.lineWidth * i.halfScreenParams) * i.texelSize;
				}

				// Draw major lines.
				if (major.x < i.lineWidth.x || major.y < i.lineWidth.y)
				{
					return _MajorColour;
				}

				// Draw minor lines.
				if (minor.x < i.lineWidth.x || minor.y < i.lineWidth.y)
				{
					return _MinorColour;
				}
				
				// Draw nothing.
				return float4(0, 0, 0, 0);
			}
			ENDCG
		}
	}

	Fallback off
}
