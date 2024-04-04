//
//  OCRProcessor.swift
//  Digital Bank
//
//  Created by Keith Puzey on 4/4/24.
//

import UIKit
import Vision

protocol OCRProcessorDelegate: AnyObject {
    func didExtractOCRResult(description: String, amount: String)
}

class OCRProcessor {
    weak var delegate: OCRProcessorDelegate?

    func process(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Unable to convert UIImage to CGImage")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text recognized")
                return
            }

            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("No candidate found")
                    continue
                }
                detectedText += topCandidate.string + "\n"
            }

            // Process the detected text to extract description and amount
            self.extractDescriptionAndAmount(from: detectedText)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }

    private func extractDescriptionAndAmount(from text: String) {
        // Here, implement your logic to extract description and amount from the detected text
        // For demonstration, let's assume the description is the first line and the amount is the second line
        let lines = text.components(separatedBy: "\n")
        if lines.count >= 2 {
            let description = lines[0]
            let amount = lines[1]
            delegate?.didExtractOCRResult(description: description, amount: amount)
        } else {
            print("Insufficient text detected for extraction")
        }
    }
}
