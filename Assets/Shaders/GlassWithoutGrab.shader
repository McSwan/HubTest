Shader "Custom/GlassWithoutGrab" 
{
	Properties
	{
	    _BumpAmt("Distortion", Range(0,64)) = 15
		_TintAmt("Tint Amount", Range(0,1)) = 0.3
		_BumpMap("Normalmap", 2D) = "bump" {}
		_MaskTex("Mask Texture", 2D) = "black" {}
		_TintColor("Tint Color", Color) = (0,0,0,1)
		_MaskScale("Mask Scale", Float) = 0
		_MaskHighlightEffect("Mask Highlight Effect", Range(0.5, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent-1"
		}

		Blend One OneMinusSrcAlpha
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform half _BumpAmt;
			uniform half _TintAmt;
			uniform sampler2D _GrabBlurTexture;
			uniform float4 _GrabBlurTexture_TexelSize;
			uniform fixed4 _TintColor;
			uniform sampler2D _MaskTex;
			uniform sampler2D _BumpMap;
			uniform float4 _MaskTex_ST;
			uniform float4 _BumpMap_ST;
			uniform float _MaskScale;
			uniform float _MaskHighlightEffect;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				float4 uvgrab : TEXCOORD0;
				float2 uvbump : TEXCOORD1;
				float2 uvmask : TEXCOORD2;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.zw;
				o.uvbump = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.uvmask = TRANSFORM_TEX(v.texcoord, _MaskTex);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
			    half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
				float2 offset = bump * _BumpAmt * _GrabBlurTexture_TexelSize.xy;
                i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
				
				half4 col = tex2Dproj(_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab));
				col = lerp(col, _TintColor, _TintAmt);

				float4 mask = tex2D(_MaskTex, i.uvmask);
				col.a = 1 - mask.r;
				col.rgb = col.rgb * (1 - mask.r);

				return col;
			}
			ENDCG
		}
	}
}