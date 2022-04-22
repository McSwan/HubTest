Shader "Custom/Label" 
{
	Properties
	{
		_MainTex("Font Texture", 2D) = "white" {}
		_Color("Text Color", Color) = (1,1,1,1)
		_Scale("Font Scale", Float) = 1.0
		_ClampedToGround("Clamped To Ground", Int) = 1
		_TextWidth("Text Width", Int) = 1
		_TextHeight("Text Height", Int) = 1
		_OutlineWidth("Outline Width", Float) = 2.0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata_t
	{
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		fixed4 color : COLOR;
		float2 texcoord : TEXCOORD0;
	};

	sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform fixed4 _Color;
	uniform float _Scale;
	uniform int _ClampedToGround;
	uniform int _TextWidth;
	uniform int _TextHeight;
	uniform float _OutlineWidth;
	
	// Global
	uniform float g_CameraAltitude;

	v2f vert(appdata_t v, float outlineWidth)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(float4(0, 0, 0, 1));
		
		float viewScale = 1;
		//Dot product between worldspace camera forward vector and worldspace up vector
		//to check if you've started tilting towards the horizon
		float viewDot = UNITY_MATRIX_IT_MV[2].y;
		if (viewDot < 0.75)
		{
			//Make between 0 and 1
			float angleScale = 4 * viewDot - 2;
			if (angleScale < 0.0)
			{
				angleScale = 0.0;
			}
			//Note that output.pos.w is the depth of the vertex in world space
			viewScale = angleScale + (g_CameraAltitude + 1) / abs(o.vertex.w) * 2;
			//Clamp the maximum size
			if (viewScale > 1)
			{
				viewScale = 1;
			}

			// Fade as text gets smaller.
			if (viewScale < 0.5)
			{
				// Immediately hide outlines to prevent transition from white text to black during fade.
				if (abs(outlineWidth) > 0.0)
				{
					v.color.a = 0;
				}
				else
				{
					v.color.a = viewScale;
				}
			}
		}

		// Scale label based on FOV.
		const float rad2DegDividedByDefaultFov = 1.9098593;
#if UNITY_UV_STARTS_AT_TOP
		float hFov = -UNITY_MATRIX_P[1].y;
#else		
		float hFov = UNITY_MATRIX_P[1].y;
#endif
		float fov = atan(1.0 / hFov) * rad2DegDividedByDefaultFov;
		viewScale *= fov;
		
		float4 offset = float4(0, 0, 0, 0);

		//Shift icon up so it doesn't clip the terrain
		if (_ClampedToGround == 1)
		{
			float4 upVec = normalize(mul(UNITY_MATRIX_V, float4(0, 1, 0, 0))) * 0.25f;
			offset += upVec * o.vertex.w * viewScale * v.texcoord.y / _ScreenParams.y;
		}
		
		offset.xy += float2(_TextWidth + outlineWidth + 20, _TextHeight + outlineWidth) * viewScale * o.vertex.w / _ScreenParams.y * 0.5;
		offset.xy += v.vertex.xy * _Scale * viewScale * o.vertex.w / _ScreenParams.y * 0.5;

		// If orthographic, apply scale fix.
		if (unity_OrthoParams.w > 0.5)
		{
			offset.xy *= unity_OrthoParams.y * 2;
		}

		o.vertex = mul(UNITY_MATRIX_P, float4(UnityObjectToViewPos(float4(0.0, 0.0, 0.0, 1.0)), 1.0) + offset);


		o.color = v.color * _Color;
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent-500"
		}

		Pass
		{
			Name "OUTLINE1"
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always

			CGPROGRAM
			#pragma vertex vertOutline1
			#pragma fragment frag

			v2f vertOutline1(appdata_t v)
			{
				return vert(v, _OutlineWidth);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float alpha = tex2D(_MainTex, i.texcoord).a;
				return fixed4(1.0 - i.color.rrr, alpha);
			}
			ENDCG
		}

		Pass
		{
			Name "OUTLINE2"
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always

			CGPROGRAM
			#pragma vertex vertOutline2
			#pragma fragment frag

			v2f vertOutline2(appdata_t v)
			{
				return vert(v, -_OutlineWidth);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed alpha = tex2D(_MainTex, i.texcoord).a;
				return fixed4(1.0 - i.color.rrr, alpha);
			}
			ENDCG
		}

		Pass
		{
			Name "TEXTURE"
			ZWrite On
			ZTest Always
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vertBase
			#pragma fragment frag

			v2f vertBase(appdata_t v)
			{
				return vert(v, 0);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = i.color;
				col.a *= tex2D(_MainTex, i.texcoord).a;
				return col;
			}
			ENDCG
		}
	}
}