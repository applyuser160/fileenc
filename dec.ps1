##################################################
# 公開鍵 暗号化
##################################################
function RSAEncrypto($PublicKey, $PlainString){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # バイト配列にする
    $ByteData = [System.Text.Encoding]::UTF8.GetBytes($PlainString)

    # RSACryptoServiceProviderオブジェクト作成
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider

    # 公開鍵を指定
    $RSA.FromXmlString($PublicKey)

    # 暗号化
    $EncryptedData = $RSA.Encrypt($ByteData, $False)

    # 文字列にする
    $EncryptedString = [System.Convert]::ToBase64String($EncryptedData)

    # オブジェクト削除
    $RSA.Dispose()

    return $EncryptedString
}

##################################################
#  鍵を作成し CSP キーコンテナに保存
##################################################
function RSACreateKeyCSP($ContainerName){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # CspParameters オブジェクト作成
    $CSPParam = New-Object System.Security.Cryptography.CspParameters

    # マシンストアを使用する(デフォルトはユーザーストア。これを有効にするとマシンストアが使用される)
    # $CSPParam.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    # CSP キーコンテナ名
    $CSPParam.KeyContainerName = $ContainerName

    # RSACryptoServiceProviderオブジェクト作成し秘密鍵を格納
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider($CSPParam)

    # 公開鍵
    $PublicKey = $RSA.ToXmlString($False)

    # オブジェクト削除
    $RSA.Dispose()

    return $PublicKey
}

#####################################################################
#  CSP キーコンテナに保存されている秘密鍵を使って文字列を復号化する
#####################################################################
function RSADecryptoCSP($ContainerName, $EncryptoString){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # バイト配列にする
    $ByteData = [System.Convert]::FromBase64String($EncryptoString)

    # CspParameters オブジェクト作成
    $CSPParam = New-Object System.Security.Cryptography.CspParameters

    # マシンストアを使用する(デフォルトはユーザーストア。これを有効にするとマシンストアが使用される)
    # $CSPParam.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    # CSP キーコンテナ名
    $CSPParam.KeyContainerName = $ContainerName

    # RSACryptoServiceProviderオブジェクト作成し秘密鍵を取り出す
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider($CSPParam)

    # 復号
    $DecryptedData = $RSA.Decrypt($ByteData, $False)

    # 文字列にする
    $PlainString = [System.Text.Encoding]::UTF8.GetString($DecryptedData)

    # オブジェクト削除
    $RSA.Dispose()

    return $PlainString
}

##################################################
# CSP キーコンテナ削除
##################################################
function RSARemoveCSP($ContainerName){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # CspParameters オブジェクト作成
    $CSPParam = New-Object System.Security.Cryptography.CspParameters

    # マシンストアを使用する(デフォルトはユーザーストア。これを有効にするとマシンストアが使用される)
    # $CSPParam.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    # CSP キーコンテナ名
    $CSPParam.KeyContainerName = $ContainerName

    # RSACryptoServiceProviderオブジェクト作成
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider($CSPParam)

    # CSP キーコンテナ削除
    $RSA.PersistKeyInCsp = $False
    $RSA.Clear()

    # オブジェクト削除
    $RSA.Dispose()

    return
}

##################################################
# CSP キーコンテナのエクスポート
##################################################
function RSAExportCSP($ContainerName){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # CspParameters オブジェクト作成
    $CSPParam = New-Object System.Security.Cryptography.CspParameters

    # マシンストアを使用する(デフォルトはユーザーストア。これを有効にするとマシンストアが使用される)
    # $CSPParam.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    # CSP キーコンテナ名
    $CSPParam.KeyContainerName = $ContainerName

    # RSACryptoServiceProviderオブジェクト作成
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider($CSPParam)

    # エクスポート
    $ByteData = $RSA.ExportCspBlob($True)

    # 文字列にする
    $ExpoprtString = [System.Convert]::ToBase64String($ByteData)

    # オブジェクト削除
    $RSA.Dispose()

    return $ExpoprtString
}

##################################################
# CSP キーコンテナのインポート
##################################################
function RSAImportCSP($ContainerName, $ExpoprtString){
    # アセンブリロード
    Add-Type -AssemblyName System.Security

    # バイト配列にする
    $ByteData = [System.Convert]::FromBase64String($ExpoprtString)

    # CspParameters オブジェクト作成
    $CSPParam = New-Object System.Security.Cryptography.CspParameters

    # マシンストアを使用する(デフォルトはユーザーストア。これを有効にするとマシンストアが使用される)
    # $CSPParam.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    # CSP キーコンテナ名
    $CSPParam.KeyContainerName = $ContainerName

    # RSACryptoServiceProviderオブジェクト作成
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider($CSPParam)

    # インポート
    $RSA.ImportCspBlob($ByteData)

    # オブジェクト削除
    $RSA.Dispose()

    return
}

$CSPName = "MuraTest"

$path = $Args[0]
$keypath = $Args[1]

$keyString = Get-Content $keypath
RSAImportCSP $CSPName $keyString

$files =  Get-ChildItem $path -Recurse -File

foreach ($file in $files) {
    $DecryptoString = ""
    $filename = $file.FullName
    foreach($line in Get-Content $filename) {
        $DecryptoString += RSADecryptoCSP $CSPName $line
    }
    $DecryptoString | Out-File $filename -NoNewline
}

RSARemoveCSP $CSPName