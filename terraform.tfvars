### Hands on においては fixed. Azure Pipelines で上書き
# 環境の名前 (dev, staging... handson の場合は識別名)
env = "local"

# リソースグループの名前
rgname = "AzFirewall-Handson-RG"

# Azure FrontDoor の名前
frontdoorname = "azfwfrontdoor"

# Log Analytics の名前
loganalytics = "azfwanalytics"

# リソースロケーション
location = "japan east"

# Windows VM のadminユーザー
adminname = "user"

# Windows VM のサイズ
vmsize = "Standard_D2s_v3"

# IIS の設定、デプロイのスクリプト(Fixed)
scriptiis = "https://yuhattor.blob.core.windows.net/share/deploy-iis.ps1"

# ICMP を enable にするスクリプト(Fixed)
scriptping = "https://yuhattor.blob.core.windows.net/share/enable-icmp.ps1"

