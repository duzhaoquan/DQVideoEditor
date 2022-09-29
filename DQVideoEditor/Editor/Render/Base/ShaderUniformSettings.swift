//
//  ShaderUniformSettings.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/26.
//

import simd
import Metal

public class ShaderUniformSettings {
    private var unifromValues = [String: Any]()
    private var vertexUnifroms: [String: UniformInfor]
    private var fragmentUniforms: [String: UniformInfor]
    
    init(vertexUnifroms: [String : UniformInfor], fragmentUniforms: [String : UniformInfor]) {
        self.vertexUnifroms = vertexUnifroms
        self.fragmentUniforms = fragmentUniforms
    }
    public subscript(key: String) -> Any?{
        get{
            return unifromValues[key]
        }
        set(newValue){
            unifromValues[key] = newValue
        }
    }
    //重载渲染设置
    public func restorShaderSettings(renderEncoder: MTLRenderCommandEncoder){
        for (uniform, value) in unifromValues{
            if let vertexInfo = vertexUnifroms[uniform] {
                renderEncoder.setVertexValue(value, uniformInfo: vertexInfo)
            }else if let fragmentInfo = fragmentUniforms[uniform] {
                renderEncoder.setFragmentValue(value, uniformInfo: fragmentInfo)
            }
        }
    }

}
public struct UniformInfor{
    let locationIndex: Int
    let dataSize: Int
}
extension MTLRenderCommandEncoder {
    func setVertexValue(_ value: Any,uniformInfo: UniformInfor){
        switch value {
        case let value as float3x3:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        case let value as float4x4:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        default:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        }
    }
    func setFragmentValue(_ value: Any, uniformInfo: UniformInfor){
        switch value {
        case let value as float3x3:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        case let value as float4x4:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        default:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        }
    }
}
