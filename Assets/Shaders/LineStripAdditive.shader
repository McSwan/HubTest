Shader "Custom/LineStripAdditive" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _LineWidth ("Line Width", Range(0.01, 100)) = 2.0
    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue" = "Overlay" }
        LOD 200
 
        Pass {
 
            Cull Off 
            ZWrite Off
            ZTest Off
            Blend SrcAlpha OneMinusSrcAlpha

            Lighting Off
 
            CGPROGRAM
            #pragma glsl_no_auto_normalization
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
 
            float4 _Color;
            float _LineWidth;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            }; 
 
            struct v2f
            {
                float4 pos : POSITION;
            };
 
            v2f vert (a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
               
                float2 aPos = UnityObjectToClipPos(v.vertex).xy;
                float2 aPrevPos = UnityObjectToClipPos(float4(v.normal.xyz, 1.0)).xy;
                float2 aNextPos = UnityObjectToClipPos(float4(v.tangent.xyz, 1.0)).xy;    
                float aOffset = v.texcoord.y;

                float2 deltaNext = aNextPos.xy - aPos.xy;
                float2 deltaPrev = aPos.xy - aPrevPos.xy;
                
                float angleNext = 1.57079632679; // pi*0.5
                if (abs(deltaNext.x) > 0.00001)
                    angleNext = atan(deltaNext.y/deltaNext.x);

                float anglePrev = 1.57079632679; // pi*0.5
                if (abs(deltaPrev.x) > 0.00001)
                    anglePrev = atan(deltaPrev.y/deltaPrev.x);

                if (v.normal.x == 0 && v.normal.y == 0) anglePrev = angleNext;
                if (v.tangent.x == 0 && v.tangent.y == 0) angleNext = anglePrev;

                float ln = length(ObjSpaceViewDir(v.vertex));
                float scale = (_LineWidth * ln * 60) / degrees(_ScreenParams.y);

                float angle = (anglePrev + angleNext) / 2.0;

                float distance = aOffset;

                if (cos(anglePrev - angle) > 0.0001) 
                    distance *= scale / cos(anglePrev - angle);
                else 
                    distance *= scale;

                o.pos.x += distance * sin(angle);
                o.pos.y -= distance * cos(angle);

                return o;

            }
 
            float4 frag(v2f i) : COLOR
            {
                return _Color; 
            }
 
            ENDCG
        }
    }
    FallBack "Diffuse"
}