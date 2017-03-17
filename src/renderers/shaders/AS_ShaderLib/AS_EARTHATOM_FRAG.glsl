#include <as_common>

uniform samplerCube tCube;
uniform float _ESun;

uniform vec3 v3LightDir;		// The direction vector to the light source
uniform float fG;				// The Mie phase asymmetry factor
uniform float fG2;				// The Mie phase asymmetry factor squared

varying vec3 vWorldPosition;//? vec3
varying vec2 vUv;
varying vec3 vT0;
varying vec3 vC0;
varying vec3 vC1;

void main() {

	float fCos = dot(v3LightDir, vT0) / length(vT0);
	float fCos2 = fCos*fCos;
	vec3 fColor = getRayleighPhase(fCos2) * vC0 + getMiePhase(fCos, fCos2, fG, fG2) * vC1;

	//Adjust color from HDR
	//fColor.rgb *= SetEV(fHdrExposure);

	gl_FragColor = vec4(fColor, fColor.b);

}

