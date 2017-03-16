//Texture coordination (0,0) is bottom left

#define SC_PI		3.14159265358 
#define SC_1D_PI		0.31830988618 

#define SC_1D6		0.166666666667 
#define SC_2D6		0.333333333333 
#define SC_3D6		0.5
#define SC_4D6		0.666666666667
#define SC_5D6		0.833333333333

#define SC_3D4		0.75


//const int SC_HC_FaceX[4] = int[4](1,4,0,5);
//const int SC_HC_FaceY[3] = int[3](2,4,3);

highp float steps[5];// = {0,1,2,3,4};

////////////////////////////////////////////////////////////////////////////

vec3 getVec(vec2 UV, int face){

    highp vec3 VEC;
    UV.x = UV.x * 2.0 - 1.0; // Range to -1 to 1
    UV.y = UV.y * 2.0 - 1.0; // Range to -1 to 1

    if(face == 0){ //PositiveX	 Right facing side (+x).
		VEC = vec3(1.0,UV.y,-UV.x);
	}

	else if(face == 1){ //NegativeX	 Left facing side (-x).
		VEC = vec3(-1.0,UV.y,UV.x);
	}

	else if(face == 2){ //PositiveY	 Upwards facing side (+y).
		VEC = vec3(UV.x,1.0,-UV.y);
	}

	else if(face == 3){ //NegativeY	 Downward facing side (-y).
		VEC = vec3(UV.x,-1.0,UV.y);
	}

	else if(face == 4){ //PositiveZ	 Forward facing side (+z).
		VEC = vec3(UV.x,UV.y,1.0);
	}

	else if(face == 5){ //NegativeZ	 Backward facing side (-z).
		VEC = vec3(-UV.x,UV.y,-1.0);
	}

	else{
		VEC = vec3(0.0,0.0,1.0);
	}

    return normalize(VEC);
}


//Horizon Linear CubeMap
vec3 getVecHorizonCubeMap(vec2 UV){
	vec2 UV2 = UV;
	//UV2.x = clamp(UV2.x,0.0,1.0);
	//UV2.y = clamp(UV2.y,0.0,1.0);
	UV2 = clamp(UV2,0.0,1.0);
	UV2.x *= 6.0;
	float face = floor(UV2.x);

	UV2.x = clamp(UV2.x - face,0.0,1.0);
	return getVec(UV2,int(face));
	
}

//Vertical Linear CubeMap
vec3 getVecVerticalCubeMap(vec2 UV){
	vec2 UV2 = UV;
	UV2 = clamp(UV2,0.0,1.0);
	UV2.y *= 6.0;
	float face = floor(UV2.y);

	UV2.y = clamp(UV2.y - face,0.0,1.0);
	return getVec(UV2,int(face));
}

//Horizon Cross CubeMap
vec3 getVecHCrossCubeMap(vec2 UV){
	//int SC_HC_FaceX[4];// = {1,4,0,5};
	//const int SC_HC_FaceY[3] = int[3](2,4,3);
	vec2 UV2 = UV;
	UV2 = clamp(UV2,0.0,1.0);

	UV2.x *= 4.0;
	UV2.y *= 3.0;

	float faceX = floor(UV2.x);
	float faceY = floor(UV2.y);

	UV2.x = clamp(UV2.x - faceX,0.0,1.0);
	UV2.y = clamp(UV2.y - faceY,0.0,1.0);

	if (faceX == 0.0 && faceY == 1.0) {
		return getVec(UV2,1);
	}
	else if (faceX == 1.0) {
		if (faceY == 0.0) {
			return getVec(UV2,3);
		}
		else if (faceY == 2.0) {
			return getVec(UV2,2);
		}
		else {
			return getVec(UV2,4);
		}
		//return getVec(UV2,SC_HC_FaceY[faceY]);
		//return vec3(0,0,0);
	}
	else if (faceX == 2.0 && faceY == 1.0) {
		return getVec(UV2,0);
	}
	else if (faceX == 3.0 && faceY == 1.0) {
		return getVec(UV2,5);
	}

	return vec3(0.0,0.0,0.0);
}

