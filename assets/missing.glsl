#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP number speed;
extern MY_HIGHP_OR_MEDIUMP vec4 col1;
extern MY_HIGHP_OR_MEDIUMP vec4 col2;

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	MY_HIGHP_OR_MEDIUMP vec4 ret_col;
	float size = (16*9)/3;
	float total = floor(float((screen_coords.x+(time*speed)) * (1/size))) +
	              floor(float((screen_coords.y-(time*speed)) * (1/size)));
	bool isEven = mod(total, 2.0) == 0.0;
	ret_col = (isEven) ? col1 : col2;
	return ret_col;
}
