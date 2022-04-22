#ifndef RW_CUSTOMTERRAIN
#define RW_CUSTOMTERRAIN

uniform float _ContrastFactor;

/*
* Applies a custom fragment operation to any terrain layers
* that are flagged for custom processing.
*/
float4 CustomTerrainFrag(float4 input)
{
	input.rgb = (input.rgb - 0.5) * _ContrastFactor + 0.5;
	return input;
}

#endif