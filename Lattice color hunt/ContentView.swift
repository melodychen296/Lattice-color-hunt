import SwiftUI
import AudioToolbox
import Combine
import Foundation

// MARK: - Core Data & Enums
enum GameState {
    case intro, home, loading, playing, result
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
}

enum MascotEmotion {
    case normal, happy, dizzy, shocked
}

enum CrystalSystem: String, CaseIterable, Codable {
    case cubic = "Cubic"
    case tetragonal = "Tetragonal"
    case orthorhombic = "Orthorhombic"
    case hexagonal = "Hexagonal"
    case rhombohedral = "Rhombohedral"
    case monoclinic = "Monoclinic"
    case triclinic = "Triclinic"
    
    var nameEn: String { rawValue }
    var nameZh: String {
        switch self {
        case .cubic: return "立方晶系 (等軸)"
        case .tetragonal: return "四方晶系"
        case .orthorhombic: return "斜方晶系"
        case .hexagonal: return "六方晶系"
        case .rhombohedral: return "菱面體晶系"
        case .monoclinic: return "單斜晶系"
        case .triclinic: return "三斜晶系"
        }
    }
    
    var triviaEn: String {
        switch self {
        case .cubic: return "Salt and diamonds belong here! Perfect symmetry, totally balanced."
        case .tetragonal: return "Imagine a cube, but stretched out like a tall building!"
        case .orthorhombic: return "Like a matchbox, all sides have different lengths but neat corners."
        case .hexagonal: return "Snowflakes get their 6 beautiful points from this lattice!"
        case .rhombohedral: return "Quartz crystals have this slightly twisted, elegant shape."
        case .monoclinic: return "Looks like a cardboard box that someone pushed sideways."
        case .triclinic: return "No symmetry at all! It leans in every single direction."
        }
    }
    
    var triviaZh: String {
        switch self {
        case .cubic: return "鹽巴跟鑽石都是立方晶系喔！四平八穩，完美對稱的資優生。"
        case .tetragonal: return "想像一個正方體，但是被用力拉高，就像一棟瘦長的大樓！"
        case .orthorhombic: return "長寬高都不一樣，就像一個火柴盒，但所有角都還是直角。"
        case .hexagonal: return "美麗的雪花會有 6 個角，就是因為它們內建這種晶系排列！"
        case .rhombohedral: return "漂亮的水晶（石英）就是屬於這個稍微有點被扭曲的優雅家族。"
        case .monoclinic: return "單斜晶系就像是一個被人從旁邊推歪的紙箱，倒立不起來。"
        case .triclinic: return "完全沒有對稱性，每個方向都歪七扭八的調皮鬼！"
        }
    }
}

struct GameRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let score: Int
    let difficulty: Difficulty
    let grade: String
}

struct HistoryStore {
    static let key = "GameHistoryRecords"
    static func load() -> [GameRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return []
        }
        return records
    }
    static func save(_ record: GameRecord) {
        var logs = load()
        logs.insert(record, at: 0)
        if logs.count > 50 { logs = Array(logs.prefix(50)) }
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    static func maxScore(for difficulty: Difficulty) -> Int {
        load().filter { $0.difficulty == difficulty }.map { $0.score }.max() ?? 0
    }
}

struct T {
    static func title(_ lang: String) -> String { "Lattice\nColor Hunt" }
    static func start(_ lang: String) -> String { lang == "en" ? "Initialize" : "啟動檢測" }
    static func settings(_ lang: String) -> String { lang == "en" ? "Lab Settings" : "實驗室設定" }
    static func language(_ lang: String) -> String { lang == "en" ? "Language" : "語言" }
    static func sfx(_ lang: String) -> String { lang == "en" ? "Machine Haptics" : "儀器音效與震動" }
    static func difficulty(_ lang: String) -> String { lang == "en" ? "Complexity" : "檢測難度" }
    static func highScore(_ lang: String, s: Int) -> String { lang == "en" ? "Best: \(s)" : "最高檢測紀錄: \(s)" }
    static func rule(_ lang: String) -> String { lang == "en" ? "Lab Manual" : "實驗操作手冊" }
    
