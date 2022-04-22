Shader "Custom/PolygonColour" {
    Properties{
        _Color("Main Color", Color) = (1,1,1,1)
    }

    SubShader{
        Tags{ "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        LOD 100
        Cull Off
        ZWrite On
        ZTest LEqual
        Offset 0, -5
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf WrapLambert alpha exclude_path:deferred exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv

		half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, -lightDir);
			half diff = NdotL * 0.1 +0.8;
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
			c.a = s.Alpha;
			return c;
		}
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = _Color.rgb;
			o.Emission = half4(0.1, 0.1, 0.1, 0.1);
			o.Alpha = _Color.a;
		}
		ENDCG
    }
    FallBack "Diffuse"
}