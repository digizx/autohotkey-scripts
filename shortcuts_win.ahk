; AutoHotkey v2 script for launching/cycling through applications with Alt Gr shortcuts
; First press: Launch or show app. Subsequent presses: cycle through instances
; Save this file with .ahk extension and run it

#SingleInstance Force

; Global map to store last window index for each application
global LastWindowIndex := Map()

/**
 * Cycles through windows of a specific application or launches it if not running
 * @param exeName - The executable name to look for (e.g., "chrome.exe")
 * @param appCommand - Command to run if no windows are found (optional)
 */
CycleWindows(exeName, appCommand := "") {
    ; Get currently focused window info
    focusedHwnd := WinExist("A")
    focusedExe := ""
    
    if (focusedHwnd) {
        try {
            focusedExe := WinGetProcessName(focusedHwnd)
        }
    }

    ; Get all windows for this executable
    windowIds := WinGetList("ahk_exe " . exeName)
    
    ; If no windows found, launch the application
    if (windowIds.Length = 0) {
        if (appCommand != "") {
            Run(appCommand)
        }
        return
    }

    ; Convert to sorted array of window identifiers
    sortedWindows := SortWindowIds(windowIds)
    
    ; Handle window cycling logic
    HandleWindowCycling(exeName, sortedWindows, focusedExe)
}

/**
 * Sorts window IDs and converts them to the proper format
 * @param windowIds - Array of window IDs from WinGetList
 * @return Array of sorted window identifiers in "ahk_id 0x..." format
 */
SortWindowIds(windowIds) {
    ; Convert to integers for proper sorting
    integerIds := []
    for hwnd in windowIds {
        integerIds.Push(Integer(hwnd))
    }
    
    ; Simple bubble sort (could use built-in sort in newer AHK versions)
    for i in Range(1, integerIds.Length - 1) {
        for j in Range(1, integerIds.Length - i) {
            if (integerIds[j] > integerIds[j + 1]) {
                ; Swap elements
                temp := integerIds[j]
                integerIds[j] := integerIds[j + 1]
                integerIds[j + 1] := temp
            }
        }
    }
    
    ; Convert back to formatted strings
    formattedIds := []
    for hwnd in integerIds {
        formattedIds.Push("ahk_id " . Format("0x{:x}", hwnd))
    }
    
    return formattedIds
}

/**
 * Handles the logic for cycling through windows
 * @param exeName - The executable name
 * @param windows - Array of sorted window identifiers
 * @param focusedExe - Currently focused executable name
 */
HandleWindowCycling(exeName, windows, focusedExe) {
    ; Get last used index, default to 1 if not found
    lastIndex := LastWindowIndex.Has(exeName) ? LastWindowIndex[exeName] : 1
    
    ; Ensure lastIndex is within valid bounds (fix for the bug)
    if (lastIndex > windows.Length || lastIndex < 1) {
        lastIndex := 1
    }
    
    ; If current window is not from the same app, activate the last used window
    if (focusedExe != exeName) {
        ActivateWindowSafely(windows[lastIndex])
        return
    }

    ; Calculate next index (cycle through windows)
    nextIndex := (lastIndex >= windows.Length) ? 1 : lastIndex + 1
    
    ; Update stored index
    LastWindowIndex[exeName] := nextIndex
    
    ; Activate the next window
    ActivateWindowSafely(windows[nextIndex])
}

/**
 * Safely activates a window with error handling
 * @param windowId - Window identifier to activate
 */
ActivateWindowSafely(windowId) {
    try {
        WinActivate(windowId)
    } catch Error as err {
        ; If window no longer exists, we'll just ignore the error
        ; The next cycle will refresh the window list
    }
}

/**
 * Creates a range for iteration (helper function)
 * @param start - Start value
 * @param end - End value
 * @return Array of numbers from start to end
 */
Range(start, end) {
    result := []
    loop end - start + 1 {
        result.Push(start + A_Index - 1)
    }
    return result
}

; =============================================================================
; HOTKEY DEFINITIONS
; =============================================================================

; Chrome - Alt Gr + S
RAlt & s:: {
    CycleWindows("chrome.exe", "chrome.exe")
}

; Microsoft Edge - Alt Gr + E
RAlt & e:: {
    CycleWindows("msedge.exe", "msedge.exe")
}

; Visual Studio Code - Alt Gr + C
RAlt & c:: {
    CycleWindows("Code.exe", '"%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe"')
}

; Visual Studio - Alt Gr + V
RAlt & v:: {
    ; Update path to your Visual Studio installation
    CycleWindows("devenv.exe", '"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"')
}

; Postman - Alt Gr + P
RAlt & p:: {
    CycleWindows("Postman.exe", "postman")
}

; SQL Server Management Studio (SSMS) - Alt Gr + Q
RAlt & q:: {
    ; Update path to your SSMS installation
    CycleWindows("Ssms.exe", '"C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Ssms.exe"')
}

; Windows Terminal - Alt Gr + T
RAlt & t:: {
    CycleWindows("WindowsTerminal.exe", "wt")
}

; Notepad++ - Alt Gr + N
RAlt & n:: {
    CycleWindows("notepad++.exe", "notepad++")
}

; File Explorer - Alt Gr + F
RAlt & f:: {
    CycleWindows("explorer.exe", "explorer")
}

; Reload script - Alt Gr + R
RAlt & r:: {
    Reload()
}

; Optional: Show help message - Alt Gr + H
RAlt & h:: {
    helpText := "
    (
    AutoHotkey Window Cycling Shortcuts:
    
    Alt Gr + S = Chrome
    Alt Gr + E = Edge
    Alt Gr + C = VS Code
    Alt Gr + V = Visual Studio
    Alt Gr + P = Postman
    Alt Gr + Q = SQL Server Management Studio
    Alt Gr + T = Windows Terminal
    Alt Gr + N = Notepad++
    Alt Gr + F = File Explorer
    Alt Gr + R = Reload this script
    Alt Gr + H = Show this help
    )"
    
    MsgBox(helpText, "Window Cycling Help", "OK")
}