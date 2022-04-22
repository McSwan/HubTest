Shader "FX/Water" 
{
	Properties
	{
		_WaveScale("Wave scale", Range(0.005,0.15)) = 0.01
		_ReflDistort("Reflection distort", Range(0,1.5)) = 0.44
		_RefrDistort("Refraction distort", Range(0,1.5)) = 0.40
		_RefrColor("Refraction color", COLOR) = (.34, .85, .92, 1)
		[NoScaleOffset] _Fresnel("Fresnel (A) ", 2D) = "gray" {}
		[NoScaleOffset] _BumpMap("Normalmap ", 2D) = "bump" {}
		[NoScaleOffset] _WaterMask("Water Mask", 2D) = "white" {}
		_WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
		[NoScaleOffset] _ReflectiveColor("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
		_HorizonColor("Simple water horizon color", COLOR) = (.172, .463, .435, 1)
		[HideInInspector] _ReflectionTex("Internal Reflection", 2D) = "" {}
		[HideInInspector] _RefractionTex("Internal Refraction", 2D) = "" {}
		[HideInInspector] _BumpScaleOffset("Normalmap Scale Offset", Vector) = (1, 1, 0, 0)
		[HideInInspector] _CameraPos("Camera Position", Vector) = (0, 0, 0, 0)
	}

	// -----------------------------------------------------------
	// Fragment program cards

	Subshader
	{
		ZTest LEqual
		Cull Off
		ZWrite Off
		Offset -1, -1

		Blend SrcAlpha OneMinusSrcAlpha
		Tags
		{
			"WaterMode" = "Refractive" 
			"Queue" = "Transparent" 
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile WATER_REFRACTIVE WATER_REFLECTIVE WATER_SIMPLE

			#if defined (WATER_REFLECTIVE) || defined (WATER_REFRACTIVE)
			#define HAS_REFLECTION 1
			#endif

			#if defined (WATER_REFRACTIVE)
			#define HAS_REFRACTION 1
			#endif

			#include "UnityCG.cginc"

			uniform float _WaveScale;
			uniform float _AbsoluteHeight;
			uniform float4 _WaveSpeed;
			uniform float4 _BumpScaleOffset;
			uniform float4 _CameraPos;
			#if HAS_REFLECTION
				uniform float _ReflDistort;
			#endif
			#if HAS_REFRACTION
				uniform float _RefrDistort;
			#endif

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv     : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 ref : TEXCOORD5;
				#if defined(HAS_REFLECTION) || defined(HAS_REFRACTION)
					float2 bumpuv0 : TEXCOORD1;
					float2 bumpuv1 : TEXCOORD2;
					float3 viewDir : TEXCOORD3;
				#else
					float2 bumpuv0 : TEXCOORD0;
					float2 bumpuv1 : TEXCOORD1;
					float3 viewDir : TEXCOORD2;
				#endif
				float2 uv : TEXCOORD4;
				float4 screenUV : TEXCOORD6;
				float nearClipFade : TEXCOORD7;
			};

			v2f vert(appdata v)
			{
				v2f o;

				v.uv += _CameraPos.xz;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.ref = ComputeScreenPos(o.pos);
				o.screenUV = UNITY_PROJ_COORD(o.ref);

				// scroll bump waves
				_WaveScale *= 2;
				float4 waveScale4 = float4(_WaveScale, _WaveScale, _WaveScale * 0.4, _WaveScale * 0.45);

				float4 _WaveOffset = float4(_WaveSpeed.x * waveScale4.x * _Time[0], _WaveSpeed.y * waveScale4.y * _Time[0], _WaveSpeed.z * waveScale4.z * _Time[0], _WaveSpeed.w * waveScale4.w * _Time[0]);

				float4 temp;
				_BumpScaleOffset = float4(1, 1, 0, 0);
				temp.xyzw = v.uv.xyxy * _BumpScaleOffset.xyxy + _WaveOffset;
				o.bumpuv0 = temp.xy;
				o.bumpuv1 = temp.wz;

				// object space view direction (will normalize per pixel)
				o.viewDir.xzy = WorldSpaceViewDir(v.vertex);

				// Cheap but nice looking near clip fade.
				float3 viewPos = UnityObjectToViewPos(v.vertex);
				o.nearClipFade = (-viewPos.z - _ProjectionParams.y) / 0.03;

				return o;
			}

			#if defined (WATER_REFLECTIVE) || defined (WATER_REFRACTIVE)
				sampler2D _ReflectionTex;
			#endif
			#if defined (WATER_REFLECTIVE) || defined (WATER_SIMPLE)
				sampler2D _ReflectiveColor;
			#endif
			#if defined (WATER_REFRACTIVE)
				sampler2D _Fresnel;
				sampler2D _RefractionTex;
				uniform float4 _RefrColor;
			#endif
			#if defined (WATER_SIMPLE)
				uniform float4 _HorizonColor;
			#endif
			sampler2D _BumpMap;
			sampler2D _WaterMask;

			half4 frag(v2f i) : SV_Target
			{
				i.viewDir = normalize(i.viewDir);

				// combine two scrolling bumpmaps into one
				half3 bump1 = UnpackNormal(tex2D(_BumpMap, i.bumpuv0)).rgb;
				half3 bump2 = UnpackNormal(tex2D(_BumpMap, i.bumpuv1)).rgb;
				half3 bump = (bump1 + bump2) * 0.5;

				// fresnel factor
				half fresnelFac = dot(i.viewDir, bump);

				// perturb reflection/refraction UVs by bumpmap, and lookup colors
				#if HAS_REFLECTION
					float4 uv1 = i.ref; uv1.xy += bump * _ReflDistort * 0.05;
					half4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(uv1));
				#endif
				#if HAS_REFRACTION
					float4 uv2 = i.ref; uv2.xy -= bump * _RefrDistort * 0.05;
					half4 refr = tex2Dproj(_RefractionTex, UNITY_PROJ_COORD(uv2)) * _RefrColor;
				#endif

				// final color is between refracted and reflected based on fresnel
				half4 color;

				#if defined(WATER_REFRACTIVE)
					half fresnel = UNITY_SAMPLE_1CHANNEL(_Fresnel, float2(fresnelFac,fresnelFac));
					color = lerp(refr, refl, fresnel);
				#endif

				#if defined(WATER_REFLECTIVE)
					half4 water = tex2D(_ReflectiveColor, float2(fresnelFac,fresnelFac));
					color.rgb = lerp(water.rgb, refl.rgb, water.a);
					color.a = refl.a * water.a;
				#endif

				#if defined(WATER_SIMPLE)
					half4 water = tex2D(_ReflectiveColor, float2(fresnelFac,fresnelFac));
					color.rgb = lerp(water.rgb, _HorizonColor.rgb, water.a);
				#endif

				color.a = 1.0f - tex2Dproj(_WaterMask, i.screenUV).r;

				if (_AbsoluteHeight > 0.0)
				{
					color.a -= _AbsoluteHeight / 1000;
				}

				color.a *= min(1, i.nearClipFade * i.nearClipFade);

				return color;
			}

			ENDCG
		}
	}
}