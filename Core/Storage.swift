//
//  Storage.swift
//  Core
//
//  Created by Alex Rupérez on 12/2/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import Foundation

public protocol Storable: NSSecureCoding {

    var identifier: String? { get }

}

public class Storage<E: Storable> {

    private let fileManager = FileManager.default
    private let containerURL: URL

    public init(groupIdentifier: String, path: String? = nil) {
        guard let path = path else {
            containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
            return
        }
        containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!.appendingPathComponent(path, isDirectory: true)
    }

    public func fetch(_ identifier: String) -> E? {
        let filePath = containerURL.appendingPathComponent(identifier, isDirectory: false).path
        guard fileManager.fileExists(atPath: filePath),
            let element = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? E,
            element.identifier == identifier else {
            return nil
        }
        return element
    }

    public func fetchAll() -> [E] {
        guard fileManager.fileExists(atPath: containerURL.path),
            let filePaths = try? fileManager.contentsOfDirectory(atPath: containerURL.path) else {
            return []
        }
        return filePaths.flatMap({ return fetch($0) })
    }

    @discardableResult public func save(_ element: E) -> Bool {
        if !fileManager.fileExists(atPath: containerURL.path) {
            try? fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true)
        }
        let filePath = containerURL.appendingPathComponent(element.identifier ?? UUID().uuidString, isDirectory: false).path
        return NSKeyedArchiver.archiveRootObject(element, toFile: filePath)
    }

    @discardableResult public func save(_ elements: [E]) -> Bool {
        return elements.reduce(true) { $0 && save($1) }
    }

    @discardableResult public func remove(_ element: E) -> Bool {
        guard let identifier = element.identifier else {
            return false
        }
        let fileURL = containerURL.appendingPathComponent(identifier, isDirectory: false)
        if fileManager.fileExists(atPath: fileURL.path) {
            try? self.fileManager.removeItem(at: fileURL)
            return true
        }
        return false
    }

    @discardableResult public func removeAll() -> Bool {
        if fileManager.fileExists(atPath: containerURL.path) {
            try? self.fileManager.removeItem(at: containerURL)
            return true
        }
        return false
    }

}
