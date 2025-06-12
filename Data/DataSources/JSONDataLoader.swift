// Data/DataSources/JSONDataLoader.swift

import Foundation

final class JSONDataLoader {
    enum LoaderError: LocalizedError {
        case fileNotFound(String)
        case decodingFailed(Error)
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "Could not find file: \(filename)"
            case .decodingFailed(let error):
                return "Failed to decode data: \(error.localizedDescription)"
            case .invalidData:
                return "Invalid data format"
            }
        }
    }
    
    // MARK: - Load Questions
    static func loadQuestions() async throws -> [Question] {
        do {
            let data = try await loadJSONData(filename: "questions", type: QuestionsContainer.self)
            return data.questions
        } catch {
            throw error
        }
    }
    
    // MARK: - Generic JSON Loading
    static func loadJSONData<T: Decodable>(filename: String, type: T.Type) async throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound("\(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch let decodingError as DecodingError {
            throw LoaderError.decodingFailed(decodingError)
        } catch {
            throw LoaderError.invalidData
        }
    }
    
    // MARK: - Save JSON (for testing/development)
    #if DEBUG
    static func saveJSON<T: Encodable>(_ object: T, to filename: String) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(object)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsPath.appendingPathComponent("\(filename).json")
            try data.write(to: fileURL)
            print("Saved JSON to: \(fileURL)")
        } catch {
            throw LoaderError.decodingFailed(error)
        }
    }
    #endif
}

// MARK: - Data Containers
private struct QuestionsContainer: Codable {
    let questions: [Question]
}
