//
//  FileNoteContentRepository.swift
//  Scribe
//
//  Created by Варнавский Игорь Витальевич on 03.11.2026.
//

import Foundation

actor FileNoteContentRepository: NoteContentRepository {
    private let directory: URL

    init(directory: URL = URL.applicationSupportDirectory
        .appendingPathComponent("Scribe/Notes", isDirectory: true)) {
        self.directory = directory
    }

    func load(noteID: UUID) throws -> String {
        try readTextIfPresent(at: fileURL(noteID)) ?? ""
    }

    func save(_ text: String, noteID: UUID) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try text.write(to: fileURL(noteID), atomically: true, encoding: .utf8)
    }

    func delete(noteIDs: [UUID]) throws {
        for noteID in noteIDs {
            try removeFileIfPresent(at: fileURL(noteID))
        }
    }

    private func readTextIfPresent(at url: URL) throws -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return nil
        }
    }

    private func removeFileIfPresent(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            return
        }
    }

    private func fileURL(_ noteID: UUID) -> URL {
        directory.appendingPathComponent(noteID.uuidString).appendingPathExtension("md")
    }
}
