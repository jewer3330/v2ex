﻿Shader "Unlit/VertexReflect"
{
	Properties
	{
		_Cube ("CubeMap", Cube) = ""
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

			samplerCUBE _Cube;
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 worldSpaceViewDir = WorldSpaceViewDir(mul(unity_ObjectToWorld,v.vertex));
				//float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				float3 worldSpaceNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldSpaceReflectPos = reflect(worldSpaceViewDir,worldSpaceNormal);
				o.uv = worldSpaceReflectPos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				// sample the texture
				fixed4 col = texCUBE(_Cube, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
