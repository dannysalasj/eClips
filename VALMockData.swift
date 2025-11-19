import Foundation

// Data gathered from VLR.gg
struct VALMockData {
    // --- MATCHES (Kept) ---
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
    
    // --- Team Info Structs (Moved from ValorantView.swift) ---
    struct VALTeamInfo: Identifiable, Decodable {
        let id: String
        let name: String
        let region: String
    }
    
    // --- UPDATED TEAM DATA ---
    static let teams: [VALTeamInfo] = [
        // North America (Top 6)
        VALTeamInfo(id: "val_t1_na", name: "G2 Esports", region: "NA"),
        VALTeamInfo(id: "val_t2_na", name: "NRG", region: "NA"),
        VALTeamInfo(id: "val_t3_na", name: "Sentinels", region: "NA"),
        VALTeamInfo(id: "val_t4_na", name: "100 Thieves", region: "NA"),
        VALTeamInfo(id: "val_t5_na", name: "Cloud9", region: "NA"),
        VALTeamInfo(id: "val_t6_na", name: "Evil Geniuses", region: "NA"),
        // South America (Top 6) -> Changing to LATAM
        VALTeamInfo(id: "val_t1_sa", name: "MIBR", region: "LATAM"),
        VALTeamInfo(id: "val_t2_sa", name: "LOUD", region: "LATAM"),
        VALTeamInfo(id: "val_t3_sa", name: "LEVIATÁN", region: "LATAM"),
        VALTeamInfo(id: "val_t4_sa", name: "KRÜ Esports", region: "LATAM"),
        VALTeamInfo(id: "val_t5_sa", name: "FURIA", region: "LATAM"),
        VALTeamInfo(id: "val_t6_sa", name: "2GAME Esports", region: "LATAM"),
        // Europe (EMEA) (Top 8)
        VALTeamInfo(id: "val_t1_eu", name: "FNATIC", region: "EMEA"),
        VALTeamInfo(id: "val_t2_eu", name: "Team Liquid", region: "EMEA"),
        VALTeamInfo(id: "val_t3_eu", name: "Team Heretics", region: "EMEA"),
        VALTeamInfo(id: "val_t5_eu", name: "GIANTX", region: "EMEA"),
        VALTeamInfo(id: "val_t6_eu", name: "Natus Vincere", region: "EMEA"),
        VALTeamInfo(id: "val_t7_eu", name: "Team Vitality", region: "EMEA"),
        // Pacific (Top 6) -> Changing to APAC
        VALTeamInfo(id: "val_t1_pac", name: "Paper Rex", region: "APAC"),
        VALTeamInfo(id: "val_t2_pac", name: "T1", region: "APAC"),
        VALTeamInfo(id: "val_t3_pac", name: "Rex Regum Qeon", region: "APAC"),
        VALTeamInfo(id: "val_t4_pac", name: "DRX", region: "APAC"),
        VALTeamInfo(id: "val_t5_pac", name: "Gen.G", region: "APAC"),
        VALTeamInfo(id: "val_t6_pac", name: "TALON", region: "APAC"),
        // China (Top 6)
        VALTeamInfo(id: "val_t1_cn", name: "Bilibili Gaming", region: "CN"),
        VALTeamInfo(id: "val_t2_cn", name: "EDward Gaming", region: "CN"),
        VALTeamInfo(id: "val_t3_cn", name: "Xi Lai Gaming", region: "CN"),
        VALTeamInfo(id: "val_t4_cn", name: "Dragon Ranger Gaming", region: "CN"),
        VALTeamInfo(id: "val_t5_cn", name: "Wolves Esports", region: "CN"),
        VALTeamInfo(id: "val_t6_cn", name: "Trace Esports", region: "CN"),
    ]
    
    // --- Forum Topic Structs (Moved from ValorantView.swift) ---
    struct VALForumTopic: Identifiable, Codable {
        let id: String
        let title: String
        let author: String
        var replies: Int
    }
    
    static let forumTopics: [VALForumTopic] = [
        VALForumTopic(id: "val_f1", title: "Who is the most underrated duelist in the Americas VCT?", author: "ValorantFanatic", replies: 345),
        VALForumTopic(id: "val_f2", title: "Should Riot add a new map based in Latin America?", author: "MapCreator1", replies: 1201),
        VALForumTopic(id: "val_f3", title: "My favorite clutch plays from the last VCT event!", author: "HighlightReel", replies: 88)
    ]
}
