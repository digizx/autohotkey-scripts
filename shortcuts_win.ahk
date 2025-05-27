; AutoHotkey v2 script for launching/cycling through applications with Alt Gr shortcuts
; First press: Launch or show app. Subsequent presses: cycle through instances
; Save this file with .ahk extension and run it

#SingleInstance Force

global LastWindowIndex := Map()

CycleWindows(exeName, appCommand := "") {
    static LastWindowIndex := Map()

    ; Get the currently focused window's exe name
    focusedHwnd := WinExist("A")
    focusedExe := ""
    if (focusedHwnd) {
        try focusedExe := WinGetProcessName(focusedHwnd)
    }

    ; Retrieve all window handles for the executable
    windows := WinGetList("ahk_exe " . exeName)
    
    ; Convert all HWNDs to integers and store in array
    sorted := []
    for hwnd in windows
        sorted.Push(Integer(hwnd))
    
    ; Sort using a custom comparison - create new sorted array
    sortedTemp := []
    for hwnd in sorted {
        inserted := false
        for i, existingHwnd in sortedTemp {
            if (hwnd < existingHwnd) {
                sortedTemp.InsertAt(i, hwnd)
                inserted := true
                break
            }
        }
        if (!inserted)
            sortedTemp.Push(hwnd)
    }
    sorted := sortedTemp
    
    ; Convert back to hex strings with "ahk_id " prefix
    formatted_hex_ids := [] ; Create a new array to store the formatted strings
    For each, hwnd_integer in sorted ; Iterate through the 'sorted' array (which contains integer HWNDs at this point)
    {
        ; Format each integer HWND into the "ahk_id 0x..." string format
        formatted_string := "ahk_id " . Format("0x{:x}", hwnd_integer)
        ; Add the formatted string to our new array
        formatted_hex_ids.Push(formatted_string)
    }
    sorted := formatted_hex_ids ; Replace the 'sorted' array with the new array of formatted strings

    if (sorted.Length = 0) {
        if (appCommand != "")
            Run(appCommand)
        return
    }

    ; Get current index or default to 0
    lastIndex := LastWindowIndex.Has(exeName) ? LastWindowIndex[exeName] : 0
    
    ; If current window is not from the same app, just activate the last used window
    if (focusedExe != exeName) {
        lastIndex := LastWindowIndex.Has(exeName) ? LastWindowIndex[exeName] : 1
        WinActivate(formatted_hex_ids[lastIndex])
        return
    }

    ; Calculate next index
    nextIndex := Mod(lastIndex, sorted.Length) + 1
    
    ; Update stored index
    LastWindowIndex[exeName] := nextIndex
    
    ; Activate the target window
    WinActivate(sorted[nextIndex])
}

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
    CycleWindows("Code.exe", '"%HOMEPATH%\AppData\Local\Programs\Microsoft VS Code\Code.exe"')
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

; Terminal from Microsoft Store - Alt Gr + T
RAlt & t:: {
    CycleWindows("WindowsTerminal.exe", "wt")
}

; Notepad++ - Alt Gr + N
RAlt & n:: {
    CycleWindows("notepad++.exe", "notepad++")
}

; Explorer - Alt Gr + X
RAlt & f:: {
    CycleWindows("explorer.exe", "explorer")
}

; Optional: Add a hotkey to reload this script (Alt Gr + R)
RAlt & r:: {
    Reload()
}
