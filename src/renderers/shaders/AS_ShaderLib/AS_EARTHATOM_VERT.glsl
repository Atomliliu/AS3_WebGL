#include <as_common>

varying vec3 vWorldPosition;//? vec3
varying vec2 vUv;
varying vec3 vT0;
//varying vec3 vT1;
varying vec3 vC0;
varying vec3 vC1;


// vec3
//uniform vec3 v3CamPos;
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
uniform float g;				// The Mie phase asymmetry factor
uniform float g2;				// The Mie phase asymmetry factor squared

/*float scale(float fCos, float fScale)
{
	float x = 1.0 - fCos;
	return fScale * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

float getNearIntersection(vec3 v3Pos, vec3 v3Ray, float fDistance2, float fRadius2)
{
	float B = 2.0 * dot(v3Pos, v3Ray);
	float C = fDistance2 - fRadius2;
	float fDet = max(0.0, B*B - 4.0 * C);
	return 0.5 * (-B - sqrt(fDet));
}*/

void main() {
	//Vertx 2 Fragment
	vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
	

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
	vec3 v3Start = v3CameraPos;
	float fHeight;
	float fDepth;
	float fCameraAngle;
	//float fLightAngle;
	float fStartOffset;


	if(fNear <= 0.0)//Camera inside atmosphere
	{
		fHeight = length(v3Start);
		fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fCameraHeight));
		fStartAngle = dot(v3Ray, v3Start) / fHeight;
		fStartOffset = fDepth*scale(fStartAngle,fScaleDepth);
	}
	else//Camera outside atmosphere
	{
		v3Start = v3CameraPos + v3Ray * fNear;
		fFar -= fNear;
		fStartAngle = dot(v3Ray, v3Start) / fOuterRadius;
       	float fStartDepth = exp(-1.0/fScaleDepth);
        fStartOffset = fStartDepth*scale(fStartAngle,fScaleDepth);
	}


	// Calculate the ray's starting position, then calculate its scattering offset
				
	/*float fCameraScale = scale(fCameraAngle,fScaleDepth);
	float fLightScale = scale(fLightAngle,fScaleDepth);
	float fCameraOffset = fDepth*fCameraScale;
	float fTemp = (fLightScale + fCameraScale);*/
	
	const int nSamples = 8;

	// Initialize the scattering loop variables
	float fSampleLength = fFar / float(nSamples);
	float fScaledLength = fSampleLength * fScale;
	vec3 v3SampleRay = v3Ray * vec3(fSampleLength);
	vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;

	// Now loop through the sample rays
	vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
	vec3 v3Attenuate;
	for(int i=0; i<nSamples; i++)
	{
		fHeight = length(v3SamplePoint);
		float fDepth2 = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
		//float fScatter = fDepth2*fTemp - fCameraOffset;
		float fLightAngle = dot(v3LightDir, v3SamplePoint) / fHeight;
		float fCameraAngle = dot(v3Ray, v3SamplePoint) / fHeight;
		float fScatter = (fStartOffset + fDepth2*(scale(fLightAngle,fScaleDepth) - scale(fCameraAngle,fScaleDepth)));
		v3Attenuate = exp(vec3(-fScatter) * (v3InvWavelength * vec3(fKr4PI) + vec3(fKm4PI)));
		v3FrontColor += v3Attenuate * vec3(fDepth2 * fScaledLength);
		v3SamplePoint += v3SampleRay;
	}


	///////////////////////////////////////OUT/////////////////////////////////////
	vWorldPosition = worldPosition.xyz;//? vec3

	vUv = uv;
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );// = pos

	vC0 = v3FrontColor * (v3InvWavelength * fKrESun + fKmESun);

	vC1 = v3Attenuate;//? lerp(vec3(1.0), v3Attenuate, _Ratio);
	vT0 = vec3(1.0);//pow(saturate(dot(v3LightDir, (modelMatrix*vec4(normal,1.0)).xyz)+vec3(0.175)),0.75);


	//Specular
	vec3 h = normalize (v3LightDir + normalize(v3CameraPos - v3Pos));
	float nh = max (0.0, dot (normal, h));
	float spec = 0.0;//pow (nh, _Glossiness * A_SPECPOWER);
	vT1 = vec3(spec);

}