//Vertical Cross CubeMap
vec3 getVecVCrossCubeMap(vec2 UV){
	vec2 UV2 = UV;
	UV2 = clamp(UV2,0.0,1.0);

	UV2.x *= 3.0;
	UV2.y *= 4.0;

	float faceX = floor(UV2.x);
	float faceY = floor(UV2.y);

	UV2.x = clamp(UV2.x - faceX,0.0,1.0);
	UV2.y = clamp(UV2.y - faceY,0.0,1.0);

	if (faceX == 0.0 && faceY == 2.0) {
		return getVec(UV2,1);
	}
	else if (faceX == 1.0) {
		if (faceY == 0.0) {
			return getVec(UV2,5);
		}
		else if (faceY == 1.0) {
			return getVec(UV2,3);
		}
		else if (faceY == 2.0) {
			return getVec(UV2,4);
		}
		else {
			return getVec(UV2,2);
		}
		//return getVec(UV2,SC_HC_FaceY[faceY]);
		//return vec3(0,0,0);
	}
	else if (faceX == 2.0 && faceY == 2.0) {
		return getVec(UV2,0);
	}

	return vec3(0.0,0.0,0.0);

}

//LL CubeMap
vec3 getVecLLCubeMap(vec2 UV){
	return vec3(0,0,0);

}

//LP CubeMap
vec3 getVecLPCubeMap(vec2 UV){
	return vec3(0,0,0);

}

vec3 getVecDPCubeMap(vec2 UV){
	return vec3(0,0,0);

}

vec3 getVecSPCubeMap(vec2 UV){
	return vec3(0,0,0);

}


vec2 getLLMapping_VEC2UV(vec3 vec) //Use for create LP map",
{
	vec2 UV;

	UV.y = acos(-vec.y) * SC_1D_PI; // y = 1 to -1, v = 0 to PI,

	float P = abs(vec.x/vec.z);
	//float O = 0.0f;

	if (vec.x >= 0.0) {
		if(vec.z == 0.0) {
			UV.x = 0.5;
		}
		else if(vec.z < 0.0) {
			UV.x = (SC_PI - atan(P)) * SC_1D_PI;
		}
		else {
			UV.x = atan(P) * SC_1D_PI;
		}

	}
	else { // X < 0  //phase
		if(vec.z == 0.0) {
			UV.x = -0.5;
		}
		else if(vec.z < 0.0) {
			UV.x = -(SC_PI - atan(P)) * SC_1D_PI;
		}
		else {
			UV.x = -atan(P) * SC_1D_PI;
		}
	}

	UV.x = (UV.x + 1.0) * 0.5;

	return vec2(UV);
}



vec2 getLPMapping_VEC2UV(vec3 vec) //Use for create LP map
{
	vec2 UV;
	float  th, la, lr, L, P;

	//UV = UV * 2 - 1; // Range to -1 to 1

	if(vec.z == 1.0){
		UV.x = UV.y = 0.0;
	}

	else {
		th = sqrt(vec.x * vec.x + vec.y * vec.y);
		if(vec.z < 0.0) {
			la = asin(th);
			lr = (SC_PI - la) * SC_1D_PI;
			UV.y = lr * (vec.y / th);
			UV.x = lr * (vec.x / th);
		}

		else{
			la = asin(th);
			lr = la * SC_1D_PI;
			UV.y = lr * (vec.y / th);
			UV.x = lr* (vec.x / th);
		}
		
		//lr = pow(L * L + P * P, 0.5f); 
	}

	//From -1 to 1 move to 0 to 1 range
	UV = (UV + 1.0) * 0.5;

	//if(mode > 0.9){ //sky to cube
	//	UV.x = (1.0 - UV.x);
	//}

	return UV;
}



vec2 getDPUVByVec(vec3 vec)
{
	vec2 uv;
	if(vec.z < 0.0){ // Front
		uv = vec.xy/(1.0 - vec.z);
		uv = (uv + 1.0) * 0.5; // Range from -1 to 1 to 0 to 1
		uv.x *= 0.5; // Move to left in texture
	}
	else{ // Back
		vec.y = -vec.y;
		uv = - vec.xy/(1.0 + vec.z);
		uv = (uv + 1.0) * 0.5; // Range from -1 to 1 to 0 to 1
		//uv.y = -uv.y;
		uv.x = (uv.x * 0.5) + 0.5; // Move to right in texture
	}

	return uv;
}


