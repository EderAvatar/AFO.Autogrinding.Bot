SetWorkingDir %A_ScriptDir%

Mine1xPos := 170
Mine1yPos := 175
Mine2xPos := 510
Mine2yPos := 175
Mine3xPos := 850
Mine3yPos := 175
Mine4xPos := 170
Mine4yPos := 470
Mine5xPos := 510
Mine5yPos := 470
Mine6xPos := 850
Mine6yPos := 470

Loop, read, Credentials.csv
{
    Credentials_j := A_Index
    Loop, parse, A_LoopReadLine, CSV
    {
		Credentials_k := A_Index
		Credentials%Credentials_j%_%Credentials_k% := A_LoopField
    }
}

WaitForColors(ColorsToWaitFor, xpos, ypos, TimeOut) {								; Waits for a color at specified position. Exits the script if the timeout is reached.
    TimeOutStart := A_TickCount														; 	Separate the colors with space
    PixelGetColor, color, %xpos%, %ypos%
    While !InStr(ColorsToWaitFor, color) {
        PixelGetColor, color, %xpos%, %ypos%
        TimeOutElapsed := A_TickCount - TimeOutStart
        If TimeOutElapsed > %TimeOut%
            return False
    }
    return color
}

Login(Account, Password) {
	Click 515, 455																	; Clicking the login button
	Send %Account%{Enter}%Password%{Enter}{Enter}
	If !WaitForColors(0x152C36, 5, 30, 10000)										; Dark top left of the main screen
		Exit
	If !DetectedColorCenter := WaitForColors(0xA8E7F9 0x9FE1F6, 500, 400, 10000)
		Exit
	Else If DetectedColorCenter = 0xA8E7F9											; Personal Info Safety badge
	{
		Send {Esc}
		If !WaitForColors(0x346D87, 5, 30, 10000)									; Light top left of the main screen
			Exit
	}
	Else If DetectedColorCenter = 0x9FE1F6											; Daily Reward badge
	{
		Send {Esc}
		If WaitForColors(0x162D54, 630, 400, 2000)									; Wait for the level-up badge and press Esc if it appears
		{	
			Send {Esc}
			Sleep 2000
		}
		If !WaitForColors(0xA8E7F9, 500, 400, 1000)									; Personal Info Safety badge
			Send {Esc}
		Send {Esc}
		If !WaitForColors(0x346D87, 5, 30, 10000)									; Light top left of the main screen
			Exit
	}
}

Logout() {
	Click 975, 135
	Click 520, 400
	Sleep 100
}

EnrollContest() {
	Click 80, 600
	Click 370, 550
	Click 250, 300
	If !WaitForColors(0xB5F3FE, 1020, 620, 10000)
		Exit
	Click 320, 70
	If !Colour := WaitForColors(0xB7DCDA 0x1255A6, 520, 440, 1000)
		Exit
	Else If Colour = 0xB7DCDA														; Already enrolled. No button.
	{
		Send {Esc}
		Send {Esc}
	}
	Else If Colour = 0x1255A6														; Not enrolled. Button detected.
	{
		Click 520, 440
		If WaitForColors(0xA4E2F6, 520, 400, 10000)									; Enrolled badge
			Send {Esc}
	}
}

ClickMine(xpos, ypos) {
	dxpos := xpos + 100
	If !WaitForColors(0x24AE84, 5, 30, 10000)
		Exit
	Sleep 500
	Click %xpos%, %ypos%
	If !WaitForColors(0x0E4635, 5, 30, 1000)										; Wait for dark in top left. On timeout try clicking the 10 button and return
	{
		Click %dxpos%, %ypos%
		WaitForColors(0x0E4635, 5, 30, 1000)										; Wait for the very short loading screen after successfully clicking the 10 button
		If !WaitForColors(0x24AE84, 5, 30, 10000)
			Exit
		return
	}
	Else If !DetectedColorCenter := WaitForColors(0x9FE1F5, 380, 300, 10000)		; Wait for the badge
		Exit
	Else If DetectedColorCenter = 0x9FE1F5
	{
		Send {Esc}
		If !WaitForColors(0x24AE84, 5, 30, 10000)
			Exit
		Sleep 500
		Click %xpos%, %ypos%
		Sleep 500
		Click %dxpos%, %ypos%
		WaitForColors(0x0E4635, 5, 30, 10000)										; Wait for the very short loading screen after successfully clicking the 10 button
		If !WaitForColors(0x24AE84, 5, 30, 10000)
			Exit
		return
	}
}

