//
//  Shaders.metal
//  TP7
//
//  Created by Carter Ewen on 2/19/26.
//
#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 randomNoise(float2 position, half4 color) {
    float2 cell = floor(position / 1.0);
    
    float value = fract(sin(dot(cell, float2(12.9898, 78.233))) * 43758.5453);
    
    float speck = step(0.92, value);
    
    return half4(0, 0, 0, half(speck) * 0.4);
}
