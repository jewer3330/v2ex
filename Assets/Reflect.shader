Shader "Unlit/Reflect"
{
	Properties
	{
		_Cube ("CubeMap", Cube) = ""{}
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
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			samplerCUBE _Cube;
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.uv = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldSpaceViewDir = WorldSpaceViewDir(i.uv);
				//float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				float3 worldSpaceNormal = UnityObjectToWorldNormal(i.normal);
				float3 worldSpaceReflectPos = reflect(worldSpaceViewDir,worldSpaceNormal);
				// sample the texture
				fixed4 col = texCUBE(_Cube, worldSpaceReflectPos);
				half3 color = DecodeHDR(col, unity_SpecCube0_HDR);
				return float4(color,1);
			}
			ENDCG
		}
	}
}
