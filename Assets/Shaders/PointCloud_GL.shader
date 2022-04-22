Shader "Custom/PointCloud_GL"
{
    /*
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
    }

    SubShader
    {    
        Pass
        {
            
            GLSLPROGRAM

            #pragma multi_compile __ AMBIENT_OCCLUSION
            #pragma multi_compile __ HEIGHT
            #pragma multi_compile __ CULLING

            #ifdef VERTEX

            #include "UnityCG.glslinc"

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
            uniform mat4 _PointClippingBox;
            uniform lowp float _CameraOrthoSize;
            uniform float _PointDistanceThreshold;
            uniform int _PointClippingEnabled;
            uniform vec4 _PointClippingCenter;

            #include "CustomPointCloud_GL.cginc"
            
            void main()
            {
                vec4 clip = gl_Vertex;
                vec4 c = gl_ModelViewProjectionMatrix * clip;
                gl_Position = c;

                if (_CameraOrthoSize < 0.0)
                {
                    float size = _PointSize / _ScreenParams.y;
                    vec4 pos1 = clip + size * _CameraUp;

                    pos1 = gl_ModelViewProjectionMatrix * pos1;
                    float pixelSize = (pos1.y - c.y) / c.w * _ScreenParams.y;

                    gl_PointSize = max(pixelSize, _MinPointSize * 0.5);
                }
                else
                {
                    gl_PointSize = 3.5;
                }

                #if defined(HEIGHT) || defined(CULLING)
                float exposure = 0.001;
                float contrast = 3.8;
                float height = exposure * pow(gl_Normal.x, contrast);
                height = height / (1.0 + height);
                #endif
                
                #if defined(CULLING)
                Color.a = step(height, _MinVisible) * step(_MaxVisible, height);
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

                if (_AmbientOcclusion > 0.0)
                {
                    float ao = (255.0 - gl_Normal.y) / 255.0;
                    Color.rgb -= ao * _AmbientOcclusion * Color.rgb;
                }


                vec4 worldPoint = unity_ObjectToWorld * gl_Vertex;
                vec4 transformedPoint = _PointClippingBox * worldPoint;

                Color.a = step(transformedPoint.x, 1.0) * step(-1.0, transformedPoint.x) * step(transformedPoint.y, 1.0) * step(-1.0, transformedPoint.y) * step(transformedPoint.z, 1.0) * step(-1.0, transformedPoint.z);
                
                if (_PointClippingEnabled == 1)
                {
                    Color.a = step((worldPoint.x - _PointClippingCenter.x) * (worldPoint.x - _PointClippingCenter.x) + (worldPoint.z - _PointClippingCenter.z) * (worldPoint.z - _PointClippingCenter.z), _PointDistanceThreshold * _PointDistanceThreshold);
                }

				gl_PointSize *= Color.a;
            }
           
            #endif
           
            #ifdef FRAGMENT
            
            varying lowp vec4 Color;
           
            void main()
            {
                vec2 coord = gl_PointCoord - vec2(0.5);
                if (coord.x * coord.x + coord.y * coord.y > 0.25 || Color.a == 0.0)
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