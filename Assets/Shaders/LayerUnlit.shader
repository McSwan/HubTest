﻿Shader "Custom/LayerUnlit"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
	}
		
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 pos : POSITION;
				float4 col : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
				float2 uv : TEXCOORD0;
			};

			uniform float4 _Color;
			uniform sampler2D _MainTex;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.col = v.col * _Color;
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv) * i.col;
			}
			ENDCG
		}
	}
}