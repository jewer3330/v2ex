Shader "Lighting/BlinnOrPhong"
{
	Properties
	{
		_Power ("Power", Range(1,256)) = 2
        [Toggle]_EnableBlinn("EnableBlinn",float) = 0
        [NoScaleOffset]_Specular ("Specular", 2D) = "white"{}
        [NoScaleOffset]_Reflect ("Reflect", 2D) = "white"{}
        
        [Toggle]_EnablePBR("EnablePBR",float) = 0
       
        //_Albedo ("Albedo", Color) = (1,1,1,1)
        [NoScaleOffset]_Albedo ("Albedo", 2D) = "white"{}
        [NoScaleOffset]_NoramlMap ("NormalMap", 2D) = "bump"{}
        [NoScaleOffset]_AO ("AO", 2D) = "white"{}
        [NoScaleOffset]_Roughness("Roughness",2D) = "white"{}
        [NoScaleOffset]_Metallic ("Metallic", 2D) = "white"{}
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
            #include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
                float4 m_pos : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 m_pos : TEXCOORD1;
                float3x3 tbn : TEXCOORD2;
                
			};

            float _Power;
           
            bool _EnableBlinn;
            sampler _Specular;
            sampler _Reflect;
            
            bool _EnablePBR;
            sampler _Albedo;
            sampler _NoramlMap;
            sampler _AO;
            sampler _Roughness;
            sampler _Metallic;


            inline float3x3 getTBN (float3 normal, float4 tangent) {
                float3 wNormal = UnityObjectToWorldNormal(normal);        // 将法线从对象空间转换到世界空间
                float3 wTangent = UnityObjectToWorldDir(tangent.xyz);     // 将切线从对象空间转换到世界空间
                float3 wBitangent = normalize(cross(wNormal, wTangent));  // 根据世界空间下的法线，切线，叉乘算出世界空间下的副切线
                return float3x3(wTangent, wBitangent, wNormal);           // 根据世界空间下的法线，切线，副切线，组合成TBN，可将切线空间下的法线转换到世界空间下
            }
    


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.normal = v.normal;
                o.m_pos = v.vertex;
                o.tbn = getTBN(v.normal,v.tangent);
				return o;
			}
			
            //NDF 法线分布函数，主要用于镜面反射
            //H为半程向量，即入射光方向和观察方向的一半
            float D_GGX_TR(float3 N, float3 H, float a)
            {
                float a2     = a*a;
                float NdotH  = max(dot(N, H), 0.0);
                float NdotH2 = NdotH*NdotH;

                float nom    = a2;
                float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
                denom        = UNITY_PI * denom * denom;

                return nom / denom;
            }

            //DFG 中的 Geo 微平面函数模型
            
            float GeometrySchlickGGX(float NdotV, float roughness)
            {
                float nom   = NdotV;
                float denom = NdotV * (1.0 - roughness) + roughness;

                return nom / denom;
            }

            float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                float ggx1 = GeometrySchlickGGX(NdotV, roughness);
                float ggx2 = GeometrySchlickGGX(NdotL, roughness);

                return ggx1 * ggx2;
            }

            //菲涅尔方程
            float3 fresnelSchlick(float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }

			fixed4 frag (v2f i) : SV_Target
			{
                // sample the texture
                fixed4 albedo = tex2D(_Albedo, i.uv);
				fixed4 spec = tex2D(_Specular, i.uv);
                fixed4 ao = tex2D(_AO, i.uv);
                float roughness = tex2D(_Roughness, i.uv).r;
                float3 matallic = tex2D(_Metallic, i.uv).rgb;
                float relf = tex2D(_Reflect,i.uv).r;
                //fixed4  metallic= tex2D(_Albedo, i.uv);
                //fixed4  albedo= tex2D(_Metallic, i.uv);
                float3  normal = UnpackNormal(tex2D(_NoramlMap, i.uv));

                float3  worldSpaceNormal = mul(normal,i.tbn);

                //float3 worldPos = mul(unity_ObjectToWorld,i.m_pos).xyz;

                //float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                //float3 worldSpaceNormal = normalize(UnityObjectToWorldNormal(i.normal));
                


                // 漫反射 dot( normal , light) worldsapce
                float3 worldSpaceLightDir =  WorldSpaceLightDir(i.m_pos);
                fixed3 diffuse = max(0,dot(worldSpaceNormal,worldSpaceLightDir)) * albedo.rgb;
                float3 worldSpaceViewDir = normalize(WorldSpaceViewDir(i.m_pos));
                
                float3 worldSpaceReflectPos = reflect(-worldSpaceViewDir,worldSpaceNormal);
                
                //return relf;

                half4 rgbm = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldSpaceReflectPos);
                half3 reflect_col = DecodeHDR(rgbm, unity_SpecCube0_HDR)  * relf;
                //return fixed4(reflect_col,1);
                float3 specular = 0;
                float3 Lo = 0;
                //Phong 高光反射 eyedirection  light_reflect_dirction 的夹角 worldspace
                if(!_EnableBlinn)
                {
                    float3 worldSpaceLightReflectDir = reflect(-worldSpaceLightDir,worldSpaceNormal);
                    specular = pow(max(0,dot(worldSpaceViewDir,worldSpaceLightReflectDir)),_Power) * spec.rgb;
                }
                //Blinn Phong 是 dot(eyedirction + lightdir,normal) worldspace 
                else
                {
                    float3 h = normalize( worldSpaceViewDir + worldSpaceLightDir);
                    if(!_EnablePBR)
                    {
                        specular = pow(max(0,dot(worldSpaceNormal,h)),_Power) * matallic;
                    }
                    else
                    {
                        //对所有的关进行遍历，这里只有一个平行光
                        float3 F0 = 0.04; 
                        F0      = lerp(F0, albedo.rgb, matallic);
                        
                        float3 N = worldSpaceNormal;
                        float3 H = h;
                        float3 L = worldSpaceLightDir;
                        float3 V = worldSpaceViewDir;

                        //由于是平行光，没有衰减因子 
                        //float distance    = length(lightPositions[i] - WorldPos);
                        //float attenuation = 1.0 / (distance * distance);

                       
                        //灯光的颜色
                        float3 radiance     = _LightColor0.rgb;        

                        // cook-torrance brdf
                        float3 F  = fresnelSchlick(max(dot(H, V), 0.0), F0);
                        //DGF
                        float NDF =  D_GGX_TR(N,H,roughness);
                        //G
                        float G =  GeometrySmith(N,V,L,roughness);


                        float3 kS = F;
                        float3 kD = 1 - kS;
                        kD *= 1.0 - matallic;     

                        float3 nominator    = NDF * G * F;
                        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; 
                        specular     = nominator / denominator;
                        //return fixed4(specular ,1);;
                        // add to outgoing radiance Lo
                        float NdotL = max(dot(N, L), 0.0);                
                        Lo += (kD * albedo/ UNITY_PI + specular + reflect_col * kS) * radiance * NdotL; 
                    }
                }
                if(!_EnablePBR)
                {
                    //固有色
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    return fixed4(specular + diffuse + ambient + reflect_col ,1);
                }
                else
                {
                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo * ao;
                    float3 color = ambient + Lo;
                    return fixed4(color ,1);
                }
                
			}
			ENDCG
		}
	}
}
