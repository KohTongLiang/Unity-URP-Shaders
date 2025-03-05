Shader "Unlit/Textured"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Pattern;
            float4 _MainTex_ST;
            #define TAU 6.28318530718

            // Create wavy patterns that will spread from the center
            float GetWave(float coord)
            {
                float wave = cos((coord - _Time.y * 0.1) * TAU * 5) + 0.5 + 0.5;
                wave *= 1 - coord;
                return wave;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // o.uv.x += _Time.y * 0.1; // Scroll texture
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Using top down projection, it will always be repeated from top down view
                float2 topDownProjection = i.worldPos.xz;
                fixed4 floorCol = tex2D(_MainTex, topDownProjection);
                float4 pattern = tex2D(_Pattern, i.uv).x;

                float4 output = lerp(float4(1, 0, 0, 0.5), floorCol, pattern);

                return output;
            }
            ENDCG
        }
    }
}