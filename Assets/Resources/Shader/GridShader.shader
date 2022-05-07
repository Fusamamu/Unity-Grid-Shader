Shader "Unlit/GridShader"
{
    Properties
    {
         _Scale("Scale", Float) = 1.0
         
        _XAxisRotation  ("Rotation", Float)   = 0.0
        _YAxisRotation  ("Y Rotation", Float) = 0.0
        
        _Thickness              ("Lines Thickness"         ,  Range(0.0001, 0.5)) = 0.005
        _SecondaryLineThickness ("Secondary Line Thickness",  Range(0.0001, 0.5)) = 0.005
        
        _PrimaryInterval   ("Primary Interval",   Int) = 5
        _SecondaryInterval ("Secondary Interval", Int) = 50
        
        _MainLineColor     ("Main Line Color"     , Color) = (1.0, 1.0, 1.0)
        _SecondaryLineColor("Secondary Line Color", Color) = (1.0, 1.0, 1.0)
        _MainColor         ("Main Color"          , Color) = (1.0, 1.0, 1.0)
        
        _MainTex           ("Texture"   , 2D   ) = "white" {}
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
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0  ;
            };

            float _Scale;

            float _XAxisRotation;
            float _YAxisRotation;

            float     _Thickness ;
            float     _SecondaryLineThickness;

            int _PrimaryInterval;
            int _SecondaryInterval;
            
            fixed4    _MainLineColor ;
            fixed4    _SecondaryLineColor;
            fixed4    _MainColor ;
            sampler2D _MainTex   ;
            float4    _MainTex_ST;

            float2 RotateMatrix(float2 pos, float rotation)
            {
                const float PI = 3.14159;
                float angle = rotation * PI * 2 * -1;

                float s = sin(angle);
                float c = cos(angle);

                float2x2 rotationMat = float2x2(c, s, -s, c);

                float2 newPos = mul(rotationMat, pos);

                return newPos;
            }

            float Union(float shape1, float shape2)
            {
                return min(shape1, shape2);
            }

            // Remap value from a range to another
            float Remap(float _value, float _from1, float _to1, float _from2, float _to2)
            {
                return (_value - _from1) / (_to1 - _from1) * (_to2 - _from2) + _from2;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 _pos;
                
                fixed4 col = _MainColor;



                float _logMappedScale = _Scale / pow(10, ceil(log10(_Scale)));
                float _localScale     = 1 / _logMappedScale;

                float _fade = pow(1 - Remap(_logMappedScale, 0.1, 1, 0.00001, 0.99999), 0.5);
                

                float _xlineColor = 1.0f;

                _pos.xy = RotateMatrix(i.uv.xy, _XAxisRotation);
                
                _pos.x  = floor(frac(_pos.x * _localScale) + _Thickness);
                
                if(_pos.x == 1)
                {
                    //_xlineColor = 0.0f;
                    _xlineColor = max((1 - _fade), _fade);
                }
                else
                {
                    _pos.xy = RotateMatrix(i.uv.xy, _XAxisRotation);
                    _pos.x  = floor(frac(_pos.x * _localScale * 10) + _SecondaryLineThickness);

                    if(_pos.x == 1)
                    {
                        //_xlineColor = 0.0f;
                        _xlineColor = (1 - _fade);
                    }
                }

                

                float _ylineColor = 1.0f;

                _pos.xy = RotateMatrix(i.uv.xy, _YAxisRotation);
                _pos.y  = floor(frac(_pos.y * _localScale) + _Thickness);

                if( _pos.y == 1)
                {
                    _ylineColor = 0.0f;;
                }
                else
                {
                    _pos.xy = RotateMatrix(i.uv.xy, _YAxisRotation);
                    _pos.y = floor(frac(_pos.y * _localScale * 10) + _SecondaryLineThickness);

                    if(_pos.y == 1)
                    {
                        _ylineColor = 0.0f;
                    }
                }

                float c = Union(_xlineColor, _ylineColor);

                col = fixed4(c, c, c, 1.0);
                
                return col;
            }
            ENDCG
        }
    }
}
