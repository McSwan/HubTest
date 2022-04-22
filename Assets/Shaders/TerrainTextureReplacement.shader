﻿Shader "Custom/TerrainTextureReplacement"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Colour", Color) = (1,1,1,1)
	}
		
	SubShader
	{
		Stencil
		{
			Ref 1
			Comp Always
			Pass Zero
		}

		ZTest Always
		ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			uniform sampler2D _MainTex;
			uniform float4 _Offset;
			uniform float4 _Color;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = v.pos.xy + _Offset.xy;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv * 5) * _Color;
			}
			ENDCG
		}
	}
}