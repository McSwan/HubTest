Shader "Custom/Line" 
{
	Properties
	{
		_ZTestOff("Z-Test", int) = 4
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTestOff]
			Cull Off

			CGPROGRAM          
			#pragma multi_compile __ LINES_CLAMPED
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			struct appdata 
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				fixed4 color : COLOR;
				float width : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID 
			};

			struct v2f
			{
				float4 pos : POSITION;
				fixed4 color : COLOR;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform int _ZTestOff;

			v2f vert(appdata v)
			{
				if (v.width < 0.001)
				{
					v2f o;
					o.pos = float4(0, 0, 0, 0);
					o.color = float4(0, 0, 0, 0);
					return o;
				}

				float aspect = _ScreenParams.x / _ScreenParams.y;

				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.pos = UnityObjectToClipPos(v.vertex);
#if LINES_CLAMPED
				v.vertex.y += (v.width * o.pos.w) / _ScreenParams.y;
				o.pos = UnityObjectToClipPos(v.vertex);
#endif

				// Calculate the screen space size of the line.
				float4 normPos = UnityObjectToClipPos(v.vertex + v.normal);
				float2 screenVec = (normPos.xy / normPos.w) - (o.pos.xy / o.pos.w);
				screenVec.x *= aspect;
				float2 screenNorm = normalize(screenVec);

				// Add the final offset to the world position.
				float4 offset = float4(screenNorm.y / _ScreenParams.x, -screenNorm.x / _ScreenParams.y, 0, 0) * v.width;
				o.pos += offset * o.pos.w;
				o.color = v.color;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				if (i.color.a < 0.001)
				{
					discard;
				}

				return i.color;
			}
			
			ENDCG
		}
	}
}