Shader "Custom/Billboard" 
{
    Properties
	{
        _MainTex("Texture", 2D) = "white" {}
        _alpha("Transparency", Float) = 1
        [MaterialToggle] _billboard("Billboard", Float) = 0
    }

    SubShader
	{
        Tags { "Queue" = "Overlay" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
		{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t 
		{
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
			{
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _billboard;
            uniform float _alpha;

            v2f vert(appdata_t v)
            {
                v2f o;

                float4 billVertex = mul(UNITY_MATRIX_P, (float4(UnityObjectToViewPos(float3(0, 0, 0)), 1.0) + float4(v.vertex.xzy, 0.0)));
                float4 nonBillVertex = UnityObjectToClipPos(v.vertex);
                o.vertex = billVertex * _billboard + nonBillVertex * (1 - _billboard); //Essentially a boolean if/else
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                col.a *= _alpha;
                return col;
            }
            ENDCG
        }
    }
}