Shader "Unlit/BakedSDFBase"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                fixed4 color : COLOR0;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR0;

                half3 vSgMean0: TEXCOORD0;
                half3 vSgMean1: TEXCOORD1;
                half3 vSgMean2: TEXCOORD2;

                half3 vSgScales : TEXCOORD3;
                float3 vDirection : TEXCOORD4;

                half3 vSgColor0 : COLOR1;
                half3 vSgColor1 : COLOR2;
                half3 vSgColor2 : COLOR3;

            };


            float4x4 UNITY_MATRIX_I_VP;

            half3 unpack(in float2 uv, out half3 sgColor, out half sgScale)
            {
                half3 sgMean;
                uint uvx = asuint(uv.x);
                uint uvy = asuint(uv.y);
                sgMean.x = half((uvx) & 0xFF);
                sgMean.y = half((uvx >> 8) & 0xFF);
                sgMean.z = half((uvx >> 16) & 0xFF);
                sgColor.x = half((uvy) & 0xFF);
                sgColor.y = half((uvy >> 8) & 0xFF);
                sgColor.z = half((uvy >> 16) & 0xFF);
                sgMean = sgMean * (2.0 / 255.0) - 1.0;
                sgScale = half((((uvx >> 24) & 0xF) | ((uvy >> 20) & 0xF0)) & 0xFF);
                sgScale = 100.0 * sgScale / 255.0;
                sgColor = sgColor / 255.0;
                return sgMean;
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.color = v.color;
                o.vSgMean0 = unpack(v.uv0, o.vSgColor0, o.vSgScales.x);
                o.vSgMean1 = unpack(v.uv1, o.vSgColor1, o.vSgScales.y);
                o.vSgMean2 = unpack(v.uv2, o.vSgColor2, o.vSgScales.z);
                o.vDirection = WorldSpaceViewDir(v.vertex);
                o.vDirection.zy = o.vDirection.yz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float3 evalSphericalGuassian(float3 direction, float3 mean, float scale, float3 color)
            {
                return color * exp(scale * (dot(direction, mean) - 1.0));
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = pow(i.color, 2.2);
                
                float3 direction = normalize(i.vDirection);
                col.xyz += evalSphericalGuassian(direction, normalize(i.vSgMean0), i.vSgScales.x, i.vSgColor0);
                col.xyz += evalSphericalGuassian(direction, normalize(i.vSgMean1), i.vSgScales.y, i.vSgColor1);
                col.xyz += evalSphericalGuassian(direction, normalize(i.vSgMean2), i.vSgScales.z, i.vSgColor2);
                return col;
            }
            ENDCG
        }
    }
}
