## Auroraへのセキュアなメンテナンス環境

SSM Session Managerとポートフォワードを用いたインバウンド方向の穴あけ不要な環境のサンプル

### 実行方法

```sh
$ terraform init
$ terraform apply

$ aws ssm start-session \
    --target <踏み台のインスタンスID> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["<>"],"portNumber":["5432"], "localPortNumber":["5432"]}
```
