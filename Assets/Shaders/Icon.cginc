struct FragmentInput
{
	float4 pos : SV_POSITION;
	fixed4 col : COLOR;
	fixed2 uv : TEXCOORD0;
};

struct VertexInput
{
	float4 pos : POSITION;
	fixed4 col: COLOR;
	fixed4 tang : TANGENT;
};

struct VertexOutput
{
	float4 pos : SV_POSITION;
	fixed4 col : COLOR;
	fixed4 tang : TANGENT;
};

uniform sampler2D _MainTex;
uniform float g_CameraAltitude;
uniform int g_ScreenHeight;
uniform float _CameraOrthoSize;
uniform float4 _CameraUp;
uniform float4 _CameraRight;

VertexOutput vert(VertexInput v)
{
	VertexOutput o;
	o.pos = v.pos;				
	o.col = v.col;
	o.tang = v.tang;

	return o;
}

// Geometry Shader -----------------------------------------------------
[maxvertexcount(3)]
void geom(point VertexOutput p[1], inout TriangleStream<FragmentInput> triStream)
{
	if (p[0].col.a == 0.0)
	{
		return;
	}

	float4 clip = p[0].pos;

	float4 up = float4(UNITY_MATRIX_V[1].xyz * 2.0, 0.0);
	float4 right = float4(-UNITY_MATRIX_V[0].xyz * 2.0, 0.0);
	
	float size = p[0].tang.z;
	bool clamped = true;
	bool worldSize = p[0].tang.w > 0.001;
	float maxWorldScale = p[0].tang.w;
	if (size < 0.0)
	{
		clamped = false;
		size = -size;
	}
	
	float4 screenPos = UnityObjectToClipPos(clip);

	FragmentInput pIn1;
	FragmentInput pIn2;
	FragmentInput pIn3;
									
	//Shift icon up so it doesn't clip the terrain		
	if (clamped && !worldSize)
	{
		clip.y = clip.y + size / _ScreenParams.y * screenPos.w * 0.25;
		screenPos = UnityObjectToClipPos(clip);
	}
	
	if (_CameraOrthoSize < 0.0)
	{
		if (worldSize)
		{
			float scaledScreenHeight = g_ScreenHeight * g_ScreenHeight / _ScreenParams.y;
			size = min(size / (scaledScreenHeight * screenPos.w * 0.01), maxWorldScale);
		}
		else
		{
			float viewScale = 0.0 + (g_CameraAltitude + 1.0) / abs(screenPos.w) * 2.0;
			if (viewScale > 1.0)
			{
				viewScale = 1.0;
			}

			size *= viewScale;
		}

		size = size / _ScreenParams.y * screenPos.w * 0.5;
	}
	else
	{
		if (worldSize)
		{
			size = min(size, maxWorldScale);
		}
		size = _CameraOrthoSize / _ScreenParams.y * size;
	}

	
	float2 offset = p[0].tang.xy;
	offset.y = 1.0 - offset.y;
	offset.x = offset.x * 2.0 - 1.0;
	offset.y = offset.y * 2.0 - 2.0;

	clip.xyz = clip.xyz + size * _CameraRight.xyz * offset.x;
	clip.xyz = clip.xyz + size * _CameraUp.xyz * offset.y;

	right *= size;
	up *= size;
	
	pIn2.pos = UnityObjectToClipPos(clip + up * 2);
	pIn1.pos = UnityObjectToClipPos(clip + right);
	pIn3.pos = UnityObjectToClipPos(clip - right);
	
	pIn1.col = p[0].col;
	pIn1.uv = float2(-0.366f, 0.05f);

	pIn2.col = p[0].col;
	pIn2.uv = float2(0.5f, 1.75f);

	pIn3.col = p[0].col;
	pIn3.uv = float2(1.366f, 0.05f);

	triStream.Append(pIn1);
	triStream.Append(pIn2);
	triStream.Append(pIn3);
}