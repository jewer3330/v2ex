Shader "Unlit/VertexRefract1"
{
	Properties
	{
		_RefractRadio("RefractRadio",Range(0,3))= 0
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
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _RefractRadio;
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 worldSpaceViewDir = WorldSpaceViewDir(v.vertex);
				//float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				float3 worldSpaceNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldSpaceReflectPos = refract(-worldSpaceViewDir,worldSpaceNormal,_RefractRadio);
				o.uv = worldSpaceReflectPos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 rgbm = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.uv);
				half3 color = DecodeHDR(rgbm, unity_SpecCube0_HDR);
				return half4(color, 1.0);
			}
			ENDCG
		}
	}
}
