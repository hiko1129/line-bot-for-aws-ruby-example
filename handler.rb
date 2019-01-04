require 'json'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_ACCESS_TOKEN"]
  end
end

def reply_text(event, text)
  client.reply_message(
    event['replyToken'],
    { type: 'text', text: text }
  )
end

def handle_message(event)
  case event.type
  when Line::Bot::Event::MessageType::Text
    reply_text(event, event.message['text'])
  else 
    reply_text(event, "I don't know.")
  end
end

def handle(event:, context:)
  body = event['body']
  signature = event['headers']['X-Line-Signature']
  return { statusCode: 400 } unless client.validate_signature(body, signature)

  events = client.parse_events_from(body)
  events.each do |_event|
    case _event
    when Line::Bot::Event::Message
      handle_message(_event)
    when Line::Bot::Event::Follow
      reply_text(_event, "Thank you for following")
    when Line::Bot::Event::Join
      reply_text(_event, "Thank you for joining")
    end
  end

  { statusCode: 200 }
end
