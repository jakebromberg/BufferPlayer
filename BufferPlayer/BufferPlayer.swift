import Foundation
import Darwin
import AVFoundation

extension URL {
    static var WXYCStream: URL {
        return URL(string: "http://audio-mp3.ibiblio.org:8000/wxyc.mp3")!
    }
}

struct CoalescingBuffer {
    static let DefaultCapacity = 1048576 / 8 / 8
    
    let capacity = DefaultCapacity
    private var storage = Data()
    
    mutating func append(data: Data) -> Bool {
        if storage.count + data.count > capacity {
            return false
        }
        
        storage.append(data)
        
        return true
    }
    
    func processData(_ processor: (Data) throws -> ()) rethrows {
        try processor(storage)
    }
}

class DataStreamer: NSObject, URLSessionDataDelegate {
    var buffer = CoalescingBuffer()
    let processingQueue = DispatchQueue(label: "writingQueue")
    var player  = AVQueuePlayer()
    
    override init() {
        super.init()
        
        self.player.play()
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if buffer.append(data: data) {
            return
        }

        let oldBuffer = self.buffer
        
        buffer = CoalescingBuffer()
        
        if !buffer.append(data: data) {
            fatalError() // bomb if we can't write to a fresh buffer
        }
        
        processingQueue.async {
            let fileName = UUID().uuidString + ".mp3"
            let filePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            let fileURL = URL(fileURLWithPath: filePath + fileName)
            
            oldBuffer.processData { data in
                try! data.write(to: fileURL)
            }
            
            let asset = AVURLAsset(url: fileURL)
            let item = AVPlayerItem(asset: asset)
            self.player.insert(item, after: nil)
        }
    }
}