    static func introTitle(_ lang: String) -> String { lang == "en" ? "Incoming Mission..." : "收到實驗室委託..." }
    static func introStory(_ lang: String) -> String {
        lang == "en" ? "You are a brilliant tiny material scientist!\n\nRecently, a batch of experimental materials degraded, forming unknown 'point defects' in their lattice.\n\nEquipped with your eagle eyes, we need you to scan the lattice and isolate the defective atoms!"
        : "你是實驗室裡最厲害的小小材料科學家！\n\n最近有一批珍貴的材料發生劣化，內部產生了微小且致命的「晶格點缺陷」。\n\n擁有肉眼顯微鏡稱號的你，快來幫忙掃描晶格，找出是哪顆原子出狀況了吧！"
    }
    static func introButton(_ lang: String) -> String { lang == "en" ? "Accept Mission" : "接受任務" }
    
    static func ruleText(_ lang: String) -> String {
        lang == "en" ? "Scan the lattice carefully!\nFind the single atom (dot) with a slightly different composition (color).\n\nTap right = Secure material +Time ⏳\nTap wrong = Material degrades -Time 🚨\nCan you achieve an S-class rating?"
        : "仔細掃描晶格結構！\n在整齊的原子陣列中，找出唯一一顆成分（顏色）異常的點缺陷。\n\n精準命中 ➔ 穩定材料，增加時間 ⏳\n誤判目標 ➔ 材料惡化，扣除時間 🚨\n不同難度有不同的寬鬆評分標準喔！"
    }
    static func score(_ lang: String, s: Int) -> String { lang == "en" ? "Fixed: \(s)" : "修復數量: \(s)" }
    static func gameOver(_ lang: String) -> String { lang == "en" ? "Analysis Complete" : "檢測結束" }
    static func playAgain(_ lang: String) -> String { lang == "en" ? "Scan Again" : "再次檢測" }
    static func goHome(_ lang: String) -> String { lang == "en" ? "Lab Dashboard" : "回控制台" }
    
    static func gradeComment(_ grade: String, lang: String) -> String {
        if lang == "en" {
            switch grade {
            case "S": return "Perfect fix! Your eyes are basically a Transmission Electron Microscope (TEM)!"
            case "A": return "Outstanding analysis! You saved a batch of top-tier semiconductors."
            case "B": return "Good job. The lattice is stable, just a few impurities left."
            case "C": return "Acceptable... but there might be some current leakage later."
            case "D": return "Uh oh, the material is ruined. Back to the synthesis lab we go!"
            default: return "Total structural collapse. What did you even synthesize?!"
            }
        } else {
            switch grade {
            case "S": return "完美的修復！你的眼睛根本是內建穿透式電子顯微鏡 (TEM) 吧！"
            case "A": return "出色的檢測！成功挽救了一大批頂級的半導體材料。"
            case "B": return "做得不錯！挑出了大部分的點缺陷，目前材料性質穩定。"
            case "C": return "還算及格...但沒抓到的缺陷可能會導致日後漏電喔！"
            case "D": return "哎呀，這批材料報廢了...快回無塵室重新合成吧！"
            default: return "結構完全崩壞！你確定你剛才在修復而不是在破壞嗎？！"
            }
        }
    }
}

