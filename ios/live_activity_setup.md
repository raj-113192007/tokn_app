import ActivityKit
import WidgetKit
import SwiftUI

struct ToknAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var servingNumber: String
        var mineNumber: String
        var hospitalName: String
        var waitTime: String
    }
    var bookingId: String
}

@main
struct ToknLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ToknAttributes.self) { context in
            // Lock Screen/Notification View (Premium Design)
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.state.hospitalName)
                            .font(.headline)
                            .foregroundColor(Color(hex: "2E4C9D"))
                        Text("• LIVE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "3B9966"))
                    }
                    Spacer()
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(hex: "2E4C9D"))
                        .background(Color(hex: "F0F4FF"))
                        .clipShape(Circle())
                }
                
                Divider()
                
                // Numbers Section
                HStack {
                    VStack {
                        Text("SERVING")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Text("#\(context.state.servingNumber)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "3B9966"))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider().frame(height: 30)
                    
                    VStack {
                        Text("MINE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Text("#\(context.state.mineNumber)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "2E4C9D"))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                
                // Footer
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)
                    Text("~\(context.state.waitTime) mins wait")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.darkGray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("S: #\(context.state.servingNumber)")
                        .foregroundColor(.green)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("M: #\(context.state.mineNumber)")
                        .foregroundColor(.blue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.hospitalName) • \(context.state.waitTime)m wait")
                }
            } compactLeading: {
                Text("#\(context.state.servingNumber)")
                    .foregroundColor(.green)
            } compactTrailing: {
                Text("#\(context.state.mineNumber)")
                    .foregroundColor(.blue)
            } minimal: {
                Text(context.state.servingNumber)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
