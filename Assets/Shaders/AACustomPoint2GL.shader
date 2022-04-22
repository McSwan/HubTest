Shader "AACustom/Point2GL"
{
	Properties
	{

		_PointSize("PointSize", Float) = 4
        _MinPointSize("MinPointSize", Float) = 2
        _Gradient("Height Texture", 2D) = "white" {}
        _ClassificationColors("Classification Texture", 2D) = "white" {}
        _MinVisible("Min Visible", Float) = 0.0
        _MaxVisible("Max Visible", Float) = 1.0
        _MinHeight("Min Height", Float) = 0.0
        _MaxHeight("Max Height", Float) = 10.0

        ///////////////////////////////////
        // Remove when UnityCG.glslinc works
        ///////////////////////////////////
        _ScreenParams("ScreenParams", Vector) = (1920.0, 1080.0, 0.0, 0.0)
        ///////////////////////////////////
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
            LOD 200

            GLSLPROGRAM

            #pragma multi_compile __ AMBIENT_OCCLUSION
            #pragma multi_compile __ HEIGHT
            #pragma multi_compile __ CULLING

            #ifdef VERTEX

            //#include "UnityCG.glslinc"

            varying lowp vec4 Color;
            
            uniform int _ColourMode;
            uniform sampler2D _Gradient;
            uniform sampler2D _ClassificationColors;
            uniform lowp vec4 _ClassificationColors_TexelSize;
            uniform lowp vec4 _CameraUp;
            uniform lowp float _PointSize;
            uniform lowp float _MinPointSize;
            uniform lowp float _AmbientOcclusion;
            uniform lowp float _MinVisible;
            uniform lowp float _MaxVisible;
            uniform lowp float _MinHeight;
            uniform lowp float _MaxHeight;

            ///////////////////////////////////
            // Remove when UnityCG.glslinc works
            ///////////////////////////////////
            uniform vec4 _ScreenParams;
            ///////////////////////////////////

			#include "CustomPointCloud_GL.cginc"
            
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
				
                #if defined(HEIGHT) || defined(CULLING)
                float height = gl_Normal.x;
                float heightRange = _MaxHeight - _MinHeight;
                float heightOffset = height - _MinHeight;
                height = heightOffset / heightRange;

                #if defined(CULLING)
                if (height < _MinVisible)
                {
                    Color = vec4(0.0, 0.0, 0.0, 0.0);
                    return;
                }

                if (height > _MaxVisible)
                {
                    Color = vec4(0.0, 0.0, 0.0, 0.0);
                    return;
                }
                #endif
                #endif

                if (_ColourMode == 0)
                {
                    Color = gl_Color;
                }
                #if defined(HEIGHT)
                else if (_ColourMode == 1)
                {
                    Color = texture2D(_Gradient, vec2(height, 0.0));
                }
                #endif
                else if (_ColourMode == 2)
                {
                    Color = texture2D(_ClassificationColors, vec2(gl_Normal.z * _ClassificationColors_TexelSize.x, 0.0));
                }
                else
                {
                    Color = CustomPointCloudVert();
                }

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

        Pass
        {
            Tags{ "LightMode" = "ShadowCaster" }
            ColorMask 0

            GLSLPROGRAM

            #pragma multi_compile __ AMBIENT_OCCLUSION
            #pragma multi_compile __ HEIGHT
            #pragma multi_compile __ CULLING

            #ifdef VERTEX

            //#include "UnityCG.glslinc"

            varying lowp float Alpha;

            uniform int _ColourMode;
            uniform lowp vec4 _CameraUp;
            uniform sampler2D _ClassificationColors;
            uniform lowp vec4 _ClassificationColors_TexelSize;
            uniform lowp float _PointSize;
            uniform lowp float _MinPointSize;
            uniform lowp float _MinVisible;
            uniform lowp float _MaxVisible;
            uniform lowp float _MinHeight;
            uniform lowp float _MaxHeight;

            ///////////////////////////////////
            // Remove when UnityCG.glslinc works
            ///////////////////////////////////
            uniform vec4 _ScreenParams;
            ///////////////////////////////////

            void main()
            {
                vec4 clip = gl_Vertex;
                float size = _PointSize / _ScreenParams.y;
                vec4 pos1 = clip + size * _CameraUp;
                Alpha = 1.0;

                vec4 c = gl_ModelViewProjectionMatrix * clip;
                pos1 = gl_ModelViewProjectionMatrix * pos1;
                float pixelSize = (pos1.y - c.y) / c.w * _ScreenParams.y;

                gl_Position = c;
                gl_PointSize = max(pixelSize, _MinPointSize * 0.5);

                #if defined(HEIGHT) || defined(CULLING)
                float height = gl_Normal.x;
                float heightRange = _MaxHeight - _MinHeight;
                float heightOffset = height - _MinHeight;
                height = heightOffset / heightRange;

                #if defined(CULLING)
                if (height < _MinVisible)
                {
                    Alpha = 0.0;
                    return;
                }

                if (height > _MaxVisible)
                {
                    Alpha = 0.0;
                    return;
                }
                #endif
                #endif

                if (_ColourMode == 2)
                {
                    Alpha = texture2D(_ClassificationColors, vec2(gl_Normal.z * _ClassificationColors_TexelSize.x, 0.0)).a;
                }
            }

            #endif

            #ifdef FRAGMENT

            varying lowp float Alpha;

            void main()
            {
                if (Alpha == 0.0)
                {
                    discard;
                }

                vec2 coord = gl_PointCoord - vec2(0.5);
                if (coord.x * coord.x + coord.y * coord.y > 0.25)
                {
                    discard;
                }
            }

            #endif

            ENDGLSL
        }

	
	}
}