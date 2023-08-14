package main

import (
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

const (
	queueURL    = "http://localstack:4566/000000000000/sample-queue"
	endpointURL = "http://localstack:4566"
	region      = "ap-northeast-1"
)

var svc *sqs.SQS

func retrieveMessage() error {
	// メッセージを取得
	receiveParams := &sqs.ReceiveMessageInput{
		QueueUrl:            aws.String(queueURL),
		MaxNumberOfMessages: aws.Int64(10),
		WaitTimeSeconds:     aws.Int64(10),
	}
	res, err := svc.ReceiveMessage(receiveParams)

	if err != nil {
		return err
	}
	if len(res.Messages) == 0 {
		return nil
	}

	fmt.Println("--- retrived message ---")
	for _, msg := range res.Messages {
		fmt.Println(*msg.Body)

		// 受け取り完了したメッセージを削除
		_, err := svc.DeleteMessage(&sqs.DeleteMessageInput{
			QueueUrl:      aws.String(queueURL),
			ReceiptHandle: msg.ReceiptHandle,
		})

		if err != nil {
			return err
		}
	}
	return nil
}

func main() {
	// localstackへのアクセス設定
	session := session.Must(session.NewSessionWithOptions(
		session.Options{
			Config: aws.Config{
				CredentialsChainVerboseErrors: aws.Bool(true),
			},
		},
	))
	// SQSクライアントの作成
	svc = sqs.New(session, aws.NewConfig().WithRegion(region).WithEndpoint(endpointURL))

	// 1秒ごとにメッセージを取得
	for {
		if err := retrieveMessage(); err != nil {
			fmt.Fprintln(os.Stderr, err.Error())
		}
		time.Sleep(time.Second)
	}
}
