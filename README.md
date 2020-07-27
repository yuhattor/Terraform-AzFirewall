![Network Architecture](./basic_network.png)

## ローカル実行

1. secret.tfvars.sample を Rename して secret.tfvars にします。その際に、下記の変数に値を入れます。
   サービスのプリンシパルがない場合は、このガイドに従って作成してください。 https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html
   - subscription_id = Your Azure Subscription ID
   - client_id       = Your Azure Service Principal App ID
   - client_secret   = Your Azure Service Principal Client Secret
   - tenant_id       = Your Azure Tenant ID
   - adminpwd = Windows VM ローカル管理者パスワード (複雑で12文字の長さでなければなりません)

   この設定をAzure Pipeline で行う際には、Terraform の Action Extension を使い、外部から 変数/シークレットとして値を渡すことで Azure Pipeline の中から情報を隠蔽します。
   そのため、ローカルで実行する際にはシークレットを直接渡す必要があります。secret.tfvars は .gitignore 内に定義され、ソースコード管理からは除外されます。

2. terraform.tfvars ファイルを開き、値を確認します。ハンズオンにおいては変更する必要はありませんが、必要に応じて値を入れ替えてください。
   - location = デプロイしたいAzureリージョン
   - adminname = Windows VM ローカル管理者名
   - vmsize = "Standard_D2s_v3" (使用したいAzure VMのサイズ、必要に応じて変更)
   - frontdoorname = Azure Front Door ホスト名。これは後にFront Doorにアクセスする際に使用する名前で、一意でなければなりません。 例: myfrontdoor01.azurefd.net

   ご参考: Azure Cloud Shell を使用して terraform テンプレートを実行することができます(https://shell.azure.com ) 

   この値は、Git において管理される必要があるので、変更されるたびに値が リモートのブランチにも反映されます。


3. Provider の設定をします
   1の手順で Service Principal の情報を渡しましたが、ローカルで実行する際にはそれを渡す必要があります。

   1. provider.tf.sample を provider.tf に Rename します。
   2. providervariables.tf.sampleを providervariables.tf に Rename します。
   
   この値は、Azure Pipelines 上では Terraform の Action (TerraformTaskV1@0) で定義されるため、ソースコード管理には含みません。あくまでもローカル用であるため .gitignore に記載があります。

5. terraform環境を初期化します。
   
   > terraform init
   
6. terraformの導入を計画し、レビューします。
   
   > terraform plan -var-file=secret.tfvars
   
7. terraformテンプレートを適用します。

   > terraform apply -var-file=secret.tfvars


# リモート

1. azure-pipelines.yml で定義されている内容を確認します。
   1. variables では主に Azure Pipelines で実行される Terraform の state を管理するための変数が定義されています。
      Terraform ではローカル実行の際に terraform.tfstate のファイルが作られて state が管理されますが、Azure Pipelines においては値を保持することができないため、Blob Storage を利用します。

   2. step: terraformInstaller@0
      Terraform 特定の version がインストールされます。

   3. task: AzureCLI@2 : "Create/Check the Terraform Statefile Azure Storage Account"
      上記の variables で記載された値にそって Blob Storage が作成されます。作成済みの場合はスキップします。
   
   4. Bash@3 : backend の設定
      backend.tf.base ファイルを backend.tf の名前でワーキングディレクトリにコピーします。
      backend.tf.base を見ると backend "azurerm" {} が指定され、Terraform が設定のために使うファイル郡が初期化されます。
      このファイルの中には、.tfstate ファイルの置き場所に関する設定も含まれます。ローカルの場合デフォルトの設定が適用され、ローカルに terraform.tfstate を作りますが、Azure Pipelines においては .tfstate のファイルは 先ほど作成した blob storage に保存したいので、この値を初期化して、次の TerraformTaskV1@0 の init で設定する値で上書きする必要があります、

   5. TerraformTaskV1@0 : terraform init
      Terraform を初期化します。その際に backend の設定を Azure Blob Storage に設定します。

   6. task: TerraformTaskV1@0: terraform plan
      terraform plan で 実行されるプランの内容が出力される定義内容が意図した通りに反映されるかを確認します。
      1. この際に、Service Principal の値は TerraformTaskV1 で渡され、SERVICECONNECTION_NAME から特定の subscription のクレデンシャル情報が参照されるようになります。この値は Azure Pipelines の Variable から渡されます。
      2. commandOptions にて "adminpwd=$(ADMINPWD)" が渡されていますが、これは windows server のパスワードです。こちらも Azure Pipelines の variable より渡されます。
      3. commandOptions にてもう一つ、-var "env=$(ENV_NAME)" が渡されていますが、これは Azure Resource を作る際の識別詞で、prefix や postfix につけて、それぞれの環境で conflict が起きないように設定されています。こちらも Azure Pipelines の variable から渡されますが、社員ID など、ユニークな値にする必要があります。

   7. task: TerraformTaskV1@0: apply
      terraform の plan が成功したら値を反映させます。変数は plan と同様です。

2. Azure Pipelines で Service Connection の設定をします。
   今回のハンズオンでは、Terraform 自体が Resource Group から作る設定になっているので、 Subscription レベルの接続が必要です。
   下記を参考に作成してください。Resource Group は空欄で作ります。
   https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml

   ご参考
   - ハンズオンリポジトリに含まれる moduled-sample のようにモジュール化して手順を分けたり、Resource Group の作成については手動で行うことで権限を最小に抑えることはできますが、Terraform においては Resource Group から作成させた方がシンプルに管理できます。
   - また、https://github.com/microsoft/terraform-azure-devops-starter にある Advanced の内容である 201-plan-apply-stages / 301-deploy-agent-vms を参考に、プロセスを分けることで管理を分離させたり環境を Azure Pipelines レベルで分けることもできます。
   - 手動で Azure Resource Group を作り権限を付与するなど、手動のプロセスが含まれる場合は、terraform import のコマンドを使って現在の環境を import するなど、追加のプロセスが必要になります。

3. Azure Pipelines の Variable を設定します。設定する内容は 

   - ADMINPWD: YourComplexPasswordwith12char のような値を入れます。またこの情報は漏れてはならない情報なので、"Keep this value secret" にチェックをつけて Azure Pipelines のログ含め全ての情報から隠蔽します。チェックをつけた場合、一度入力した値は再度見ることができなくなります。
   - ENV_NAME: 社員ID など(ex: 社員ID が ABC123 の場合はそれを入力。あまり長いと storage account の尺制限に引っかかったりするので、簡潔かつユニークなものを推奨します。)
   - SERVICECONNECTION_NAME: 2 で作成した Service Connection の名前を入力します

4. Azure Pipelines を run します。
![Azure Pipelines](https://yuhattor.blob.core.windows.net/share/Screen%20Shot%202020-07-27%20at%2012.22.02.png)

# テストする

下記のように構成されているか確認をします。

![Network Architecture](./basic_network.png)

* FrontDoorのホスト名（例：myfrontdoor.azurefd.net）を取得し、お好きなインターネットブラウザを使ってアクセスしてください。
  * ウェブサイトはHTTP（TCP 80）ポートにのみ応答するため、HTTPを使用する必要があります： http://myfrontdoor.azurefd.net (ご自身の値にかえてご参照ください。)
  * Spoke VNET上のWebアプリケーションにアクセスできるはずです。
  * アクセスはAzure Front DoorからAzure Firewallに流れていますが、Azure FirewallではNATルールがあり、プライベートIP経由でWebサイトを公開している内部のロードバランサーに通信を送信しています。
* ネットワークの基本ガイドのエクササイズ11に従ってください: https://github.com/adicout/lab/tree/master/Network/basic-networking

## すべてのリソースをクリンナップする

Azure NetworkingのTerraformラボを無事に終了したら、Resource Groupsを削除します。以下のterraformコマンドを実行します。

   > terraform destroy