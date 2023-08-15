package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
)

const (
	topicARN    = "arn:aws:sns:ap-northeast-1:000000000000:sns-sample"
	endpointURL = "http://localstack:4566"
	region      = "ap-northeast-1"
)

func main() {
	// localstackへのアクセス設定
	session := session.Must(session.NewSessionWithOptions(
		session.Options{
			Config: aws.Config{
				CredentialsChainVerboseErrors: aws.Bool(true),
			},
		},
	))
	// SNSクライアントの作成
	svc := sns.New(session, aws.NewConfig().WithRegion(region).WithEndpoint(endpointURL))

	// 200ミリ秒ごとにランダムな値を送信
	for {
		msg := &sns.PublishInput{
			Message:  aws.String(strconv.Itoa(rand.Int())),
			TopicArn: aws.String(topicARN),
		}
		messageID, err := svc.Publish(msg)
		if err != nil {
			fmt.Fprintln(os.Stderr, err.Error())
		} else {
			fmt.Println("Published: ", messageID)
		}
		time.Sleep(time.Millisecond * 100)
	}
}
