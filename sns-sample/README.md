## SNSとSQSでのファンアウト

### 概要

Amazon SNSとAmazon SQSを組み合わせたファンアウトの構成をlocalstackを使って構成する。

Publisher -> SNS -> SQS -> Subscriber

### 実行方法

```sh
# コンテナビルド
$ docker compose build

# コンテナ開始
$ docker compose up

# SNSトピックの作成
$ docker compose exec localstack aws sns --endpoint-url=http://localhost:4566 create-topic --name sns-sample
{
    "TopicArn": "arn:aws:sns:ap-northeast-1:000000000000:sns-sample"
}

# SNSトピックの取得
$ docker compose exec localstack aws sns --endpoint-url=http://localhost:4566 list-topics
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:ap-northeast-1:000000000000:sns-sample"
        }
    ]
}

# SQSキューの作成
$ docker compose exec localstack \
    aws sqs create-queue --queue-name sample-queue \
    --endpoint-url http://localhost:4566
{
    "QueueUrl": "http://localhost:4566/000000000000/sample-queue"
}


# SQSキューのARN取得
$ docker compose exec localstack \
    aws sqs get-queue-attributes --queue-url http://localhost:4566/000000000000/sample-queue \
     --attribute-names All --endpoint-url http://localhost:4566
{
    "Attributes": {
        "ApproximateNumberOfMessages": "0",
        "ApproximateNumberOfMessagesNotVisible": "0",
        "ApproximateNumberOfMessagesDelayed": "0",
        "CreatedTimestamp": "1692036742",
        "DelaySeconds": "0",
        "LastModifiedTimestamp": "1692036742",
        "MaximumMessageSize": "262144",
        "MessageRetentionPeriod": "345600",
        "QueueArn": "arn:aws:sqs:ap-northeast-1:000000000000:sample-queue",
        "ReceiveMessageWaitTimeSeconds": "0",
        "VisibilityTimeout": "30",
        "SqsManagedSseEnabled": "false"
    }
}

# サブスクリプション開始
$ docker compose exec localstack \
    aws sns subscribe \
    --endpoint-url=http://localhost:4566 \
    --topic-arn arn:aws:sns:ap-northeast-1:000000000000:sns-sample \
    --protocol sqs --notification-endpoint arn:aws:sqs:ap-northeast-1:000000000000:sample-queue

# 購読確認
$ docker compose logs -f subscriber
```
