﻿Shader "Custom/UnlitColour"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_ZTestOff("Z-Test", int) = 4
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		
		ZTest [_ZTestOff]
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			struct appdata
			{
				float4 pos : POSITION;
				float4 col : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			uniform float4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.col = v.col * _Color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.col;
			}
			ENDCG
		}
	}
}