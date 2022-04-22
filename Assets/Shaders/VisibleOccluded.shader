Shader "Custom/VisibleOccluded" {
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Indicator ("Indicator Color", Color) = (1,1,1,1)
    }
   
    SubShader
    {
        Tags { "Queue" = "Geometry+1" "RenderType" = "Opaque" }
         LOD 200

        CGPROGRAM
        #pragma surface surf Lambert exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv
       
        sampler2D _MainTex;
         
        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };
       
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D ( _MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
        
        Blend SrcAlpha OneMinusSrcAlpha

// Pass: Under Surface Shader
      Pass
        {
            Tags { "LightMode" = "Always" }
            AlphaTest Greater [_Indicator.a]
            ZWrite Off
            ZTest Greater
         
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform float4 _Indicator;
			float4 _MainTex_ST;
		 
            struct v2f
            {
                float4 pos          : POSITION;
                float2 uv           : TEXCOORD1;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);    
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                return o;
            }
            
            half4 frag( v2f i ) : COLOR
            {
                half4 texcol = _Indicator;
                return  texcol;
            }
            ENDCG          
        } 
 }
 Fallback " Glossy", 0
}