// MARK: - Lab Grid Background
struct BlueprintBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 0.98).ignoresSafeArea()
            
            GeometryReader { geometry in
                Path { path in
                    let step: CGFloat = 30
                    for x in stride(from: 0, through: geometry.size.width, by: step) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, through: geometry.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.teal.opacity(0.1), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Scientist Mascot View
struct ScientistMascotView: View {
    var emotion: MascotEmotion
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 35)
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .frame(width: 60, height: 50)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(white: 0.3), lineWidth: 2))
                    
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(width: 2, height: 50)
                }
            }
            
            VStack(spacing: 0) {
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 35, y: 15))
                        path.addLine(to: CGPoint(x: 25, y: 2))
                        path.move(to: CGPoint(x: 55, y: 15))
                        path.addLine(to: CGPoint(x: 65, y: 4))
                    }
                    .stroke(Color(white: 0.2), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    
                    Circle()
                        .fill(Color(red: 0.98, green: 0.88, blue: 0.8))
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(Color(white: 0.3), lineWidth: 2.5))
                        .shadow(color: .cyan.opacity(0.2), radius: 5, y: 3)
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 16) {
                            if emotion == .dizzy {
                                Text("X").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                                Text("X").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                            } else if emotion == .happy {
                                Text("^").font(.system(size: 20, weight: .black)).foregroundColor(.black)
                                Text("^").font(.system(size: 20, weight: .black)).foregroundColor(.black)
                            } else if emotion == .shocked {
                                Circle().fill(Color.black).frame(width: 9, height: 9)
                                Circle().fill(Color.black).frame(width: 9, height: 9)
                            } else {
                                Circle().fill(Color.black).frame(width: 6, height: 6)
                                Circle().fill(Color.black).frame(width: 6, height: 6)
                            }
                        }
                        .offset(y: 2)
                        
                        if emotion == .happy || emotion == .shocked {
                            Circle()
                                .fill(emotion == .happy ? Color.pink : Color.black)
                                .frame(width: 10, height: emotion == .happy ? 8 : 10)
                                .offset(y: 2)
                        } else if emotion == .dizzy {
                            Capsule()
                                .fill(Color.black)
                                .frame(width: 14, height: 3)
                                .offset(y: 4)
                        } else {
                            Text("w").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                                .offset(y: -2)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.cyan.opacity(0.35))
                            .frame(width: 26, height: 18)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.teal, lineWidth: 2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.cyan.opacity(0.35))
                            .frame(width: 26, height: 18)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.teal, lineWidth: 2))
                    }
                    .offset(y: -4)
                    .offset(y: emotion == .shocked ? -15 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: emotion)
                }
            }
        }
        .frame(width: 90, height: 90)
    }
}

// MARK: - App Structure
struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "zh"
    @AppStorage("gameDifficulty") private var difficulty: Difficulty = .normal
    
    @State private var gameState: GameState = .intro
    @State private var score: Int = 0
    @State private var grade: String = ""
    @State private var selectedSystem: CrystalSystem = .cubic
    
    var body: some View {
        ZStack {
            BlueprintBackground()
            
            Group {
                switch gameState {
                case .intro:
                    IntroView(gameState: $gameState, appLanguage: appLanguage)
                case .home:
                    HomeView(gameState: $gameState, appLanguage: $appLanguage, difficulty: $difficulty)
                case .loading:
                    LoadingView(gameState: $gameState, appLanguage: appLanguage, finalSystem: $selectedSystem)
                case .playing:
                    GameView(gameState: $gameState, score: $score, difficulty: difficulty, appLanguage: appLanguage, finalGrade: $grade, crystalSystem: selectedSystem)
                case .result:
                    ResultView(gameState: $gameState, score: score, difficulty: difficulty, grade: grade, appLanguage: appLanguage)
                }
            }
            .transition(.scale(scale: 0.95).combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameState)
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Intro View
struct IntroView: View {
    @Binding var gameState: GameState
    let appLanguage: String
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 25) {
            Text(T.introTitle(appLanguage))
                .font(.system(size: 26, weight: .black, design: .monospaced))
                .foregroundColor(.teal)
                .padding(.top, 40)
            
            Spacer()
            
            ScientistMascotView(emotion: .happy)
                .scaleEffect(2.2)
                .padding(.vertical, 20)
                .offset(y: floatOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        floatOffset = -15
                    }
                }
            
            VStack {
                Text(T.introStory(appLanguage))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .padding(22)
            }
            .background(Color.white.opacity(0.85))
            .cornerRadius(15)
            .shadow(color: .teal.opacity(0.1), radius: 10)
            .padding(.horizontal, 25)
            
            Spacer()
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                gameState = .home
            }) {
                Text(T.introButton(appLanguage))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.teal)
                    .cornerRadius(15)
                    .shadow(color: .teal.opacity(0.4), radius: 8, y: 4)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - HomeView
struct HomeView: View {
    @Binding var gameState: GameState
    @Binding var appLanguage: String
    @Binding var difficulty: Difficulty
    
