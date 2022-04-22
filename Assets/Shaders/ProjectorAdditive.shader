Shader "Projector/Additive" 
{
    Properties
    {
       _ShadowTex("Projected Image", 2D) = "white" {}
    }

    SubShader
    {
        Pass 
        {
			Blend SrcAlpha OneMinusSrcAlpha // blend color of _ShadowTex with the color in the framebuffer
            ZWrite Off // don't change depths
            Offset -1, -1 // avoid depth fighting

            CGPROGRAM

            #pragma vertex vert  
            #pragma fragment frag 

            // User-specified properties
            uniform sampler2D _ShadowTex;

            // Projector-specific uniforms
            uniform float4x4 unity_Projector; // transformation matrix from object space to projector space 

            struct vertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
			struct vertexOutput {
                float4 pos : SV_POSITION;
                float4 posProj : TEXCOORD0;
                // position in projector space
            };

             vertexOutput vert(vertexInput input)
             {
                vertexOutput output;

                output.posProj = mul(unity_Projector, input.vertex);
                output.pos = UnityObjectToClipPos(input.vertex);
                return output;
             }


            float4 frag(vertexOutput input) : COLOR
            {
                if (abs(input.posProj.x) <= 1 && abs(input.posProj.y) <= 1 && input.posProj.w > 0.0)
                {
                    return tex2D(_ShadowTex, input.posProj.xy / input.posProj.w);
                }
                else // outside of projector frustum
                {
                    return float4(0.0, 0.0, 0.0, 0.0);
                }
            }

            ENDCG
        }
    }
    //Fallback "Projector/Light"
}