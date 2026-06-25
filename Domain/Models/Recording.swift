//
//  Recording.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public struct Recording: Identifiable, Codable, Equatable {
    public let id: UUID
    public let filename: String
    public let createdAt: Date
    public let duration: TimeInterval
    public var name: String

    public var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent(filename)
    }

    public init(id: UUID = UUID(), filename: String, createdAt: Date = Date(), duration: TimeInterval, name: String) {
        self.id = id
        self.filename = filename
        self.createdAt = createdAt
        self.duration = duration
        self.name = name
    }
}
