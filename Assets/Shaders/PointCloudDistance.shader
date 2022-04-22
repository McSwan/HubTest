Shader "Custom/PointCloudDistance_GL"
{
    /*
    Properties
    {
        _PointSize("PointSize", Float) = 4
        _MinPointSize("MinPointSize", Float) = 2
        _Gradient("Distance Gradient", 2D) = "white" {}
        _MinVisible("Min Visible", Float) = 0.0
        _MaxVisible("Max Visible", Float) = 1.0
        _MinHeight("Min Height", Float) = 0.0
        _MaxHeight("Max Height", Float) = 10.0
    }

    SubShader
    {	
        Pass
        {
            Stencil
            {
                Ref 1
                Comp always
                Pass replace
            }
            
            GLSLPROGRAM

            #pragma multi_compile __ AMBIENT_OCCLUSION
            #pragma multi_compile __ DISTANCE
            #pragma multi_compile __ CULLING

            #ifdef VERTEX

            #include "UnityCG.glslinc"

            varying lowp vec4 Color;
            
            uniform sampler2D _Gradient;
            uniform lowp vec4 _CameraUp;
            uniform lowp float _PointSize;
            uniform lowp float _MinPointSize;
            uniform lowp float _AmbientOcclusion;
            uniform lowp float _MaxDistance;
            
            void main()
            {
                vec4 clip = gl_Vertex;
                float size = _PointSize / _ScreenParams.y;
                vec4 pos1 = clip + size * _CameraUp;

                vec4 c = gl_ModelViewProjectionMatrix * clip;
                pos1 = gl_ModelViewProjectionMatrix * pos1;
                float pixelSize = (pos1.y - c.y) / c.w * _ScreenParams.y;

                gl_Position = c;
                gl_PointSize = max(pixelSize, _MinPointSize * 0.5);

                #if defined(DISTANCE) || defined(CULLING)
                /// TODO calculate distance from line
				float distance = 0;

                #if defined(CULLING)
                if (distance < _MaxDistance)
                {
                    Color = vec4(0.0, 0.0, 0.0, 0.0);
                    return;
                }
                #endif
                #endif

                #if defined(DISTANCE)
				Color = texture2D(_Gradient, vec2(distance, 0.0));
				#else
				Color = texture2D(_Gradient, vec2(1.0, 0.0));
                #endif

                if (_AmbientOcclusion > 0.0 && gl_Normal.y > 0.0)
                {
                    float ao = (255.0 - gl_Normal.y) / 255.0;
                    Color.rgb -= ao * _AmbientOcclusion * Color.rgb;
                }
            }
           
            #endif
           
            #ifdef FRAGMENT
                       
            varying lowp vec4 Color;
           
            void main()
            {
                if (Color.a == 0.0)
                {
                    discard;
                }

                vec2 coord = gl_PointCoord - vec2(0.5);
                if (coord.x * coord.x + coord.y * coord.y > 0.25)
                {
                    discard;
                }
                
                gl_FragColor = Color;
            }
           
            #endif

            ENDGLSL
        }

    }
    */
}