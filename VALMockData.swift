import Foundation

// A simple, reusable struct for all mock matches
struct MockMatch: Identifiable, Decodable {
    let id: String
    let tournament: String
    let team1Name: String
    let team2Name: String
    let team1Score: Int
    let team2Score: Int
    let date: String

    var matchResult: String {
        "\(team1Score) - \(team2Score)"
    }
}

// Data gathered from VLR.gg
struct VALMockData {
    static let matches: [MockMatch] = [
        MockMatch(id: "val1", tournament: "Red Bull Home Ground 2025", team1Name: "G2 Esports", team2Name: "NRG", team1Score: 3, team2Score: 0, date: "Nov 16, 2025"),
        MockMatch(id: "val2", tournament: "SOOP Valorant League 2025", team1Name: "FULL SENSE", team2Name: "Sharper Esport", team1Score: 3, team2Score: 0, date: "Nov 17, 2025"),
        MockMatch(id: "val3", tournament: "Predator League 2026: Indonesia", team1Name: "BOOM Esports", team2Name: "Team Nemesis", team1Score: 2, team2Score: 1, date: "Nov 16, 2025"),
        MockMatch(id: "val4", tournament: "China Evolution Series: Epilogue", team1Name: "FunPlus Phoenix", team2Name: "Nova Esports", team1Score: 3, team2Score: 1, date: "Nov 16, 2025"),
        MockMatch(id: "val5", tournament: "Predator League 2026: Malaysia", team1Name: "Todak", team2Name: "ENDER DRAGON", team1Score: 3, team2Score: 0, date: "Nov 16, 2025"),
        MockMatch(id: "val6", tournament: "Predator League 2026: Philippines", team1Name: "Oasis Gaming", team2Name: "Xipto Esports", team1Score: 3, team2Score: 1, date: "Nov 16, 2025"),
        MockMatch(id: "val7", tournament: "Red Bull Home Ground 2025", team1Name: "G2 Esports", team2Name: "ZETA DIVISION", team1Score: 2, team2Score: 0, date: "Nov 15, 2025"),
        MockMatch(id: "val8", tournament: "BRAZA: Open Series by Elgin", team1Name: "ELEVATE", team2Name: "PEEK", team1Score: 3, team2Score: 2, date: "Nov 15, 2025"),
        MockMatch(id: "val9", tournament: "Red Bull Home Ground 2025", team1Name: "NRG", team2Name: "ZETA DIVISION", team1Score: 2, team2Score: 0, date: "Nov 15, 2025"),
        MockMatch(id: "val10", tournament: "China Evolution Series: Epilogue", team1Name: "JDG Esports", team2Name: "Trace Esports", team1Score: 3, team2Score: 2, date: "Nov 15, 2025")
    ]
}
