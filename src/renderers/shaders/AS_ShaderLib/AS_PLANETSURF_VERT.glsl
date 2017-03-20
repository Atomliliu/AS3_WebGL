#include <as_common>

varying vec3 vWorldPosition;//? vec3
varying vec2 vUv;
varying vec3 vT0;
varying vec3 vT1;
varying vec3 vC0;
varying vec3 vC1;


// vec3
uniform int nSamples;
uniform int nDepthSamples;
uniform vec3 v3Translate;		// The objects world pos
uniform vec3 v3LightDir;		// The direction vector to the light source
uniform vec3 v3InvWavelength; // 1 / pow(wavelength, 4) for the red, green, and blue channels
uniform float fOuterRadius;		// The outer (atmosphere) radius
uniform float fOuterRadius2;	// fOuterRadius^2
uniform float fInnerRadius;		// The inner (planetary) radius
uniform float fInnerRadius2;	// fInnerRadius^2
uniform float fKrESun;			// Kr * ESun
uniform float fKmESun;			// Km * ESun
uniform float fKr4PI;			// Kr * 4 * PI
uniform float fKm4PI;			// Km * 4 * PI
uniform float fScale;			// 1 / (fOuterRadius - fInnerRadius)
uniform float fScaleDepth;		// The scale depth (i.e. the altitude at which the atmosphere's average density is found)
uniform float fScaleOverScaleDepth;	// fScale / fScaleDepth
uniform float fHdrExposure;		// HDR exposure

//vec2 GetDepth(vec3 vP, vec3 vRay, float fF, float fScaleDepth, float fScale, float fR, float fR2, int dSamples)

void main() {
	//Vertx 2 Fragment
	vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
	vWorldPosition = worldPosition.xyz;//? vec3

	vUv = uv;
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );// = pos

	//////////////////////////////////////////////////////////////////////////////

	//vec3 cameraToVertex = normalize( worldPosition.xyz - cameraPosition );

	vec3 v3CameraPos = cameraPosition - v3Translate;	// The camera's current position
	float fCameraHeight = length(v3CameraPos);					// The camera's current height
	float fCameraHeight2 = fCameraHeight*fCameraHeight;			// fCameraHeight^2
	
	// Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere)
	//vec3 v3Pos = mul(_Object2World, v.vertex).xyz - v3Translate;
	vec3 v3Pos = worldPosition.xyz - v3Translate;
	vec3 v3Ray = v3Pos - v3CameraPos;
	float fFar = length(v3Ray);
	v3Ray /= fFar;
	
	// Calculate the closest intersection of the ray with the outer atmosphere (which is the near point of the ray passing through the atmosphere)
	float fNear = getNearIntersection(v3CameraPos, v3Ray, fCameraHeight2, fOuterRadius2);
	float fF = getFarIntersection(v3CameraPos, v3Ray, fCameraHeight2, fOuterRadius2);
				
	bool bCameraAbove = true;
	vec3 v3Start = v3CameraPos;
	vec2 v2CameraDepth=vec2(0,0);
	vec2 v2LightDepth;
	vec2 v2SampleDepth;

	//float fHeight;
	//float fDepth;
	//float fCameraAngle;
	//float fLightAngle;


	if(fNear <= 0.0)//Camera inside atmosphere
	{
		//bCameraInAtmosphere = true;
		float fCameraHeight = length(v3CameraPos);
		bCameraAbove = fCameraHeight >= length(v3Pos);
		v2CameraDepth = GetDepth(v3CameraPos,v3Ray,fF,fScaleDepth, fScale, fInnerRadius, fInnerRadius2, nDepthSamples);
		//vec2 GetDepth(vec3 vP, vec3 vRay, float fF, float fScaleDepth, float fScale, float fR, float fR2, int dSamples)
	}
	else//Camera outside atmosphere
	{
		v3Start = v3CameraPos + v3Ray * fNear; // Move the camera up to the near intersection point
		fFar -= fNear; 
	}

	// If the distance between the points on the ray is negligible, don't bother to calculate anything
	if(fFar <= DELTA)
	{
		vT0=vec3(0);
		vT1=vec3(0);
		vC0=vec3(0);
		vC1=vec3(0);
		return;
	}

	// Surface sample
	float fStartHeight = length(v3Pos);

	float fSampleAngle;
	if(bCameraAbove)
	{
		fSampleAngle = dot(-v3Ray, v3Pos) / vec3(fStartHeight);
	}
	else
	{
		fSampleAngle = dot(v3Ray, v3Pos) / vec3(fStartHeight);
	}
	

	// Initialize the scattering loop variables
	//vec3 v3Sum = vec3(0,0,0);
	float fSampleLength = fFar / float(nSamples);
	float fScaledLength = fSampleLength * fScale;
	vec3 v3SampleRay = v3Ray * vec3(fSampleLength);
	// Start at the center of the first sample ray, and loop through each of the others
	vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;

	// Now loop through the sample rays
	vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
	vec3 v3Attenuate;
	for(int i=0; i<_MaxSample; i++)
	{
		if(i == nSamples) break;
		float fFL = getFarIntersection(v3SamplePoint, v3LightDir, dot(v3SamplePoint,v3SamplePoint), fOuterRadius2);
		v2LightDepth = GetDepth(v3SamplePoint,v3LightDir,fFL,fScaleDepth, fScale, fInnerRadius, fInnerRadius2, nDepthSamples);
		// If no light light reaches this part of the atmosphere, no light is scattered in at this point
		if(v2LightDepth.x < DELTA)
		{
			break;
			//or continue;
		}
		// Get the density at this point, along with the optical depth from the light source to this point
		float fDensity = fScaledLength * v2LightDepth.x;
		float fDepth = v2LightDepth.y;

		// If the camera is above the point we're shading, we calculate the optical depth from the sample point to the camera
		// Otherwise, we calculate the optical depth from the camera to the sample point
		v2SampleDepth = GetDepth(v3SamplePoint, -v3Ray, fF,fScaleDepth, fScale, fInnerRadius, fInnerRadius2, nDepthSamples);
		if(bCameraAbove)
		{
			fDepth += (v2SampleDepth.x - v2CameraDepth.x);
		}
		else
		{
			fDepth += (v2CameraDepth.x - v2SampleDepth.x);
		}

		// Now multiply the optical depth by the attenuation factor for the sample ray
		fDepth *= fKr4PI;

		// Calculate the attenuation factor for the sample ray
		v3Attenuation = exp(vec3(-fDepth.x) * v3InvWavelength - vec3(fDepth.xxx));
		v3FrontColor += vec3(fDensity.x) * v3Attenuation;

		// Move the position to the center of the next sample ray
		v3SamplePoint += v3SampleRay;

	}


	///////////////////////////////////////OUT/////////////////////////////////////
	

	vC0 = v3FrontColor * (v3InvWavelength * vec3(fKrESun) + vec3(fKmESun));

	vC1 = v3Attenuate;//? lerp(vec3(1.0), v3Attenuate, _Ratio);
	vT0 = vec3(1.0);//pow(saturate(dot(v3LightDir, (modelMatrix*vec4(normal,1.0)).xyz)+vec3(0.175)),0.75);


	//Specular
	vec3 h = normalize (v3LightDir + normalize(v3CameraPos - v3Pos));
	float nh = max (0.0, dot (normal, h));
	float spec = 0.0;//pow (nh, _Glossiness * A_SPECPOWER);
	vT1 = vec3(spec);

}


