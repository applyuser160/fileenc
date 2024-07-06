# Usage

## Compile
1. Install `ps2exe`
``` powershell
Install-Module ps2exe
```
2. Compile
``` powershell
Invoke-PS2EXE ./enc.ps1 ./enc.exe
Invoke-PS2EXE ./dec.ps1 ./dec.exe
```

## Encrypt
1. Get the path of the folder you want to encrypt.
2. Run the following command:
``` powershell
./enc.exe {folder path}
```

## Decrypt
1. Get the path of the encrypted folder.
2. Get the path to the file where the key is stored
3. Run the following command:
``` powershell
./dec.exe {folder path} {key path}
```