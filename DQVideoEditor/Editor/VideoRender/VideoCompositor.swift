//
//  VideoCompositor.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/23.
//

import AVFoundation

class VideoCompositor: NSObject, AVVideoCompositing {
    
    private var renderingQueue = DispatchQueue(label: "com.studio.VideoLab.renderingqueue")
    private var renderContextQueue = DispatchQueue(label: "com.studio.VideoLab.rendercontextqueue")
    private var renderContext: AVVideoCompositionRenderContext?
    private var shouldCancelAllRequests = false
    private let layerCompositor = LayerCompositor()
    var sourcePixelBufferAttributes: [String : Any]? = [
        String(kCVPixelBufferPixelFormatTypeKey): [Int(kCVPixelFormatType_32ABGR),
                                                  Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                                                   Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)],
        String(kCVPixelBufferOpenGLCompatibilityKey): true
        ]
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = [
        String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA),
         String(kCVPixelBufferOpenGLESCompatibilityKey): true
    ]
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderingQueue.sync {
            renderContext = newRenderContext
        }
    }
    
    enum PixelBufferRequestError: Error {
        case newRenderedPixelBufferForRequestFailure
    }
    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        autoreleasepool {
            renderingQueue.async {
                if self.shouldCancelAllRequests{
                    asyncVideoCompositionRequest.finishCancelledRequest()
                }else{
                    guard let resultPixels = self.newRenderedPixelBufferForRequest(asyncVideoCompositionRequest) else{
                        asyncVideoCompositionRequest.finish(with: PixelBufferRequestError.newRenderedPixelBufferForRequestFailure)
                        return
                    }
                    asyncVideoCompositionRequest.finish(withComposedVideoFrame: resultPixels)
                }
            }
        }
    }
    

    func cancelAllPendingVideoCompositionRequests(){
        renderingQueue.sync {
            shouldCancelAllRequests = true
        }
        //执行完了之后复原
        renderingQueue.async {
            self.shouldCancelAllRequests = false
        }
    }
    func newRenderedPixelBufferForRequest(_ request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer?{
        guard let newPixelBuffer = renderContext?.newPixelBuffer() else{
            return  nil
        }
        layerCompositor.renderPixelBuffer(newPixelBuffer,for:request)
        
        return newPixelBuffer
    }
}
