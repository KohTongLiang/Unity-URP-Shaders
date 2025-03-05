Shader "Unlit/VertexOffset"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _ColorStart ("Start Color", Range(0,1)) = 1
        _ColorEnd ("End Color", Range(0,1)) = 0
        _WaveAmp ("Wave Amplitude", Range(0, 10)) = 0.1
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
            #define TAU 6.28318530718

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1;
            float4 _Color2;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmp;


            // Can change where the gradient starts
            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            // Create wavy patterns that will spread from the center
            float GetWave(float2 uv)
            {
                float2 uvsCentered = uv * 2 - 1; // Shifts UV 0,0 to the middle
                float radialDistance = length(uvsCentered); // Get scalar value of coordinates
                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5) + 0.5 + 0.5;
                wave *= 1 - radialDistance;
                return wave;
            }

            v2f vert(appdata v)
            {
                v2f o;

                // Offset vertex y position to create waves
                float wave = cos((v.uv.y - _Time.y * 0.1) * TAU * 5);
                // v.vertex.y = wave * _WaveAmp;
                v.vertex.y = GetWave(v.uv) * _WaveAmp;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // float wave = cos((i.uv.y - _Time.y * 0.1) * TAU * 5) + 0.5 + 0.5;
                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}