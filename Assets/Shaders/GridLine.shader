Shader "Custom/GridLine"
{
    Properties
    {
        _Colour("Base (RGB)", Color) = (1,1,1,1)
        _Mask("Mask", 2D) = "White" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
        }

        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex vert  
            #pragma fragment frag 

            #include "UnityCG.cginc"

            // User-specified uniforms            
            uniform float4 _Colour;
            uniform sampler2D _Mask;

            struct vertexInput
            {
                float4 pos : POSITION;
				float4 col : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 col : COLOR;
                float2 uv : TEXCOORD0;
            };

            vertexOutput vert(vertexInput input)
            {
                vertexOutput output;
				
                output.pos = UnityObjectToClipPos(input.pos);
                output.col = _Colour * input.col;
                output.uv = input.uv;

                return output;
            }

            fixed4 frag(vertexOutput input) : SV_Target
            {
                fixed2 UV = input.uv.xy;
                fixed4 alpha = tex2D(_Mask, UV);

                fixed4 colour = input.col * alpha;
                return colour;
            }

            ENDCG
        }
    }
}