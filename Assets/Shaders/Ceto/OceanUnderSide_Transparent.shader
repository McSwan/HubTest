Shader "Ceto/OceanUnderSide_Transparent" 
{
	Properties 
	{
		[HideInInspector] _CullFace ("__cf", Float) = 1.0
	}
	SubShader 
	{

		Tags { "OceanMask" = "Ceto_ProjectedGrid_Under" "RenderType" = "Ceto_ProjectedGrid_Under" "IgnoreProjector" = "True" "Queue" = "Transparent-2"  }
		LOD 200

		GrabPass { "Ceto_RefractionGrab" }

		zwrite on
		//cull front

		cull[_CullFace]

		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface OceanSurfUnder OceanBRDF exclude_path:prepass novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv noambient keepalpha
		#pragma vertex OceanVert
		#pragma target 3.0

		//#define CETO_DISABLE_SPECTRUM_SLOPE
		//#define CETO_DISABLE_SPECTRUM_FOAM
		//#define CETO_DISABLE_NORMAL_OVERLAYS
		//#define CETO_DISABLE_FOAM_OVERLAYS
		//#define CETO_DISABLE_EDGE_FADE
		//#define CETO_DISABLE_FOAM_TEXTURE

		//Fast BRDF not working on underside. Must use nice BRDF.
		#define CETO_NICE_BRDF
		#define CETO_OCEAN_UNDERSIDE
		#define CETO_TRANSPARENT_QUEUE

		#include "./OceanShaderHeader.cginc"
		#include "./OceanDisplacement.cginc"
		#include "./OceanBRDF.cginc"
		#include "./OceanUnderWater.cginc"
		#include "./OceanSurfaceShaderBody.cginc"

		ENDCG
	}
	
	FallBack Off
}















