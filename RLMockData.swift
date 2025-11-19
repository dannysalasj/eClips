import Foundation

// Data gathered from escharts.com
struct RLMockData {
    // --- MATCHES (Kept) ---
    static let matches: [MockMatch] = [
        MockMatch(id: "rl1", tournament: "Coupe de France Slash 2025", team1Name: "M8.Alpine", team2Name: "KC", team1Score: 4, team2Score: 2, date: "Nov 1, 2025"),
        MockMatch(id: "rl2", tournament: "Coupe de France Slash 2025", team1Name: "KC", team2Name: "VIT", team1Score: 3, team2Score: 2, date: "Nov 1, 2025"),
        MockMatch(id: "rl3", tournament: "Coupe de France Slash 2025", team1Name: "M8.Alpine", team2Name: "LYOST", team1Score: 3, team2Score: 0, date: "Nov 1, 2025"),
        MockMatch(id: "rl4", tournament: "RLCS 2025 - World Championship", team1Name: "NRG", team2Name: "FLCN", team1Score: 4, team2Score: 1, date: "Sep 14, 2025"),
        MockMatch(id: "rl5", tournament: "RLCS 2025 - World Championship", team1Name: "NRG", team2Name: "GE", team1Score: 4, team2Score: 0, date: "Sep 14, 2025"),
        MockMatch(id: "rl6", tournament: "RLCS 2025 - World Championship", team1Name: "FLCN", team2Name: "KC", team1Score: 4, team2Score: 2, date: "Sep 14, 2025"),
        MockMatch(id: "rl7", tournament: "RLCS 2025 - World Championship", team1Name: "GE", team2Name: "Wildcard", team1Score: 4, team2Score: 1, date: "Sep 14, 2025"),
        MockMatch(id: "rl8", tournament: "RLCS 2025 - World Championship", team1Name: "KC", team2Name: "ULT", team1Score: 4, team2Score: 0, date: "Sep 14, 2025"),
        MockMatch(id: "rl9", tournament: "RLCS 2025 - World Championship", team1Name: "FLCN", team2Name: "Wildcard", team1Score: 4, team2Score: 1, date: "Sep 13, 2025"),
        MockMatch(id: "rl10", tournament: "RLCS 2025 - World Championship", team1Name: "NRG", team2Name: "ULT", team1Score: 4, team2Score: 3, date: "Sep 13, 2025")
    ]
    
    // --- Team Info Structs (Moved from RocketLeagueView.swift) ---
    struct RLTeamInfo: Identifiable, Decodable {
        let id: String
        let name: String
        let region: String
    }
    
    // --- UPDATED TEAM DATA ---
    static let teams: [RLTeamInfo] = [
        // North America (Top 6)
        RLTeamInfo(id: "rl_t1_na", name: "NRG", region: "NA"),
        RLTeamInfo(id: "rl_t2_na", name: "The Ultimates", region: "NA"),
        RLTeamInfo(id: "rl_t3_na", name: "Spacestation Gaming", region: "NA"),
        RLTeamInfo(id: "rl_t4_na", name: "Gen.G Mobil1 Racing", region: "NA"),
        RLTeamInfo(id: "rl_t5_na", name: "Complexity Gaming", region: "NA"),
        RLTeamInfo(id: "rl_t6_na", name: "Team Evo", region: "NA"),
        // South America (SAM) (Top 6) -> Changing to LATAM
        RLTeamInfo(id: "rl_t1_sa", name: "FURIA", region: "LATAM"),
        RLTeamInfo(id: "rl_t2_sa", name: "MIBR", region: "LATAM"),
        RLTeamInfo(id: "rl_t3_sa", name: "Team Secret", region: "LATAM"),
        RLTeamInfo(id: "rl_t4_sa", name: "Novadrift", region: "LATAM"),
        RLTeamInfo(id: "rl_t5_sa", name: "bandoleiros", region: "LATAM"),
        RLTeamInfo(id: "rl_t6_sa", name: "NoTime", region: "LATAM"),
        // Europe (Top 8)
        RLTeamInfo(id: "rl_t1_eu", name: "Karmine Corp", region: "EU"),
        RLTeamInfo(id: "rl_t2_eu", name: "Dignitas", region: "EU"),
        RLTeamInfo(id: "rl_t3_eu", name: "Team Vitality", region: "EU"),
        RLTeamInfo(id: "rl_t4_eu", name: "Ninjas in Pyjamas", region: "EU"),
        RLTeamInfo(id: "rl_t6_eu", name: "Gentle Mates Alpine", region: "EU"),
        RLTeamInfo(id: "rl_t7_eu", name: "Team BDS", region: "EU"),
        // Pacific (APAC) (Top 6) -> Changing to APAC
        RLTeamInfo(id: "rl_t1_pac", name: "Gamin Gladiators", region: "APAC"),
        RLTeamInfo(id: "rl_t2_pac", name: "Elevate", region: "APAC"),
        RLTeamInfo(id: "rl_t3_pac", name: "Veloce Esports", region: "APAC"),
        RLTeamInfo(id: "rl_t4_pac", name: "The Club", region: "APAC"),
        RLTeamInfo(id: "rl_t5_pac", name: "Ghost Gaming", region: "APAC"),
        RLTeamInfo(id: "rl_t6_pac", name: "Ground Zero Gaming", region: "APAC"),
        // China (MENA - Using competitive teams from the Middle East/North Africa region)
        RLTeamInfo(id: "rl_t1_cn", name: "Team Falcons", region: "CN"),
        RLTeamInfo(id: "rl_t2_cn", name: "Twisted Minds", region: "CN"),
        RLTeamInfo(id: "rl_t3_cn", name: "Al Qadsiah", region: "CN"),
        RLTeamInfo(id: "rl_t4_cn", name: "RISING STAR", region: "CN"),
        RLTeamInfo(id: "rl_t5_cn", name: "Geekay Esports", region: "CN"),
        RLTeamInfo(id: "rl_t6_cn", name: "KOI", region: "CN"),
    ]
    
    // --- Forum Topic Structs (Moved from RocketLeagueView.swift) ---
    struct RLForumTopic: Identifiable, Codable {
        let id: String
        let title: String
        let author: String
        var replies: Int
    }
    
    static let forumTopics: [RLForumTopic] = [
        RLForumTopic(id: "rl_f1", title: "Is the new RLCS circuit too demanding on player health?", author: "RLProDebater", replies: 890),
        RLForumTopic(id: "rl_f2", title: "Which decal looks the best on the Octane? Post your setups!", author: "CustomCarFan", replies: 3205),
        RLForumTopic(id: "rl_f3", title: "Theory: Next season's world championship location is Europe.", author: "MapPredictor", replies: 156)
    ]
}
