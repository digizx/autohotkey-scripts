/* 
There's this website that you can create a map in Minecraft using a simple image: https://rebane2001.com/mapartcraft/
This is a macro that takes N amount of images, transforms them into dat files and saves them using this website. Yes, this is skill issue for me.
*/

/* SET UP */

Esc::ExitApp ; Necessary unless you want the computer to go crazy if there's an error going on

WinActive('Google Chrome')

WinMaximize('Google Chrome')

CoordMode('Mouse', 'Screen')

MouseMove(126, 365) ; block selection combo
Click('Left')
Sleep(300)

MouseMove(126, 412) ; everything
Click('Left')
Sleep(300)

MouseMove(1279, 367) ; settings combo
Click('Left')
Sleep(300)

MouseMove(1279, 416) ; dat
Click('Left')
Sleep(300)

/* LOOP */

Loop 590
{
    MouseMove(867, 486) ; open choose image menu
    Click('Left')
    Sleep(500)

    SendInput('odore') ; type the image we want
    SendInput(A_Index)

    Send('{Down}') ; select the image
    Sleep(500)
    Send('{Enter}')
    Sleep(500)

    MouseMove(1740, 667) ; download file
    Click('Left')
    Sleep(500)

    SendInput('odore_') ; rename the dat file
    SendInput(A_Index)
    Send('{Enter}')
    Sleep(500)
}

