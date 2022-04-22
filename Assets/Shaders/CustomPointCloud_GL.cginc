#ifndef RW_CUSTOMPOINTCLOUD
#define RW_CUSTOMPOINTCLOUD


uniform vec4 _QuadraticCoEfs;
uniform mat4 _TransformationMatrix;

// Remove when Unity.glinc works
float saturate(float x)
{
	return max(0.0, min(1.0, x));
}

/*
* Applies a custom vertex operation to all point clouds.
*/
vec4 CustomPointCloudVert()
{
	// Perform any custom processing here.

	// Catenary distance display
	if (_ColourMode == 3)
	{
		float distance;

		vec4 worldPoint = unity_ObjectToWorld * gl_Vertex;
		vec4 transformedPoint = _TransformationMatrix * worldPoint;

		float x = transformedPoint.x;
		if (_QuadraticCoEfs.x >= 0.0)
			x = -x;
		float y = transformedPoint.y;
		float z = transformedPoint.z;

		distance = dot(vec3(x*x, x, 1.0), vec3(_QuadraticCoEfs.x, _QuadraticCoEfs.y, _QuadraticCoEfs.z));
		distance = 1.0 - saturate(abs(distance - y) * 100.0);
		distance *= 1.0 - saturate(abs(z) * 100.0);

		gl_PointSize = max(_MinPointSize * 0.5, (0.5 + (0.5 * distance)) * gl_PointSize);

		vec4 pointColour = texture2D(_Gradient, vec2(distance, 0.0));

		pointColour *= 1.0 - ((((255.0 - gl_Normal.y) * (1.0 - distance)) / 255.0) * 0.8);

		return pointColour;
	}
	// Greyscale point display
	else if (_ColourMode == 4)
	{
		vec4 myColor = vec4(1.0, 1.0, 1.0, 1.0);
		float aoMultiplier = (255.0 - gl_Normal.y) / 255.0;
		myColor.rgb -= aoMultiplier * myColor.rgb;
		return myColor;
	}

	return gl_Color;
}

#endif