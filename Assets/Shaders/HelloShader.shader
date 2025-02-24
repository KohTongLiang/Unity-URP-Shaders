Shader "Unlit/HelloShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _ColorStart ("Start Color", Range(0,1)) = 1
        _ColorEnd ("End Color", Range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" // Tagging for post processing effects
            "Queue"="Transparent" // Actual order where things are drawn in
        }
        LOD 100

        Pass
        {
            Blend One One // Additive
//            Blend DstColor Zero // Multiplicative
            ZWrite Off
            ZTest LEqual // GEqual useful for effect where we only want applied on the object, meaning render if depth greater than value in depth buffer
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 normal : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Define macro, we can use the macro to represent certain values etc
            #define TWO 2

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1;
            float4 _Color2;
            float _ColorStart;
            float _ColorEnd;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            // Can change where the gradient starts
            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Make wavy pattern
                float xOffset = cos(i.uv.x * 25) * 0.05;
                float t = abs(frac((i.uv.y + xOffset - _Time.y * 0.25) * 5) * TWO - 1);
                t *= 1 - i.uv.y;

                float topBottomRemover = abs(i.normal.y) < 0.999; // if normals almost up or down multiplied by 0
                float waves = t * topBottomRemover;
                float4 gradient = lerp(_Color1, _Color2, i.uv.y);

                return gradient * waves;

                // float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.y));
                // t = frac(t); // frac returns fractional part of a number, used for repeating patterns or animate textures
                // float4 outColor = lerp(_Color1, _Color2, t);
                // return outColor;
            }
            ENDCG
        }
    }
}