Shader "Ceto/OceanTopSide_Transparent" 
{
	Properties 
	{
		[HideInInspector] _CullFace ("__cf", Float) = 2.0
	}
	SubShader 
	{
		Tags { "OceanMask"="Ceto_ProjectedGrid_Top" "RenderType"="Ceto_ProjectedGrid_Top" "IgnoreProjector"="True" "Queue"="Transparent-1"  }
		LOD 200
		
		GrabPass { "Ceto_RefractionGrab" }
		
		zwrite on
		//cull back

		cull [_CullFace]

		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface OceanSurfTop OceanBRDF exclude_path:prepass alpha novertexlights nolightmap nodynlightmap nodirlightmap nofog nometa noforwardadd nolppv noambient
		#pragma vertex OceanVert
		#pragma target 3.0
						
		//#define CETO_DISABLE_SPECTRUM_SLOPE
		//#define CETO_DISABLE_SPECTRUM_FOAM
		//#define CETO_DISABLE_NORMAL_OVERLAYS
		//#define CETO_DISABLE_FOAM_OVERLAYS
		//#define CETO_DISABLE_EDGE_FADE
		//#define CETO_DISABLE_FOAM_TEXTURE
		
		//#define CETO_BRDF_FRESNEL
		//#define CETO_NICE_BRDF
		#define CETO_OCEAN_TOPSIDE
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















