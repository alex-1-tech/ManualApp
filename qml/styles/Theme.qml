pragma Singleton
import QtQuick 2.15

QtObject {
    // ==== Text ====
    property color colorTextPrimary: "#F3F4F6"
    property color colorTextSecondary: "#D1D5DB"
    property color colorTextMuted: "#9CA3AF"
    property color colorTextLight: "#6B7280"
    property color colorTextPlaceholder: "#aaaaaa"

    // ==== Background ====
    property color colorBgPrimary: "#2E3E4E"
    property color colorBgMuted: "#3C4F63"
    property color colorBgCard: "#374A5E"

    // ==== Sidebar ====
    property color colorSidebar: "#293846"
    property color colorNavActive: "#354759"
    property color colorNavInactive: "#263441"
    property color colorNavHover: "#3D5166"

    // ==== Borders ====
    property color colorBorder: "#475569"
    property color colorBorderHover: "#64748B"
    property color colorBorderLight: "#334155"

    // ==== Accents ====
    property color colorAccent: "#3B82F6"
    property color colorAccentHover: "#2563EB"
    property color colorAccentMuted: "#60A5FA"

    // ==== Success / Error (мягкие) ====
    property color colorSuccess: "#34D399"
    property color colorError: "#F87171"
    property color colorWarning: "#FBBF24"
    property color colorNeutral: "#9e9e9e"
    // ==== Pills ====
    property color colorPillBg: "#3F5A72"
    property color colorPillText: "#FFFFFF"

    // ==== Buttons ====
    property color colorButtonPrimary: "#3B82F6"
    property color colorButtonPrimaryHover: "#2563EB"
    property color colorButtonSecondary: "#475569"
    property color colorButtonSecondaryHover: "#64748B"
    property color colorButtonDisabled: "#bdc3c7"

    // ==== Sizes ====
    property int radiusCard: 12
    property int radiusPill: 999
    property int radiusButton: 8

    property int fontTitle: 20
    property int fontSubtitle: 16
    property int fontBody: 14
    property int fontSmall: 12
}
