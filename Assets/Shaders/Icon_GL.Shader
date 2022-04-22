Shader "Custom/Icon_GL"
{
	Properties
	{
		_MainTex("Texture Image", 2D) = "white" {}
		_ZTestOff("Z-Test", int) = 4
		
		///////////////////////////////////
		// Remove when UnityCG.glslinc works
		///////////////////////////////////
		_ScreenParams("ScreenParams", Vector) = (1920.0, 1080.0, 0.0, 0.0) 
		///////////////////////////////////
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent-500" }

		Pass
		{
			ZWrite On
			ColorMask 0
			ZTest [_ZTestOff]

			GLSLPROGRAM

			#define FIRSTPASS
			#include "Icon.glslinc"

			ENDGLSL
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTestOff]

			GLSLPROGRAM

			#include "Icon.glslinc"

			ENDGLSL
		}
	}
}