@testable import muterCore
import testingCore
import SwiftSyntax
import Foundation
import Quick
import Nimble

@available(OSX 10.13, *)
class AcceptanceTests: QuickSpec {
    override func spec() {

        var output: String!

        describe("someone using Muter", flags: [:]) {
            beforeEach {
                output = self.muterOutput
            }

            they("see that their files are copied to a temp folder") {
                expect(output.contains("Copying your project for mutation testing")).to(beTrue())
            }

            they("see the list of files that Muter discovered") {
                expect(output.contains("Discovered 3 Swift files")).to(beTrue())
                expect(self.numberOfDiscoveredFileLists(in: output)).to(beGreaterThanOrEqualTo(1))
            }

            they("see that Muter is working in a temporary directory") {
                expect(output.contains("/var/folders")).to(beTrue())
                expect(output.contains("/T/TemporaryItems/")).to(beTrue())
            }

            they("see how many mutation operators it's able to perform") {
                expect(output.contains("In total, Muter applied 9 mutation operators.")).to(beTrue())
            }

            they("see which runs of a mutation test passed and failed") {
                expect(output.contains("Mutation Test Passed")).to(beTrue())
                expect(output.contains("Mutation Test Failed")).to(beTrue())
            }

            they("see the mutation scores for their test suite") {
                let mutationScoresHeader = """
                --------------------
                Mutation Test Scores
                --------------------
                """

                expect(output.contains(mutationScoresHeader)).to(beTrue())
                expect(output.contains("Mutation Score of Test Suite (higher is better): 33/100")).to(beTrue())
            }

            they("see which mutation operators were applied") {
                let appliedMutationOperatorsHeader = """
                --------------------------
                Applied Mutation Operators
                --------------------------
                """

                expect(output.contains(appliedMutationOperatorsHeader)).to(beTrue())
            }
        }
    }
}

@available(OSX 10.13, *)
private extension AcceptanceTests {
    var exampleAppDirectory: String {
        return AcceptanceTests().productsDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent() // Go up 3 directories
            .appendingPathComponent("ExampleApp") // Go down 1 directory
            .withoutScheme() // Remove the file reference scheme
            .absoluteString
    }

    var muterOutputPath: String { return "\(AcceptanceTests().rootTestDirectory)/acceptanceTests/muters_output.txt" }

    var muterOutput: String {
        guard let data = FileManager.default.contents(atPath: muterOutputPath),
            let output = String(data: data, encoding: .utf8) else {
                fatalError("Unable to find a valid output file from a prior run of Muter at \(muterOutputPath)")
        }

        return output
    }

    func numberOfDiscoveredFileLists(in output: String) -> Int {
        let filePathRegex = try! NSRegularExpression(pattern: "Discovered \\d* Swift files:\n\n(/[^/ ]*)+/?", options: .anchorsMatchLines)
        let entireString = NSRange(location: 0, length: output.count)
        return filePathRegex.numberOfMatches(in: output,
                                             options: .withoutAnchoringBounds,
                                             range: entireString)
    }
}