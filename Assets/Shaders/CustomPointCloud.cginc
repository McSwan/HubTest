#ifndef RW_CUSTOMPOINTCLOUD
#define RW_CUSTOMPOINTCLOUD

/*
* Applies a custom vertex operation to all point clouds.
*/
fixed4 CustomPointCloudVert(VertexInput v)
{
	// Perform any custom processing here.
	return v.color;
}

#endif	