#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP number speed;
extern MY_HIGHP_OR_MEDIUMP number size;

vec4 effect( vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords )
{
	// Pixel coordinates from -1 to 1 (height)
	MY_HIGHP_OR_MEDIUMP vec2 uv = (2. * screenCoords - love_ScreenSize.xy) / love_ScreenSize.y;
	MY_HIGHP_OR_MEDIUMP vec3 retCol = vec3(0);
	MY_HIGHP_OR_MEDIUMP float localTime = time * speed;
	MY_HIGHP_OR_MEDIUMP float baseSize = size + sin(localTime);
	const MY_HIGHP_OR_MEDIUMP float layersCounts = 20.;
	for ( MY_HIGHP_OR_MEDIUMP float layer =  0; layer < layersCounts; layer++)
	{
		MY_HIGHP_OR_MEDIUMP float  layerNorm = layer/layersCounts;
		MY_HIGHP_OR_MEDIUMP float layerSize = mix(baseSize, 0.5, layerNorm);
		MY_HIGHP_OR_MEDIUMP float layerSpeed = localTime + layerNorm;
		MY_HIGHP_OR_MEDIUMP vec2 distorted;
		//through experimentation will lead to such a distortion
		distorted.x = uv.x + cos(uv.y * layerSize + layerSpeed);
		distorted.y = uv.y + sin(uv.x * layerSize + layerSpeed);
		MY_HIGHP_OR_MEDIUMP float dist = length(distorted);
		MY_HIGHP_OR_MEDIUMP vec3 wave = cos(dist + vec3(
			1.0 + cos(layerSpeed),
			1.0 + sin(layerSpeed),
			1.0 + cos(layerSpeed + 3.14159)
		));
		vec3 layerColor = 0.001 / (0.5 + 0.5 * wave);//make color "neony"
		retCol += clamp(layerColor, 0., 1.) / (layer + 1.0);//layering layers(maslo maslenoe)
	}
	retCol = pow(retCol, vec3(1.2));
	MY_HIGHP_OR_MEDIUMP  float vignette = 1.0 - 0.5 * length(uv);
	retCol *= vignette;

	// Output to screen
	return vec4(retCol, 1.);
}
