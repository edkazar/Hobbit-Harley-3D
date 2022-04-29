// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Foliage toon"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.1
		_Maincolor("Main color", Color) = (0.3372549,0.4431373,0.2980392,1)
		_Shadowcolor("Shadow color", Color) = (0.1946179,0.3139887,0.5028866,1)
		[HDR]_RimColor("Rim Color", Color) = (0.4235294,0.6313726,0.1882353,0)
		_RimStr("Rim Str", Range( 0.01 , 5)) = 0.56
		_Rimoffset("Rim offset", Range( -4 , 4)) = 0.65
		_IndirectDiffuseContribution("Indirect Diffuse Contribution", Range( 0 , 1)) = 1
		_BaseCellSharpness("Base Cell Sharpness", Range( 0.01 , 1)) = 0.56
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0.6
		_Wind("Wind", Range( 0 , 0.1)) = 0.02
		_WindNoise("Wind Noise", Float) = 0.4
		_Mask("Mask", 2D) = "gray" {}
		_Shadowcontribution("Shadow contribution", Range( 0.02 , 1)) = 0.5
		_Falloffshadowdistance("Falloff shadow distance", Float) = 0
		_Blendingdistance("Blending distance", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Grass"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		ColorMask RGB
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _WindNoise;
		uniform float _Wind;
		uniform sampler2D _Mask;
		uniform float4 _Maincolor;
		uniform float _IndirectDiffuseContribution;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpness;
		uniform float4 _Shadowcolor;
		uniform float _RimStr;
		uniform float _Rimoffset;
		uniform float4 _RimColor;
		uniform float _Blendingdistance;
		uniform float _Falloffshadowdistance;
		uniform float _Shadowcontribution;
		uniform float _Cutoff = 0.1;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float simplePerlin2D410 = snoise( ( float3( v.texcoord.xy ,  0.0 ) + ( _Time.y * ase_vertex3Pos ) ).xy*_WindNoise );
			simplePerlin2D410 = simplePerlin2D410*0.5 + 0.5;
			float clampResult489 = clamp( ( simplePerlin2D410 * _Wind ) , -2.0 , 2.0 );
			v.vertex.xyz = ( clampResult489 + ase_vertex3Pos );
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float Alpha464 = tex2D( _Mask, i.uv_texcoord ).r;
			float LightType668 = _WorldSpaceLightPos0.w;
			float3 temp_cast_0 = (1.0).xxx;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi72 = gi;
			float3 diffNorm72 = ase_worldNormal;
			gi72 = UnityGI_Base( data, 1, diffNorm72 );
			float3 indirectDiffuse72 = gi72.indirect.diffuse + diffNorm72 * 0.0001;
			float3 lerpResult90 = lerp( temp_cast_0 , indirectDiffuse72 , _IndirectDiffuseContribution);
			float3 WSNormal31 = ase_worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult34 = dot( WSNormal31 , ase_worldlightDir );
			float NdotL36 = dotResult34;
			float3 temp_output_112_0 = ( lerpResult90 + saturate( ( ( NdotL36 + _BaseCellOffset ) / _BaseCellSharpness ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor93 = ase_lightColor;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult49 = dot( WSNormal31 , ase_worldViewDir );
			float saferPower737 = abs( ( distance( ase_worldPos , _WorldSpaceCameraPos ) / _Blendingdistance ) );
			float clampResult671 = clamp( ase_lightAtten , ( ( 1.0 - saturate( pow( saferPower737 , _Falloffshadowdistance ) ) ) * _Shadowcontribution ) , 1.0 );
			float4 lerpResult725 = lerp( _Shadowcolor , ( _Maincolor + float4( ( saturate( ( saturate( NdotL36 ) * (( 1.0 - saturate( dotResult49 ) )*_RimStr + _Rimoffset) ) ) * (_RimColor).rgb ) , 0.0 ) ) , ( float4( temp_output_112_0 , 0.0 ) * clampResult671 * Lightcolor93 ));
			float4 ifLocalVar726 = 0;
			if( LightType668 == 1.0 )
				ifLocalVar726 = ( _Maincolor * float4( temp_output_112_0 , 0.0 ) * Lightcolor93 * ase_lightAtten );
			else if( LightType668 < 1.0 )
				ifLocalVar726 = lerpResult725;
			c.rgb = ifLocalVar726.rgb;
			c.a = 1;
			clip( Alpha464 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
-1067;221;1041;668;13289.54;-2084.208;3.795974;True;False
Node;AmplifyShaderEditor.WorldNormalVector;28;-11655.21,3162.55;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;35;-11360.3,4130.754;Inherit;False;1870.131;522.2462;;15;41;127;47;81;188;720;105;85;829;95;76;691;67;49;830;Rimlight;0.9993406,1,0.759434,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-11313.94,3157.876;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;30;-11639.39,3503.856;Inherit;False;780.9001;289.4;;4;36;34;32;717;NdotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;730;-11051.46,3108.925;Inherit;False;1011.811;339.5486;Distance shadow attenuation;8;738;737;736;734;735;733;732;731;Distance;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;127;-11335.03,4278.897;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;731;-11007.84,3150.901;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;41;-11301.75,4196.753;Inherit;False;31;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;732;-11024.96,3295.364;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;717;-11623.23,3620.012;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;32;-11595.85,3535.046;Inherit;False;31;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;734;-10718.42,3284.267;Inherit;False;Property;_Blendingdistance;Blending distance;14;0;Create;True;0;0;0;False;0;False;2;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;733;-10692.36,3163.724;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-11305.6,3550.845;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;49;-11046.4,4210.91;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-11077.99,3547.228;Float;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-10808.21,4247.951;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;736;-10718.14,3366.374;Inherit;False;Property;_Falloffshadowdistance;Falloff shadow distance;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;735;-10471.92,3163.824;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;37;-10424.85,2456.809;Inherit;False;2354.766;580.6261;;20;728;624;726;724;725;91;672;112;671;62;55;46;52;39;44;743;744;423;740;729;Shadows;0.3568628,0.4007989,0.5490196,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-10813.25,4428.551;Float;False;Property;_RimStr;Rim Str;4;0;Create;True;0;0;0;False;0;False;0.56;5;0.01;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-10628.93,4334.425;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;691;-10590.52,4202.125;Inherit;False;36;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;737;-10340.14,3166.3;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-10371.28,2508.684;Inherit;True;36;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;252;-10335.58,3537.694;Inherit;False;1637.823;503.197;;11;494;820;489;407;248;410;817;406;572;827;828;Wind;0.740566,1,0.9844556,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-10797.66,4534.617;Float;False;Property;_Rimoffset;Rim offset;5;0;Create;True;0;0;0;False;0;False;0.65;-4;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-10390.07,2700.746;Float;False;Property;_BaseCellOffset;Base Cell Offset;8;0;Create;True;0;0;0;False;0;False;0.6;0.3;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;738;-10185.63,3166.027;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-10645.61,2104.683;Inherit;False;626.4547;269.6332;;4;70;72;90;623;Indirect Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;572;-10314.54,3887.844;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;406;-10302.9,3606.163;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;95;-10375.27,4172.63;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;829;-10471.61,4427.17;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-10092.58,2682.553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-10386.26,2796.356;Float;False;Property;_BaseCellSharpness;Base Cell Sharpness;7;0;Create;True;0;0;0;False;0;False;0.56;0.857;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;-10170.21,4474.166;Float;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;0;False;0;False;0.4235294,0.6313726,0.1882353,0;0.424946,0.6320754,0.1878337,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;827;-10079.29,3818.115;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;741;-9994.653,3063.67;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-10616.65,2280.974;Float;False;Property;_IndirectDiffuseContribution;Indirect Diffuse Contribution;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-10157.06,4243.095;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;55;-9959.371,2585.586;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;61;-11655.35,3025.755;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;817;-10084.11,3604.655;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-10596.65,2141.191;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;624;-9841.621,2947.38;Inherit;False;Property;_Shadowcontribution;Shadow contribution;12;0;Create;True;0;0;0;False;0;False;0.5;0.65;0.02;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;72;-10600.15,2214.255;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;828;-9732.232,3582.35;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;740;-9506.515,2930.967;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;720;-9870.966,4475.798;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;90;-10256.69,2150.785;Inherit;True;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-11302.68,3023.644;Inherit;False;Lightcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;494;-9771.057,3751.917;Inherit;False;Property;_WindNoise;Wind Noise;10;0;Create;True;0;0;0;False;0;False;0.4;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;728;-9658.564,2807.979;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;62;-9810.102,2693.318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;830;-9844.377,4245.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;669;-11622.22,3807.154;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;248;-9588.043,3889.103;Inherit;False;Property;_Wind;Wind;9;0;Create;True;0;0;0;False;0;False;0.02;0.07;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;410;-9575.746,3590.03;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-9639.986,2610.658;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;729;-9341.313,2630.935;Inherit;False;93;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-9624.724,4332.835;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;423;-9056.805,2513.441;Inherit;False;Property;_Maincolor;Main color;1;0;Create;True;0;0;0;False;0;False;0.3372549,0.4431373,0.2980392,1;0.4648028,0.6792453,0.3300071,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;671;-9325.56,2900.451;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;745;-8595.682,2128.846;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;743;-8635.432,2689.099;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;407;-9277.152,3594.606;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;668;-11292.04,3825.551;Inherit;False;LightType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;672;-9150.371,2781.455;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;91;-8884.352,2818.893;Inherit;False;Property;_Shadowcolor;Shadow color;2;0;Create;True;0;0;0;False;0;False;0.1946179,0.3139887,0.5028866,1;0.09019449,0.2588216,0.3294098,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;725;-8488.407,2666.825;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;585;-8159.555,2102.793;Inherit;True;Property;_Mask;Mask;11;0;Create;True;0;0;0;False;0;False;-1;None;b6a71755e64b74640a8d8c933d07344e;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;724;-8559.969,2507.655;Inherit;False;668;LightType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;489;-9057.609,3593.75;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;-2;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;-8690.196,2566.647;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenDepthNode;788;-10183.37,1767.658;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;726;-8328.409,2522.825;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT3;0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;792;-9713.825,1877.358;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;790;-10166.15,1874.184;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;789;-10458.94,1770.403;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;820;-8828.451,3920.338;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;791;-9887.222,1846.442;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;795;-9963.967,2332.361;Inherit;False;Property;_MAX;MAX;16;0;Create;True;0;0;0;False;0;False;0;3.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;794;-9984.967,2239.361;Inherit;False;Property;_MIN;MIN;15;0;Create;True;0;0;0;False;0;False;0;3.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;796;-9965.496,2084.268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;798;-9875.564,1752.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;793;-9809.103,2247.352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-3;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;-7828.858,2126.484;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-7540.877,1977.85;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Foliage toon;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;True;False;False;False;False;Off;0;False;-1;0;False;182;False;0;False;-1;0;False;-1;False;0;Custom;0.1;True;True;0;True;Grass;;AlphaTest;All;18;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;3;7.6;0;1.89;False;5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;28;0
WireConnection;733;0;731;0
WireConnection;733;1;732;0
WireConnection;34;0;32;0
WireConnection;34;1;717;0
WireConnection;49;0;41;0
WireConnection;49;1;127;0
WireConnection;36;0;34;0
WireConnection;67;0;49;0
WireConnection;735;0;733;0
WireConnection;735;1;734;0
WireConnection;76;0;67;0
WireConnection;737;0;735;0
WireConnection;737;1;736;0
WireConnection;738;0;737;0
WireConnection;95;0;691;0
WireConnection;829;0;76;0
WireConnection;829;1;81;0
WireConnection;829;2;47;0
WireConnection;52;0;44;0
WireConnection;52;1;39;0
WireConnection;741;0;738;0
WireConnection;105;0;95;0
WireConnection;105;1;829;0
WireConnection;55;0;52;0
WireConnection;55;1;46;0
WireConnection;817;0;406;0
WireConnection;817;1;572;0
WireConnection;828;0;827;0
WireConnection;828;1;817;0
WireConnection;740;0;741;0
WireConnection;740;1;624;0
WireConnection;720;0;85;0
WireConnection;90;0;623;0
WireConnection;90;1;72;0
WireConnection;90;2;70;0
WireConnection;93;0;61;0
WireConnection;62;0;55;0
WireConnection;830;0;105;0
WireConnection;410;0;828;0
WireConnection;410;1;494;0
WireConnection;112;0;90;0
WireConnection;112;1;62;0
WireConnection;188;0;830;0
WireConnection;188;1;720;0
WireConnection;671;0;728;0
WireConnection;671;1;740;0
WireConnection;743;0;423;0
WireConnection;743;1;188;0
WireConnection;407;0;410;0
WireConnection;407;1;248;0
WireConnection;668;0;669;2
WireConnection;672;0;112;0
WireConnection;672;1;671;0
WireConnection;672;2;729;0
WireConnection;725;0;91;0
WireConnection;725;1;743;0
WireConnection;725;2;672;0
WireConnection;585;1;745;0
WireConnection;489;0;407;0
WireConnection;744;0;423;0
WireConnection;744;1;112;0
WireConnection;744;2;729;0
WireConnection;744;3;728;0
WireConnection;788;0;789;0
WireConnection;726;0;724;0
WireConnection;726;3;744;0
WireConnection;726;4;725;0
WireConnection;792;0;798;0
WireConnection;820;0;489;0
WireConnection;820;1;572;0
WireConnection;791;0;788;0
WireConnection;791;1;790;4
WireConnection;796;0;792;0
WireConnection;796;1;49;0
WireConnection;798;0;788;0
WireConnection;798;1;790;4
WireConnection;793;0;796;0
WireConnection;793;1;794;0
WireConnection;793;2;795;0
WireConnection;464;0;585;1
WireConnection;0;10;464;0
WireConnection;0;13;726;0
WireConnection;0;11;820;0
ASEEND*/
//CHKSM=B52069705D9AE46A218824DDA5BC4BD1A460FEE8