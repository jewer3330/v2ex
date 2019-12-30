Shader "Hidden/UVClip"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value("Value",Range(0,2)) = 0
        _Start("Start",Range(0,1)) = 0.5
        _AlphaWidth("AlphaWidth",Range(0,0.5)) = 0.2
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Value;
            float _Start;
            float _AlphaWidth;
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float v = abs(i.uv.x - _Start) * 2;
                if(v > _Value)
                {
                    float alpha = 1 - (v - _Value)/_AlphaWidth;
                    return fixed4(col.rgb,alpha);
                }
                return col;
            }
            ENDCG
        }
    }
}
