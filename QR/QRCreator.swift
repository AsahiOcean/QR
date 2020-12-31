import SwiftUI

final class QRCreator: ObservableObject {
    var history: [String] = []
    @Published private(set) var result: Image = Image("LaunchScreen")
    @Published var text: String = "" {
        didSet {
            if self.text.count < 2330  { // 2330 - limit?
                if self.text != oldValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.creator(string: self.text)
                    }
                }
            } else {
                self.result = Image("Error_Too_many_characters")
            }
        }
    }
    
    func pasteboard() {
        guard let stringValue = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) ?? self.text else { fatalError() }
        self.text = stringValue
    }
    
    private func creator(string: String) {
        DispatchQueue.global(qos: .background).async {
            guard
                let qrFilter = CIFilter(name: "CIQRCodeGenerator"),
                let data = string.data(using: .utf8)
            else { return }
            
            qrFilter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            guard let qrImage = qrFilter.outputImage?.transformed(by: transform, highQualityDownsample: true) else { return }
            
            guard let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent) else { return }
            
            let result = Image(cgImage, scale: 1, label: Text("\(string)"))
            DispatchQueue.main.async {
                self.result = result
            }
        }
    }
}
