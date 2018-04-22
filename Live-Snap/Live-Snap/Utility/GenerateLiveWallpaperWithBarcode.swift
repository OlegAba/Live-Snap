//
//  GenerateLiveWallpaperWithBarcode.swift
//  Live-Snap
//
//  Created by Baby on 1/8/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import Photos

class GenerateLiveWallpaperWithBarcode {
    
    let wallpaperImage: UIImage
    let barcodeImage: UIImage
    let fileName: String
    
    init(fileName: String, wallpaperImage: UIImage, barcodeImage: UIImage) {
        self.fileName = fileName
        self.wallpaperImage = wallpaperImage
        self.barcodeImage = barcodeImage
    }
    
    func imageURL() -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let imageFilePath = "\(documentsDirectory)/\(fileName).jpeg"
        return URL(fileURLWithPath: imageFilePath)
    }
    
    func videoURL() -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let videoFilePath = "\(documentsDirectory)/\(fileName).mov"
        return URL(fileURLWithPath: videoFilePath)
    }
    
    func create(completion: @escaping (LivePhoto?) -> ()) {
        
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { completion(nil); return }
        
        let imageFilePath = "\(documentsDirectory)/\(fileName).jpeg"
        let imageFilePathURL = URL(fileURLWithPath: imageFilePath)

        let videoFilePath = "\(documentsDirectory)/\(fileName).mov"
        let videoFilePathURL = URL(fileURLWithPath: videoFilePath)
        
        guard let videoFrames = interpolateFrames() else { completion(nil); return }
        VideoFromImages(images: videoFrames, framesPerSecond: 3).writeMovieToURL(url: videoFilePathURL) { (success: Bool) in
            
            guard success else { completion(nil); return }
            
            // Create image path
            guard let livePhotoImage = videoFrames.first else { completion(nil); return }
            let livePhotoImageData = UIImageJPEGRepresentation(livePhotoImage, 1.0)
            guard let _ = try? livePhotoImageData?.write(to: imageFilePathURL) else { completion(nil); return }

            LivePhotoMaker(imagePath: imageFilePath, videoPath: videoFilePath).create(completion: { (livePhoto: LivePhoto?) in
                completion(livePhoto)
            })
        }
    }
    
    func interpolateFrames() -> [UIImage]? {
        
        let frame1 = wallpaperImage
        
        /*
        guard let frame2Background = frame1.darkenedAndBlurred(darkness: 0.04, blurRadius: 16) else { return nil }
        guard let blurredSnapcode = barcodeImage.blurred(blurRadius: 16) else { return nil }
        guard let frame2 = drawSnapCodeOnImage(snapcode: blurredSnapcode, image: frame2Background) else { return nil }
        
        let frame3Background = frame1.darkenedAndBlurred(darkness: 0.06, blurRadius: 30)
        guard let frame3 = drawSnapCodeOnImage(snapcode: barcodeImage, image: frame3Background!) else { return nil }
        */

        guard let frame2 = drawSnapCodeOnImage(snapcode: barcodeImage, image: frame1) else { return nil }
 
        //return [frame1, frame2, frame3]
        return [frame1, frame2]
    }
    
    func drawSnapCodeOnImage(snapcode: UIImage, image: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let _ = UIGraphicsGetCurrentContext() else { return nil }
       
        let xOffset = (image.size.width / 2.0) - snapcode.size.width / 2.0
        let yOffset = (image.size.height / 2.0) - snapcode.size.height / 2.0
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        snapcode.draw(in: CGRect(x: xOffset, y: yOffset, width: snapcode.size.width, height: snapcode.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}