    @State private var showSettings = false
    @State private var showRules = false
    @State private var showHistory = false
    @State private var mascotBounce: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { showRules = true }) {
                    Image(systemName: "book.fill")
                        .font(.title2)
                        .foregroundColor(.teal)
                        .padding()
                }
                Spacer()
                Button(action: { showHistory = true }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                }
                Button(action: { showSettings = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                ScientistMascotView(emotion: .normal)
                    .scaleEffect(1.3)
                    .offset(y: mascotBounce)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            mascotBounce = -10
                        }
                    }
                
                Text(T.title(appLanguage))
                    .font(.system(size: 42, weight: .heavy, design: .monospaced))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding()
            }
            
            Spacer().frame(height: 30)
            
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    Text(T.difficulty(appLanguage))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Picker(T.difficulty(appLanguage), selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { diff in
                            Text(diff.rawValue).tag(diff)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                    .tint(.teal)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill").foregroundColor(.teal)
                        Text(T.highScore(appLanguage, s: HistoryStore.maxScore(for: difficulty)))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                    }
                    .padding(.top, 4)
                    .animation(.none, value: difficulty)
                }
                
                Button(action: {
                    gameState = .loading
                }) {
                    Text(T.start(appLanguage))
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(width: 220)
                        .background(Color.teal)
                        .cornerRadius(30)
                        .shadow(color: .teal.opacity(0.5), radius: 10, y: 5)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showSettings) { SettingsView(appLanguage: $appLanguage) }
        .sheet(isPresented: $showRules) { RulesView(appLanguage: appLanguage) }
        .sheet(isPresented: $showHistory) { HistoryView(appLanguage: appLanguage) }
    }
}

// MARK: - Modals
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var appLanguage: String
    @AppStorage("isSFXEnabled") private var isSFXEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(T.language(appLanguage))) {
                    Picker(T.language(appLanguage), selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("中文").tag("zh")
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Audio")) {
                    Toggle(T.sfx(appLanguage), isOn: $isSFXEnabled)
                        .tint(.teal)
                }
            }
            .navigationTitle(T.settings(appLanguage))
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct RulesView: View {
    let appLanguage: String
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack {
                Text(T.ruleText(appLanguage))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .padding(30)
                    .background(Color(white: 0.95))
                    .cornerRadius(15)
                    .padding()
                Spacer()
            }
            .navigationTitle(T.rule(appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Confirm") { dismiss() } }
        }
    }
}

struct HistoryView: View {
    let appLanguage: String
    @Environment(\.dismiss) var dismiss
    @State private var records: [GameRecord] = []
    
    var body: some View {
        NavigationView {
            List(records) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(record.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                        Text(T.score(appLanguage, s: record.score))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(record.grade)
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(.teal)
                        Text(record.difficulty.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.teal.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.vertical, 2)
            }
            .navigationTitle("Lab Data")
            .toolbar { Button("Close") { dismiss() } }
            .onAppear { records = HistoryStore.load() }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @Binding var gameState: GameState
    let appLanguage: String
    @Binding var finalSystem: CrystalSystem
    
    @AppStorage("isSFXEnabled") private var isSFXEnabled: Bool = true
    @State private var currentIndex = 0
    @State private var isSpinning = true
    @State private var showResult = false
    @State private var showCountdown = false
    @State private var countdownText = ""
    
    let allSystems = CrystalSystem.allCases.shuffled()
    let spinTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                if showCountdown {
                    Text(countdownText)
                        .font(.system(size: 150, weight: .heavy, design: .monospaced))
                        .foregroundColor(.teal)
                        .transition(.scale(scale: 1.5).combined(with: .opacity))
                        .id(countdownText)
                } else {
                    VStack(spacing: 25) {
                        Text(appLanguage == "en" ? "Generating Lattice Structure..." : "生成晶格微觀結構中...")
                            .font(.title2.bold())
                            .foregroundColor(.gray)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.teal.opacity(0.1))
                                .frame(height: 80)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.teal, lineWidth: 3))
                            
                            Text(appLanguage == "en" ? allSystems[currentIndex].nameEn : allSystems[currentIndex].nameZh)
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(.black.opacity(0.8))
                                .id(currentIndex)
                                .animation(.none, value: currentIndex)
                        }
                        .padding(.horizontal, 40)
                        
