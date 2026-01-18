#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define HPMP highp
#else
	#define HPMP mediump
#endif

#define PI 3.141592653589793f
#define LAYERS_COUNT 20.f

extern HPMP number time;
extern HPMP number speed;
extern HPMP number size;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords)
{
	// Pixel coordinates from -1 to 1 (height)
	HPMP vec2 uv = (2. * screenCoords - love_ScreenSize.xy) / love_ScreenSize.y;
	HPMP vec3 retCol = vec3(0.);
	HPMP float localTime = time * speed;
	HPMP float baseSize = size + sin(localTime);
	for (HPMP float layer = 0.; layer < LAYERS_COUNT; layer++)
	{
		HPMP float layerNorm = layer/LAYERS_COUNT;
		HPMP float layerSize = mix(baseSize, 0.5, layerNorm);
		HPMP float layerSpeed = localTime + layerNorm;
		HPMP vec2 distorted;
		// Through experimentation will lead to such a distortion
		distorted.x = uv.x + cos(uv.y * layerSize + layerSpeed);
		distorted.y = uv.y + sin(uv.x * layerSize + layerSpeed);
		HPMP float dist = length(distorted);
		HPMP vec3 wave = cos(dist + vec3(
			1. + cos(layerSpeed),
			1. + cos(layerSpeed - 2.*PI/3.),
			1. + cos(layerSpeed + 2.*PI/3.)
		));
		vec3 layerColor = 0.001 / (0.5 + 0.5 * wave); // Make color "neony"
		retCol += clamp(layerColor, 0., 1.) / (layer + 1.); // Layering layers (maslo maslenoe)
	}
	retCol = pow(retCol, vec3(1.2));
	HPMP float vignette = 1. - 0.5 * length(uv);
	retCol *= vignette;

	// Output to screen
	return vec4(retCol, 1.);
}