vec3 getVecByDPUV(vec2 uv){
	float A;
	vec3 vec;
	if(uv.x < 0.5){
		uv.x = uv.x * 2.0;
		uv = uv * 2.0 - 1.0; // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)
		uv *= 1.2;
		A = uv.x * uv.x + uv.y * uv.y + 1.0;
		vec = vec3(2.0*uv.x,2.0*uv.y,(A-2.0)); // -1+s^2+t^2 = A-2
		return (vec/A);
	}
	else {
		uv.x = uv.x * 2.0 - 1.0;

		uv = uv * 2.0 - 1.0; // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)
		uv *= 1.2;
		A = uv.x * uv.x + uv.y * uv.y + 1.0;
		vec = vec3(2.0*uv.x,-2.0*uv.y,(A-2.0)); // -1+s^2+t^2 = A-2
		return (-vec/A);
	}
}



vec3 DecodeRGBM(vec4 rgbm, float maxRange, float lum)
{
	return rgbm.rgb * (rgbm.a * maxRange) * lum;
}



vec4 EncodeRGBM(vec3 rgb, float maxRange)
{
    float maxRGB = max(rgb.x,max(rgb.g,rgb.b));
    float M = maxRGB / maxRange;
    M = ceil(M * 255.0) / 255.0;
    return vec4(rgb / (M * maxRange), M);
}




//Atmosphere Function Libs 
//////////////////////////

// The scale equation calculated by Vernier's Graphical Analysis
float scale(float fCos, float fScale)
{
	float x = 1.0 - fCos;
	return fScale * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

// Calculates the Mie phase function
float getMiePhase(float fCos, float fCos2, float g, float g2)
{
	return 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos2) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);
}

// Calculates the Rayleigh phase function
float getRayleighPhase(float fCos2)
{
	return 0.75 + 0.75 * fCos2;
}

float getAltitude(float sampleHeight, float radius, float scaleHeight, float scale){
	float alt = (sampleHeight - radius) * scale;
	//alt = max(alt, 0.0f);
	return max(exp(-alt / scaleHeight), 0.0);
} 

// Returns the near intersection point of a line and a sphere
float getNearIntersection(vec3 v3Pos, vec3 v3Ray, float fDistance2, float fRadius2)
{
	float B = 2.0 * dot(v3Pos, v3Ray);
	float C = fDistance2 - fRadius2;
	float fDet = max(0.0, B*B - 4.0 * C);
	return 0.5 * (-B - sqrt(fDet));
}

// Returns the far intersection point of a line and a sphere
float getFarIntersection(vec3 v3Pos, vec3 v3Ray, float fDistance2, float fRadius2)
{
	float B = 2.0 * dot(v3Pos, v3Ray);
	float C = fDistance2 - fRadius2;
	float fDet = max(0.0, B*B - 4.0 * C);
	return 0.5 * (-B + sqrt(fDet));
}

vec3 getIntersection(vec3 v3Pos, vec3 v3Ray, float fDistance2, float fRadius2)
{

	float B = 2.0 * dot(v3Pos, v3Ray);
	float C = fDistance2 - fRadius2;
	float fDet = B*B - 4.0 * C;
	bool bVisible = (fDet < 0.0 || (0.5 * (-B - sqrt(fDet)) <= 0.0) && (0.5 * (-B + sqrt(fDet)) <= 0.0));

	return vec3(fDet, (0.5 * (-B - sqrt(fDet))), (0.5 * (-B + sqrt(fDet))) );

}


//#ifndef D_BIT
#define D_BIT		0.0039215686274509803921568627451
//#endif

//#ifndef D_BIT2
#define D_BIT2		1.5378700499807766243752402921953e-5
//#endif

//#ifndef D_BIT3
#define D_BIT3		6.0308629411010848014715305576287e-8
//#endif

//#ifndef DELTA
#define DELTA		1e-6f
//#endif


float DecodeRGBA2Float(vec4 vColor, float fMax)
{
	//const float fromFixed = 256.0f/255.0f;
	vec4 vBitShift = vec4(D_BIT3, D_BIT2, D_BIT, 1.0);
	vec4 vCol = vColor;// * fromFixed;
	float fVal = dot(vCol, vBitShift);
	fVal = (fVal >= 0.999999) ? 1.0 : fVal ;
	fVal *= fMax; // Scale float back to correct range

	return fVal;
}


float Saturation(vec3 v3Rgb)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    float intensity = dot(v3Rgb, W);
    //return mix(intensity, rgb, adjustment);
    return intensity;
}

float SetEV(float fEV){
	return pow(0.5,fEV);
}
