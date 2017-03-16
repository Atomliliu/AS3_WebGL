//#include <as_common>

uniform samplerCube tCube;
uniform float _ESun;

varying vec3 vWorldPosition;//? vec3
varying vec2 vUv;
varying vec3 vT0;
varying vec3 vT1;
varying vec3 vC0;
varying vec3 vC1;


void main() {

	vec4 texSurfCol = vec4(0.0);//tex2D(_MainTex, IN.uv);
	//half4 texCloudCol = tex2D(_CloudTex, float2(IN.uv.x + _CloudUOffset * _Time.x, IN.uv.y));
	vec3 diff = vT0 * vC1 * _ESun;
	vec3 col = vT1 * diff * vec3(0.3);
	//col = IN.c0 + lerp(col.rgb, texCloudCol.rgb * diff, texCloudCol.a);
	col = vC0 + col.rgb ;
	//col = vec3(0.5);
	col = vC1;
	
	gl_FragColor = vec4(col, 1.0);
	//fColor.rgb *= SetEV(fHdrExposure);

}
