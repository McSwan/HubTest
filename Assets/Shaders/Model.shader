Shader "Custom/Model" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Specular("Specular", Color) = (0,0,0)
        _SpecularTex("Specular (RGB)", 2D) = "white" {}
        _Emission("Emission", Color) = (0,0,0)
        _EmissionTex("Emission (RGB)", 2D) = "black" {}
    }

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardSpecular exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _EmissionTex;
        sampler2D _SpecularTex;


        struct Input {
            float2 uv_MainTex;
            float2 uv_EmissionTex;
            float2 uv_SpecularTex;
        };

        half _Glossiness;
        half _Occlusion;
        fixed4 _Color;
        fixed4 _Emission;
        fixed4 _Specular;

        void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            fixed4 s = tex2D(_SpecularTex, IN.uv_SpecularTex) * _Specular;
            o.Specular = s.rgb;

            o.Emission = _Emission.rbg * tex2D(_EmissionTex, IN.uv_EmissionTex).a;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}
