import Foundation

// Data gathered from Liquipedia and escharts.com
struct OWMockData {
    // --- MATCHES (Kept) ---
    static let matches: [MockMatch] = [
        MockMatch(id: "ow1", tournament: "CECC 2026 West Regional", team1Name: "ASU", team2Name: "UTAH", team1Score: 3, team2Score: 2, date: "Nov 16, 2025"),
        MockMatch(id: "ow2", tournament: "Homecoming Fall 2025 Varsity", team1Name: "ISU", team2Name: "SCC", team1Score: 4, team2Score: 2, date: "Nov 16, 2025"),
        MockMatch(id: "ow3", tournament: "CECC 2026 West Regional", team1Name: "ASU", team2Name: "UCLA", team1Score: 3, team2Score: 0, date: "Nov 16, 2025"),
        MockMatch(id: "ow4", tournament: "G-Star Cup 2025", team1Name: "WAE", team2Name: "ADAR", team1Score: 3, team2Score: 2, date: "Nov 14, 2025"),
        MockMatch(id: "ow5", tournament: "OWCS 2025 - NA Stage 3", team1Name: "Liquid", team2Name: "SSG", team1Score: 4, team2Score: 3, date: "Oct 26, 2025"),
        MockMatch(id: "ow6", tournament: "OWCS 2025 - EMEA Stage 3", team1Name: "TM", team2Name: "AIQ", team1Score: 4, team2Score: 1, date: "Oct 26, 2025"),
        MockMatch(id: "ow7", tournament: "OWCS 2025 - NA Stage 3", team1Name: "Geekay", team2Name: "SSG", team1Score: 2, team2Score: 3, date: "Oct 26, 2025"),
        MockMatch(id: "ow8", tournament: "OWCS 2025 - EMEA Stage 3", team1Name: "TM", team2Name: "TP", team1Score: 3, team2Score: 0, date: "Oct 26, 2025"),
        MockMatch(id: "ow9", tournament: "OWCS 2025 - NA Stage 3", team1Name: "Liquid", team2Name: "Geekay", team1Score: 3, team2Score: 1, date: "Oct 25, 2025"),
        MockMatch(id: "ow10", tournament: "OWCS 2025 - NA Stage 3", team1Name: "Sakura", team2Name: "SSG", team1Score: 1, team2Score: 3, date: "Oct 25, 2025")
    ]
    
    // --- Team Info Structs (Moved from OverwatchView.swift) ---
    struct OWTeamInfo: Identifiable, Decodable {
        let id: String
        let name: String
        let region: String
    }
    
    // --- UPDATED TEAM DATA ---
    static let teams: [OWTeamInfo] = [
        // North America (Top 6)
        OWTeamInfo(id: "ow_t1_na", name: "Team Liquid", region: "NA"),
        OWTeamInfo(id: "ow_t2_na", name: "Spacestation Gaming", region: "NA"),
        OWTeamInfo(id: "ow_t3_na", name: "NTMR", region: "NA"),
        OWTeamInfo(id: "ow_t4_na", name: "Sakura", region: "NA"),
        OWTeamInfo(id: "ow_t5_na", name: "Geekay Esports", region: "NA"),
        OWTeamInfo(id: "ow_t6_na", name: "Team Z", region: "NA"),
        // South America (Top 6 - Using LATAM/Minor Competitive Teams) -> Changing to LATAM
        OWTeamInfo(id: "ow_t1_sa", name: "The Gatos Guapos", region: "LATAM"),
        OWTeamInfo(id: "ow_t2_sa", name: "ZoKorp Esports", region: "LATAM"),
        OWTeamInfo(id: "ow_t3_sa", name: "AG.AL International", region: "LATAM"),
        OWTeamInfo(id: "ow_t4_sa", name: "Team Eggplant", region: "LATAM"),
        OWTeamInfo(id: "ow_t5_sa", name: "ROC Esports", region: "LATAM"),
        OWTeamInfo(id: "ow_t6_sa", name: "Sign Esports", region: "LATAM"),
        // Europe (EMEA) (Top 8)
        OWTeamInfo(id: "ow_t1_eu", name: "Twisted Minds", region: "EMEA"),
        OWTeamInfo(id: "ow_t2_eu", name: "Virtus.pro", region: "EMEA"),
        OWTeamInfo(id: "ow_t3_eu", name: "Gen.G Esports", region: "EMEA"),
        OWTeamInfo(id: "ow_t4_eu", name: "Al Qadsiah", region: "EMEA"),
        OWTeamInfo(id: "ow_t6_eu", name: "Team Singularity", region: "EMEA"),
        OWTeamInfo(id: "ow_t7_eu", name: "Movistar KOI", region: "EMEA"),
        // Pacific (Asia/Korea/Japan) (Top 6) -> Changing to APAC
        OWTeamInfo(id: "ow_t1_pac", name: "Crazy Raccoon", region: "APAC"),
        OWTeamInfo(id: "ow_t2_pac", name: "Team Falcons", region: "APAC"),
        OWTeamInfo(id: "ow_t3_pac", name: "T1", region: "APAC"),
        OWTeamInfo(id: "ow_t4_pac", name: "VARREL", region: "APAC"),
        OWTeamInfo(id: "ow_t5_pac", name: "ZETA DIVISION", region: "APAC"),
        OWTeamInfo(id: "ow_t6_pac", name: "Nosebleed Esports", region: "APAC"),
        // China (Top 6)
        OWTeamInfo(id: "ow_t1_cn", name: "Weibo Gaming", region: "CN"),
        OWTeamInfo(id: "ow_t2_cn", name: "Team CC", region: "CN"),
        OWTeamInfo(id: "ow_t3_cn", name: "Once Again", region: "CN"),
        OWTeamInfo(id: "ow_t4_cn", name: "ROC Esports", region: "CN"),
        OWTeamInfo(id: "ow_t5_cn", name: "Old Man Club", region: "CN"),
        OWTeamInfo(id: "ow_t6_cn", name: "Lucky Future", region: "CN"),
    ]
    
    // --- Forum Topic Structs (Moved from OverwatchView.swift) ---
    struct OWForumTopic: Identifiable, Codable {
        let id: String
        let title: String
        let author: String
        var replies: Int
    }
    
    static let forumTopics: [OWForumTopic] = [
        OWForumTopic(id: "ow_f1", title: "Who do you think is the best Zarya player right now? Discussion.", author: "TankMain77", replies: 560),
        OWForumTopic(id: "ow_f2", title: "Request: New competitive mode rule set for one-tank.", author: "RuleChanger", replies: 1823),
        OWForumTopic(id: "ow_f3", title: "My favorite legendary skins from the Halloween event!", author: "CollectorOW", replies: 95)
    ]
}
