//
//  Winefonts.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import Foundation
import SemanticVersion

class WinefontsTypes {
    /// A URL encoded as a string.
    public struct CodableURL: Codable {
        let url: URL

        // Encode just the URL's string representation.
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(url.absoluteString)
        }

        // Decode just the URL's string representation.
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let url = URL(string: string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid URL string: \(string)")
            }
            self.url = url
        }

        init(_ url: URL) {
            self.url = url
        }
    }

    /// A Semantic Version encoded as a string.
    public struct CodableSemanticVersion: Codable {
        let version: SemanticVersion

        // Encode just the SemanticVersion's string representation.
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(version.description)
        }

        // Decode just the SemanticVersion's string representation.
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let version = SemanticVersion(string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Semantic Version string: \(string)")
            }
            self.version = version
        }

        init(_ version: SemanticVersion) {
            self.version = version
        }
    }

    /// A downloadable file.
    public struct Download: Codable {
        var id: UUID
        var downloadUrl: CodableURL
        var hash: String
        var fileSize: Double
    }

    /// A group of fonts.
    public struct Group: Codable {
        var id: UUID
        var name: String
        var fonts: [UUID]
    }

    /// A font category.
    public enum FontCategory: String, Codable {
        case Serif = "serif"
        case SansSerif = "sans-serif"
        case Monospace = "monospace"
        case Cursive = "cursive"
        case Display = "display"
        case Symbol = "symbol"
    }

    /// A font installation.
    public enum FontInstallation: Codable {
        public struct CabextractInstallation: Codable {
            public struct File: Codable {
                var file: String
                var registryName: String
            }

            var download: UUID
            var files: [File]
        }

        case Cabextract(CabextractInstallation)

        enum CodingKeys: String, CodingKey {
            case type = "type"
        }

        enum Types: String, Codable {
            case Cabextract = "cabextract"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: CodingKeys.type)
            switch type {
            case Types.Cabextract.rawValue:
                self = .Cabextract(try CabextractInstallation(from: decoder))
            default:
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.type, in: container, debugDescription: "Invalid font installation type: \(type)")
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .Cabextract(let installation):
                try container.encode(Types.Cabextract.rawValue, forKey: CodingKeys.type)
                try installation.encode(to: encoder)
            }
        }
    }

    /// A font.
    public struct Font: Codable {
        var id: UUID
        var name: String
        var shortName: String
        var publisher: String
        var categories: [FontCategory]
        var installations: [FontInstallation]
    }

    /// A file.
    public struct File: Codable {
        var version: CodableSemanticVersion
        var downloads: [Download]
        var fonts: [Font]
        var groups: [Group]
    }
}
