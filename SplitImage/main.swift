//
//  main.swift
//  SplitImage
//
//  Created by Shane Whitehead on 22/6/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
//    static NSImage *croppedImageFromRect(NSImage *image, NSRect rect){
//    NSImage *subImage = [[NSImage alloc] initWithSize:rect.size];
//    NSRect drawRect = NSZeroRect;
//    drawRect.size = rect.size;
//    [subImage lockFocus];
//    [image drawInRect:drawRect
//    fromRect:rect
//    operation:NSCompositeSourceOver
//    fraction:1.0f];
//    [subImage unlockFocus];
//    return subImage;
//    }
    
    func cropped(fromRect rect: NSRect) -> NSImage {
        let subImage = NSImage(size: rect.size)
        var drawRect = NSRect.zero
        drawRect.size = rect.size
        subImage.lockFocus()
        draw(in: drawRect, from: rect, operation: .sourceOver, fraction: 1.0)
        subImage.unlockFocus()
        return subImage
    }
}

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath
let urlPath = URL(fileURLWithPath: currentDirectory)

///Users/swhitehead/Downloads/iStock-468823102.jpg
///Users/swhitehead/Downloads/iStock-527675810.jpg

let gridWidth : CGFloat = 5.0
let gridHeight : CGFloat = 5.0

let sourceURL = URL(fileURLWithPath: "/Users/swhitehead/Downloads/iStock-527675810.jpg")
print("Read image")
let image = NSImage(byReferencing: sourceURL)
let width = image.size.width
let height = image.size.height
print("Image Size = \(width)x\(height)")
let cellWidth = round(width / gridWidth)
let cellHeight = round(height / gridHeight)
for row in 0..<Int(gridHeight) {
    for col in 0..<Int(gridWidth) {
        let cell = NSRect(x: CGFloat(col) * cellWidth,
                          y: CGFloat(row) * cellHeight,
                          width: cellWidth,
                          height: cellHeight)
        let subImage = image.cropped(fromRect: cell)
        let dest = urlPath.appendingPathComponent("\(col)x\(row).png")
        print("Write image to \(dest)")
        if !subImage.pngWrite(to: dest) {
            print("!! Could not write file to \(dest)")
        }
    }
}