                        ZStack {
                            if showResult {
                                let target = allSystems[currentIndex]
                                
                                VStack(spacing: 15) {
                                    Text(appLanguage == "en" ? target.triviaEn : target.triviaZh)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 25)
                                        .frame(height: 60)
                                    
                                    Image("image_b68b64")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 250, maxHeight: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .shadow(radius: 5)
                                }
                                .transition(.opacity)
                            }
                        }
                        .frame(height: 300)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            finalSystem = allSystems.randomElement()!
            runSequence()
        }
        .onReceive(spinTimer) { _ in
            if isSpinning {
                currentIndex = (currentIndex + 1) % allSystems.count
                if isSFXEnabled { AudioServicesPlaySystemSound(1103) }
            }
        }
    }
    
    func runSequence() {
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                isSpinning = false
                if let idx = allSystems.firstIndex(of: finalSystem) {
                    currentIndex = idx
                }
                if isSFXEnabled { AudioServicesPlaySystemSound(1057) }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showResult = true }
            }
            
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) { showCountdown = true }
            }
            
            for i in (1...3).reversed() {
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { countdownText = "\(i)" }
                    if isSFXEnabled { AudioServicesPlaySystemSound(1113) }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                try? await Task.sleep(nanoseconds: 800_000_000)
            }
            
            await MainActor.run { gameState = .playing }
        }
    }
}

// MARK: - GameView (Bravais Lattice Coordinate Layout)
struct GameView: View {
    @Binding var gameState: GameState
    @Binding var score: Int
    let difficulty: Difficulty
    let appLanguage: String
    @Binding var finalGrade: String
    let crystalSystem: CrystalSystem
    
    @AppStorage("isSFXEnabled") private var isSFXEnabled: Bool = true
    
    @State private var timeRemaining: Int = 30
    let maxTime: Int = 30
    @State private var isTimerActive: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var gridSize: Int = 3
    @State private var targetIndex: Int = 0
    @State private var baseColor: Color = .gray
    @State private var targetColor: Color = .gray
    
    @State private var shakeOffset: CGFloat = 0
    @State private var isRevealing: Bool = false
    
    @State private var mascotEmotion: MascotEmotion = .normal
    @State private var mascotOffset: CGFloat = 0
    
    var timeRatio: Double { min(1.0, max(0.0, Double(timeRemaining) / Double(maxTime))) }
    var barColor: Color {
        if timeRemaining > 15 { return .teal }
        else if timeRemaining > 5 { return .orange }
        else { return .red }
    }
    
