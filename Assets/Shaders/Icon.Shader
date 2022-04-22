Shader "Custom/Icon"
{
	Properties
	{
		_MainTex("Texture Image", 2D) = "white" {}
		_ZTestOff("Z-Test", int) = 4
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent-500" }

		Pass
		{
			ZWrite On
			ColorMask 0
			ZTest [_ZTestOff]

			CGPROGRAM

			#include "Icon.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#pragma target 4.0

			fixed4 frag(FragmentInput o) : COLOR
			{
				fixed4 col = tex2D(_MainTex, o.uv) * o.col;
				if (col.a < 0.75)
				{
					discard;
				}
				
				return col;
			}
			
			ENDCG
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTestOff]

			CGPROGRAM

			#include "Icon.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#pragma target 4.0

			fixed4 frag(FragmentInput o) : COLOR
			{
				if (o.uv.x < 0.0 || o.uv.x > 1.0 || o.uv.y < 0.0 || o.uv.y > 1.0)
				{
					return float4(0.0, 0.0, 0.0, 0.0);
				}

				return tex2D(_MainTex, o.uv) * o.col;
			}
			
			ENDCG
		}
	}
}