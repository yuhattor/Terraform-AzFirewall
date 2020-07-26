# リソースグループの名前
rgname = "AzFirewall-Handson"

# リソースロケーション
location = "japaneast"

# プレフィックス
prefix = "mypref"

# Windows VM のadminユーザー
adminname = "yuhattor3"

# Windows VM のサイズ
vmsize = "Standard_D2s_v3"

# Azure FrontDoor の名前
frontdoorname = "yuhattor3"

### Hands on においては fixed
# IIS の設定、デプロイのスクリプト(Fixed)
scriptiis = "https://yuhattor.blob.core.windows.net/share/deploy-iis.ps1"

# ICMP を enable にするスクリプト(Fixed)
scriptping = "https://yuhattor.blob.core.windows.net/share/enable-icmp.ps1"