    // 依據難度設定的加減秒數
    var timeGain: Int { difficulty == .easy ? 5 : (difficulty == .normal ? 3 : 1) }
    var timeLoss: Int { difficulty == .easy ? 1 : (difficulty == .normal ? 3 : 5) }

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                Button(action: {
                    isTimerActive = false
                    gameState = .home
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title)
                        .foregroundColor(.red.opacity(0.8))
                        .background(Circle().fill(Color.white))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                        RoundedRectangle(cornerRadius: 8)
                            .fill(barColor)
                            .frame(width: geo.size.width * CGFloat(timeRatio))
                            .animation(.linear(duration: 0.3), value: timeRatio)
                    }
                }
                .frame(height: 16)
                
                Text("\(score)")
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(.teal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // 點點排列區域 (絕對置中的基底向量晶格渲染)
            GeometryReader { geometry in
                let sideLength = min(geometry.size.width, geometry.size.height) * 0.75
                let spacing = sideLength / CGFloat(gridSize)
                let itemSize = spacing * 0.65
                let vectors = latticeVectors(for: crystalSystem, spacing: spacing)
                
                ZStack {
                    ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                        let row = index / gridSize
                        let col = index % gridSize
                        let cx = CGFloat(col) - CGFloat(gridSize - 1) / 2.0
                        let cy = CGFloat(row) - CGFloat(gridSize - 1) / 2.0
                        
                        let isTarget = index == targetIndex
                        let isHighlighted = isRevealing && isTarget
                        
                        // 計算真實的晶格偏移量
                        let xOffset = cx * vectors.v1.dx + cy * vectors.v2.dx
                        let yOffset = cx * vectors.v1.dy + cy * vectors.v2.dy
                        
                        Circle()
                            .fill(isTarget ? targetColor : baseColor)
                            .frame(width: itemSize, height: itemSize)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: isHighlighted ? 4 : 0)
                            )
                            .scaleEffect(isRevealing ? (isTarget ? 1.3 : 0.8) : 1.0)
                            .offset(x: xOffset, y: yOffset)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRevealing)
                            .onTapGesture {
                                handleTap(at: index)
                            }
                    }
                }
                .frame(width: sideLength, height: sideLength)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(x: shakeOffset)
            }
            
            // 下方小小實驗家
            HStack(spacing: 12) {
                ScientistMascotView(emotion: mascotEmotion)
                    .scaleEffect(1.1)
                    .offset(y: mascotOffset)
                
                Text(mascotSpeech)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.teal)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.15), radius: 3)
            }
            .padding(.bottom, 25)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { startGame() }
        .onReceive(timer) { _ in
            guard isTimerActive else { return }
            if timeRemaining > 0 { timeRemaining -= 1 }
            if timeRemaining <= 0 { endGame() }
        }
    }
    
    // 真實布拉菲晶格的基底向量，保證圖形精準生成且絕對對稱置中
    func latticeVectors(for system: CrystalSystem, spacing: CGFloat) -> (v1: CGVector, v2: CGVector) {
        switch system {
        case .cubic:
            return (CGVector(dx: spacing, dy: 0), CGVector(dx: 0, dy: spacing))
        case .tetragonal:
            return (CGVector(dx: spacing, dy: 0), CGVector(dx: 0, dy: spacing * 1.3))
        case .orthorhombic:
            return (CGVector(dx: spacing * 1.2, dy: 0), CGVector(dx: 0, dy: spacing * 0.8))
        case .hexagonal:
            return (CGVector(dx: spacing, dy: 0), CGVector(dx: spacing * 0.5, dy: spacing * 0.866))
        case .rhombohedral:
            return (CGVector(dx: spacing, dy: spacing * 0.3), CGVector(dx: spacing * 0.3, dy: spacing))
        case .monoclinic:
            return (CGVector(dx: spacing, dy: 0), CGVector(dx: spacing * 0.3, dy: spacing))
        case .triclinic:
            return (CGVector(dx: spacing * 1.1, dy: spacing * 0.2), CGVector(dx: spacing * 0.2, dy: spacing * 0.9))
        }
    }
    
    var mascotSpeech: String {
        switch mascotEmotion {
        case .happy: return appLanguage == "en" ? "Got it! Great scan!" : "太棒了！抓到一顆缺陷！"
        case .dizzy: return appLanguage == "en" ? "Oops! Wrong atom!" : "哎呀！點錯原子了！"
        case .shocked: return appLanguage == "en" ? "Oh no! Time's up!" : "糟糕！材料快崩解了！"
        default: return appLanguage == "en" ? "Scanning lattice..." : "正在仔細掃描中..."
        }
    }
    
    func playSound(_ soundID: SystemSoundID) {
        if isSFXEnabled { AudioServicesPlaySystemSound(soundID) }
    }
    
    func triggerShake() {
        withAnimation(.linear(duration: 0.05).repeatCount(5, autoreverses: true)) {
            shakeOffset = 15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shakeOffset = 0 }
    }
    
    func triggerMascotReaction(isCorrect: Bool) {
        if isCorrect {
            mascotEmotion = .happy
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { mascotOffset = -8 }
        } else {
            mascotEmotion = .dizzy
            withAnimation(.linear(duration: 0.1).repeatCount(3, autoreverses: true)) { mascotOffset = 5 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            mascotEmotion = .normal
            withAnimation(.spring()) { mascotOffset = 0 }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = maxTime
        isTimerActive = true
        isRevealing = false
        mascotEmotion = .normal
        generateLevel()
    }
    
    func generateLevel() {
        gridSize = min(3 + score / 4, 8)
        targetIndex = Int.random(in: 0..<(gridSize * gridSize))
        let hue = Double.random(in: 0...1)
        let sat = Double.random(in: 0.5...1.0)
        let bri = Double.random(in: 0.7...0.95)
        baseColor = Color(hue: hue, saturation: sat, brightness: bri)
        
        // 依據難度分別給予不同的顏色判斷基準，Hard 將非常困難！
        var diff: Double
        switch difficulty {
        case .easy:
            diff = max(0.06, 0.20 - Double(score) * 0.003)
        case .normal:
            diff = max(0.02, 0.12 - Double(score) * 0.004)
        case .hard:
            diff = max(0.005, 0.08 - Double(score) * 0.005)
        }
        
        if Int.random(in: 0...1) == 0 {
            targetColor = Color(hue: (hue + diff).truncatingRemainder(dividingBy: 1.0), saturation: sat, brightness: bri)
        } else {
            targetColor = Color(hue: hue, saturation: max(0, sat - diff), brightness: bri)
        }
    }
    
    func handleTap(at index: Int) {
        guard isTimerActive, !isRevealing else { return }
        if index == targetIndex {
            playSound(1104)
            triggerMascotReaction(isCorrect: true)
            if isSFXEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            withAnimation(.spring()) {
                timeRemaining = min(maxTime + 10, timeRemaining + timeGain)
                score += 1
                generateLevel()
            }
        } else {
            playSound(1053)
            triggerMascotReaction(isCorrect: false)
            if isSFXEnabled { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
            triggerShake()
            withAnimation(.spring()) {
                timeRemaining = max(0, timeRemaining - timeLoss)
            }
            if timeRemaining == 0 { endGame() }
        }
    }
    
    func calculateGrade() -> String {
        // 評分標準：每個難度有不同的達標門檻 (越難的模式門檻越低，因為容錯率極低)
        let sThresh = difficulty == .easy ? 40 : (difficulty == .normal ? 30 : 20)
        let aThresh = difficulty == .easy ? 30 : (difficulty == .normal ? 20 : 15)
        let bThresh = difficulty == .easy ? 20 : (difficulty == .normal ? 12 : 10)
        let cThresh = difficulty == .easy ? 10 : (difficulty == .normal ? 6 : 5)
        
        if score >= sThresh { return "S" }
        if score >= aThresh { return "A" }
        if score >= bThresh { return "B" }
        if score >= cThresh { return "C" }
        if score > 0 { return "D" }
        return "F"
    }
    
    func endGame() {
        isTimerActive = false
        isRevealing = true
        mascotEmotion = .shocked
        playSound(1053)
        finalGrade = calculateGrade()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { gameState = .result }
    }
}

// MARK: - ResultView
struct ResultView: View {
    @Binding var gameState: GameState
    let score: Int
    let difficulty: Difficulty
    let grade: String
    let appLanguage: String
    
    @AppStorage("isSFXEnabled") private var isSFXEnabled: Bool = true
    @State private var showGrade = false
    
    var mascotFinalEmotion: MascotEmotion {
        switch grade {
        case "S", "A": return .happy
        case "B", "C": return .normal
        default: return .dizzy
        }
    }
    
    var body: some View {
        ZStack {
            BlueprintBackground()
            
            VStack(spacing: 25) {
                Spacer()
                
                Text(T.gameOver(appLanguage))
                    .font(.system(size: 36, weight: .black, design: .monospaced))
                    .foregroundColor(.black.opacity(0.8))
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        Text(T.score(appLanguage, s: score))
                            .font(.title2.bold())
                            .foregroundColor(.gray)
                        
                        ScientistMascotView(emotion: mascotFinalEmotion)
                            .scaleEffect(1.1)
                    }
                    
                    Text(grade)
                        .font(.system(size: 130, weight: .heavy, design: .monospaced))
                        .foregroundColor(gradeColor(grade))
                        .rotationEffect(.degrees(showGrade ? -5 : 0))
                        .scaleEffect(showGrade ? 1.0 : 3.0)
                        .opacity(showGrade ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2), value: showGrade)
                    
                    Text(T.gradeComment(grade, lang: appLanguage))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                        .padding(.horizontal, 30)
                        .frame(height: 70)
                        .opacity(showGrade ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 0.8).delay(0.6), value: showGrade)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: { gameState = .loading }) {
                        Text(T.playAgain(appLanguage))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.teal)
                            .cornerRadius(15)
                            .padding(.horizontal, 40)
                    }
                    Button(action: { gameState = .home }) {
                        Text(T.goHome(appLanguage))
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(15)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            showGrade = true
            if isSFXEnabled {
                let soundID: SystemSoundID = (grade == "S" || grade == "A") ? 1332 : 1054
                AudioServicesPlaySystemSound(soundID)
            }
            let record = GameRecord(date: Date(), score: score, difficulty: difficulty, grade: grade)
            HistoryStore.save(record)
        }
    }
    
    func gradeColor(_ g: String) -> Color {
        switch g { case "S": return .purple; case "A": return .blue; case "B": return .teal; case "C": return .orange; case "D": return .init(red: 1.0, green: 0.4, blue: 0.4); default: return .gray }
    }
}

#Preview { ContentView() }
