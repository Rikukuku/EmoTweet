module ApplicationHelper
  def get_twitter_card_info(post)
    twitter_card = {}
    if post.present?
      if post.id.present?
        twitter_card[:url] = "https://emotionaltweet.herokuapp.com/posts/#{post.id}"
        twitter_card[:image] = "https://s3-ap-northeast-1.amazonaws.com/emotionaltweet-production/images/#{post.id - 9}.png"
      else
        twitter_card[:url] = 'https://emotionaltweet.herokuapp.com/'
        twitter_card[:image] = "https://raw.githubusercontent.com/Rikukuku/emotionaltweet/master/app/assets/images/top.png"
      end
    else
      twitter_card[:url] = 'https://emotionaltweet.herokuapp.com/'
      twitter_card[:image] = "https://raw.githubusercontent.com/Rikukuku/emotionaltweet/master/app/assets/images/top.png"
    end
    twitter_card[:title] = "エモツイ"
    twitter_card[:card] = 'summary_large_image'
    twitter_card[:description] = '登録不要!感情をのせまくろう'
    twitter_card
  end
end
