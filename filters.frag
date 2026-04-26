#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float srcWidth;
    float srcHeight;
    float f_negatyw;
    float f_krawedzie;
    float f_szum;
    float f_rozmycie_kol;
    float f_pixel_art;
    float f_stary_film;
    float f_cieple_lato;
    float f_progowanie;
    float f_sepia_retro;
    float f_zimna_noc;
} ubuf;
layout(binding = 1) uniform sampler2D source;
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
void main() {
    vec2 uv = qt_TexCoord0;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        discard;
    }
    vec2 res = vec2(1.0 / ubuf.srcWidth, 1.0 / ubuf.srcHeight);
    if (ubuf.f_pixel_art > 0.0) {
        float d = 500.0 - (ubuf.f_pixel_art * 480.0);
        uv = floor(uv * d) / d;
    }
    vec4 tex = texture(source, uv);
    vec3 color = tex.rgb;
    if (ubuf.f_rozmycie_kol > 0.0) {
        float blurDist = ubuf.f_rozmycie_kol * 0.01;
        color += texture(source, clamp(uv + vec2(blurDist, blurDist), 0.0, 1.0)).rgb;
        color += texture(source, clamp(uv + vec2(-blurDist, -blurDist), 0.0, 1.0)).rgb;
        color += texture(source, clamp(uv + vec2(blurDist, -blurDist), 0.0, 1.0)).rgb;
        color += texture(source, clamp(uv + vec2(-blurDist, blurDist), 0.0, 1.0)).rgb;
        color /= 5.0;
    }
    if (ubuf.f_krawedzie > 0.0) {
        vec3 edge = abs(color - texture(source, clamp(uv + vec2(res.x, 0.0), 0.0, 1.0)).rgb);
        edge += abs(color - texture(source, clamp(uv + vec2(0.0, res.y), 0.0, 1.0)).rgb);
        color = mix(color, edge * 2.0, ubuf.f_krawedzie);
    }
    if (ubuf.f_negatyw > 0.0) {
        color = mix(color, 1.0 - color, ubuf.f_negatyw);
    }
    if (ubuf.f_sepia_retro > 0.0) {
        vec3 sepia = vec3(
            dot(color, vec3(0.393, 0.769, 0.189)),
            dot(color, vec3(0.349, 0.686, 0.168)),
            dot(color, vec3(0.272, 0.534, 0.131))
        );
        color = mix(color, sepia, ubuf.f_sepia_retro);
    }
    if (ubuf.f_cieple_lato > 0.0) {
        color.r += ubuf.f_cieple_lato * 0.2;
        color.b -= ubuf.f_cieple_lato * 0.1;
    }
    if (ubuf.f_zimna_noc > 0.0) {
        color.b += ubuf.f_zimna_noc * 0.3;
        color.rg -= ubuf.f_zimna_noc * 0.1;
    }
    if (ubuf.f_progowanie > 0.0) {
        float gray = dot(color, vec3(0.299, 0.587, 0.114));
        float threshold = step(0.6 - (ubuf.f_progowanie * 0.2), gray);
        color = mix(color, vec3(threshold), ubuf.f_progowanie);
    }
    if (ubuf.f_szum > 0.0 || ubuf.f_stary_film > 0.0) {
        float n = (rand(uv) - 0.5) * (ubuf.f_szum + ubuf.f_stary_film);
        color += n;
        if (ubuf.f_stary_film > 0.0) {
            color *= (1.0 - ubuf.f_stary_film * 0.2);
        }
    }

    fragColor = vec4(color, tex.a) * ubuf.qt_Opacity;
}