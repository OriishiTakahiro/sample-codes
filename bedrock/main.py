import boto3
import json
import base64


# 画像はbase64エンコードして送信する
encoded_img = ''
with open('./sample_table.png', 'rb') as f:
    encoded_img = base64.b64encode(f.read()).decode('utf-8')

# 画像はbase64エンコードして送信する
prompt = ''''
あなたはベテランのデータベースエンジニアです。
画像の表を正規化し、テーブル定義に落とし込んでください。
適切なリレーションや制約条件の付与も行ってください。
結果はSQLのみで、解説は不要です。
'''

body = json.dumps({
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 2048,
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "image",
            "source": {
              "type": "base64",
              "media_type": "image/png",
              "data": encoded_img
            }
          },
          {
            "type": "text",
            "text": prompt,
          }
        ]
      }
    ]
})

# boto3からbedrockへリクエスト
# Claude3 Sonnetはバージニアリージョンのみ対応
bedrock = boto3.client(service_name='bedrock-runtime', region_name='us-east-1')
res = bedrock.invoke_model(
    body=body,
    modelId='anthropic.claude-3-sonnet-20240229-v1:0',
    accept='application/json',
    contentType='application/json',
)
res_body = json.loads(res.get('body').read())
print(res_body.get('content')[0].get('text'))