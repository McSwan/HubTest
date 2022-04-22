Shader "Custom/PointCloud"
{
    Properties
    {
        _PointSize("PointSize", Float) = 4.0
        _MinPointSize("MinPointSize", Float) = 2.0
        _Gradient("Height Texture", 2D) = "white" {}
        _ClassificationColors("Classification Texture", 2D) = "white" {}
        _MinVisible("Min Visible", Float) = 0.0
        _MaxVisible("Max Visible", Float) = 1.0
        _MinHeight("Min Height", Float) = 0.0
        _MaxHeight("Max Height", Float) = 10.0
    }

    SubShader
    {		
		Tags 
		{ 
			"Queue" = "Geometry+1" 
		}

        Pass
        {
			Stencil
			{
				Ref 1
				Comp always
				Pass replace
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            #pragma target 4.0
			
			#pragma multi_compile __ HEIGHT
			#pragma multi_compile __ CULLING
			#pragma multi_compile __ AMBIENT_OCCLUSION

            struct FragmentInput
            {
                float4 pos : SV_POSITION;
				fixed4 col : COLOR;
				fixed2 uv : TEXCOORD0;
            };

            struct VertexInput
            {
                float4 v : POSITION;
                fixed4 color: COLOR;
                float3 heightAmbientClassification : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                fixed4 col : COLOR;
            };

            uniform sampler2D _Gradient;
            uniform sampler2D _ClassificationColors;
            float4 _ClassificationColors_TexelSize;
            fixed _AmbientOcclusion;
            int _ColourMode;
            float _PointSize;
            float _MinPointSize;
            float _MinVisible;
            float _MaxVisible;
            float _MinHeight;
            float _MaxHeight;
            
			#include "CustomPointCloud.cginc"

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = v.v;

				#if defined(HEIGHT) || defined(CULLING)
                float height = v.heightAmbientClassification.x;
                float heightRange = _MaxHeight - _MinHeight;
                float heightOffset = height - _MinHeight;
                height = heightOffset / heightRange;
                
				#if defined(CULLING)
                if (height < _MinVisible)
                {
                    o.col = fixed4(0, 0, 0, 0);
                    return o;
                }
                
                if (height > _MaxVisible)
                {
                    o.col = fixed4(0, 0, 0, 0);
                    return o;
                }
				#endif
				#endif

                switch (_ColourMode)
                {
                    case 0:
                        o.col = v.color;
                        break;
					#if defined(HEIGHT)
                    case 1:
                        o.col = tex2Dlod(_Gradient, float4(height, 0, 1, 1));
                        break;
					#endif
                    case 2:
                        o.col = tex2Dlod(_ClassificationColors, float4(v.heightAmbientClassification.z * _ClassificationColors_TexelSize.x, 0, 1, 1));
                        break;
                    default:
                        o.col = CustomPointCloudVert(v);
                        break;
                }

				#if defined(AMBIENT_OCCLUSION)
				if (_AmbientOcclusion > 0.0 && v.heightAmbientClassification.y > 0.0)
				{
					fixed ao = (255.0 - v.heightAmbientClassification.y) / 255.0;
					o.col.rgb -= ao * o.col.rgb * _AmbientOcclusion;
				}
				#endif
				
                return o;
            }

			// Geometry Shader -----------------------------------------------------
			[maxvertexcount(3)]
			void geom(point VertexOutput p[1], inout TriangleStream<FragmentInput> triStream)
			{
				if (p[0].col.a == 0.0)
				{
					return;
				}

				float3 clip = p[0].pos.xyz;
				float size = _PointSize / _ScreenParams.y * 2.0;

				float4 up = float4(UNITY_MATRIX_V[1].xyz, 0.0);
				float4 right = float4(-UNITY_MATRIX_V[0].xyz, 0.0);

				// In UV coordinates point (0.5, 0.5) is described
				// by summed weight of 3 vertices (0.29 for apex, 0.36, 0.36 for base vertices)
				// i.e. Barycentric coordinates
				// Summing these weights in view-space gives us the point (0, -0.43 * size * up.y, 0)
				// i.e. The center of circle will be -0.43 * size * up.y below actual point position
				// Let's adjust for this by shifting the triangle up that amount
				const float yshift = 0.43;

				float4 c = UnityObjectToClipPos(clip.xyz);
				float4 pos1 = UnityObjectToClipPos(clip.xyz + (1 + yshift) * size * up.xyz);

				float pixelSize = abs(pos1.y - c.y) / c.w * _ScreenParams.y;

				FragmentInput pIn;
				pIn.col = p[0].col;
				pIn.uv = float2(0.5, 1.732);
				
				if (pixelSize > _MinPointSize * 0.8)
				{					
					pIn.pos = pos1;
				}
				else
				{	
					size = (_MinPointSize / _ScreenParams.x * c.w);
					pos1.xyz = clip.xyz + size * up.xyz;
					pIn.pos = UnityObjectToClipPos(pos1);
				}
				triStream.Append(pIn);

				right.xyz *= size;
				up.xyz *= size;
				clip.xyz -= (1 - yshift) * up.xyz;

				pIn.pos = UnityObjectToClipPos(clip.xyz - right.xyz);
				pIn.uv = fixed2(1.366, 0.0);
				triStream.Append(pIn);

				pIn.pos = UnityObjectToClipPos(clip.xyz + right.xyz);
				pIn.uv = fixed2(-0.366, 0.0);
				triStream.Append(pIn);
			}

			fixed4 frag(FragmentInput o) : COLOR
			{
				fixed2 coord = o.uv - fixed2(0.5, 0.5);
				if (dot(coord, coord) > 0.25)
				{
					discard;
				}

				return o.col;
			}

			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }
			ColorMask 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#pragma target 4.0
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			#pragma multi_compile __ HEIGHT
			#pragma multi_compile __ CULLING
			#pragma multi_compile __ AMBIENT_OCCLUSION

            uniform sampler2D _ClassificationColors;
            float4 _ClassificationColors_TexelSize;
            int _ColourMode;
			float _PointSize;
			float _MinPointSize;
            float _MinVisible;
            float _MaxVisible;
            float _MinHeight;
            float _MaxHeight;
			
			struct FragmentInput
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			struct VertexInput
			{
				float4 v : POSITION;
				float3 heightAmbientClassification : NORMAL;
			};

			struct VertexOutput
			{
				float4 pos : SV_POSITION;
				fixed alpha : TEXCOORD0;
			};

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.pos = v.v;
				o.alpha = 1.0;
				
				#if defined(HEIGHT) || defined(CULLING)
				float height = v.heightAmbientClassification.x;
				float heightRange = _MaxHeight - _MinHeight;
				float heightOffset = height - _MinHeight;
				height = heightOffset / heightRange;

				#if defined(CULLING)
				if (height < _MinVisible)
				{
					o.alpha = 0.0;
					return o;
				}

				if (height > _MaxVisible)
				{
					o.alpha = 0.0;
					return o;
				}
				#endif
				#endif
				
				if (_ColourMode == 2)
                {
                    o.alpha = tex2Dlod(_ClassificationColors, float4(v.heightAmbientClassification.z * _ClassificationColors_TexelSize.x, 0, 1, 1)).a;
                }
				
				return o;
			}

			// Geometry Shader -----------------------------------------------------
			[maxvertexcount(3)]
			void geom(point VertexOutput p[1], inout TriangleStream<FragmentInput> triStream)
			{
				if (p[0].alpha == 0.0)
				{
					return;
				}

				float3 clip = p[0].pos.xyz;
				float size = _PointSize / _ScreenParams.y * 2.0;

				float4 up = float4(UNITY_MATRIX_V[1].xyz, 0.0);
				float4 right = float4(-UNITY_MATRIX_V[0].xyz, 0.0);

				// In UV coordinates point (0.5, 0.5) is described
				// by summed weight of 3 vertices (0.29 for apex, 0.36, 0.36 for base vertices)
				// i.e. Barycentric coordinates
				// Summing these weights in view-space gives us the point (0, -0.43 * size * up.y, 0)
				// i.e. The center of circle will be -0.43 * size * up.y below actual point position
				// Let's adjust for this by shifting the triangle up that amount
				const float yshift = 0.43;

				float4 c = UnityObjectToClipPos(clip.xyz);
				float4 pos1 = UnityObjectToClipPos(clip.xyz + (1 + yshift) * size * up.xyz);

				float pixelSize = abs(pos1.y - c.y) / c.w * _ScreenParams.y;

				FragmentInput pIn;
				pIn.uv = fixed2(0.5, 1.732);

				if (pixelSize > _MinPointSize * 0.8)
				{					
					pIn.pos = pos1;
				}
				else
				{	
					size = (_MinPointSize / _ScreenParams.x * c.w);
					pos1.xyz = clip.xyz + size * up.xyz;
					pIn.pos = UnityObjectToClipPos(pos1);
				}
				triStream.Append(pIn);

				right.xyz *= size;
				up.xyz *= size;
				clip.xyz -= (1 - yshift) * up.xyz;

				pIn.pos = UnityObjectToClipPos(clip.xyz - right.xyz);
				pIn.uv.xy = fixed2(1.366, 0.0);
				triStream.Append(pIn);

				pIn.pos = UnityObjectToClipPos(clip.xyz + right.xyz);
				pIn.uv.xy = fixed2(-0.366, 0.0);
				triStream.Append(pIn);
			}

			fixed4 frag(FragmentInput input) : SV_Target
			{
				fixed2 coord = input.uv - fixed2(0.5, 0.5);
				if (dot(coord, coord) > 0.25)
				{
					discard;
				}
				
				return 0;
			}

			ENDCG
		}
	}
}