ClickMineMatSymbol(xpos, ypos) {
	ULx := xpos - 150
	ULy := ypos - 150
	BRx := xpos + 150
	BRy := ypos + 150
	Materials1 := "Stone"
	Materials2 := "Wood"
	Materials3 := "Iron"
	Loop 3 {
		MaterialString := Materials%A_Index%
		ImageSearch, FoundX, FoundY, %ULx%, %ULy%, %BRx%, %BRy%, %A_WorkingDir%\images\%MaterialString%Mine10.bmp
		If !ErrorLevel
		{
			Click %FoundX%, %FoundY%
			return
		}
		Else If ErrorLevel = 1
		{
			Continue
		}
		Else
			Exit
	}
	return False
}

$F1::
IfWinExist BlueStacks App Player for Windows (beta-1)
{
	WinActivate
	PixelGetColor, color, 10, 90
	If color != 0xA4CFD2
	{
		Exit
	}
	Loop %Credentials_j%
	{
		Gosub, TheRoutine
	}
}
else
{
	Run %A_ProgramFiles%\BlueStacks\HD-RunApp.exe Android com.jiuzhangtech.arena com.jiuzhangtech.arena.SplashActivity
	WinWait BlueStacks App Player for Windows (beta-1)
	WinActivate
}
return

TheRoutine:
Logout()
usr := Credentials%A_Index%_1
pw := Credentials%A_Index%_2
Login(usr, pw)
Click 750, 400
NumberOfMines := Credentials%A_Index%_3
Loop %NumberOfMines%
{
	ClickMine(Mine%A_Index%xPos, Mine%A_Index%yPos)
}
Sleep 1000
Send {Esc}
EnrollContest()
return

$F2::
Reload
Sleep 1000
return

$F3::
Materials1 := "Stone"
Materials2 := "Wood"
Materials3 := "Iron"
Loop 3 {
	If !WaitForColors(0x346D87, 5, 30, 10000)									; Light top left of the main screen
		Exit
	Sleep 100
	Click 900, 250
	If !WaitForColors(0x064589, 1010, 80, 10000)
		Exit
	Sleep 100
	Click 350, 50
	Sleep 100
	Loop 5 {
		Send {Down}
	}
	Send {Enter}
	If !WaitForColors(0x68C7E7, 350, 420, 10000)
		Exit
	Sleep 100
	MaterialString := Materials%A_Index%
	ImageSearch, FoundX, FoundY, 380, 240, 650, 400, %A_WorkingDir%\images\%MaterialString%.bmp
	If !ErrorLevel
		Click %FoundX%, %FoundY%
	Else If ErrorLevel = 1
	{
		Send {Esc}
		Send {Esc}
		Continue
	}
	Else
		Exit
	If !WaitForColors(0x001E6B, 645, 400, 1000)
		Exit
	Loop 20 {
		Sleep 100
		Click 560, 340														; Clicking the plus sign
	}
	Sleep 100
	Click 520, 410
	If !DetectedColor := WaitForColors(0x001E6B 0x6FCFEA, 645, 400, 10000)
		Exit
	Else If DetectedColor = 0x001E6B
	{
		Send {Esc}
		Send {Esc}
	}
	Else If DetectedColor = 0x6FCFEA
	{
		Send {Esc}
		Send {Esc}
		Send {Esc}
		Send {Esc}
	}
}
return