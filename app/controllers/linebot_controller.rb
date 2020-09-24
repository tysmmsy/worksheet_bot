class LinebotController < ApplicationController
  require 'line/bot'
  
  protect_from_forgery :expect => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.massage['text'].eql?('アンケート')
            client.reply_message(event['replyToken'], template)
          end
        end
      end
    }

    head :ok
  end

  private

  def template
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
        "type": "confirm",
        "text": "今日の学習時間は10時間以上ですか？",
        "actions": [
          {
            "type": "message",
            # Botから送られてくる文字列
            "label": "はい",
            # ボタンを押したときにBotに送られる文字列
            "text": "はい"
          },
          {
            "type": "message",
            "label": "いいえ",
            "text": "いいえ"
;          }
        ]
      }
    }
  end
end
