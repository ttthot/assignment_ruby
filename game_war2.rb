# トランプを各プレイヤーに分配する
class Deck
  attr_accessor :deck1, :deck2

  # 全てのカードから二人に２６枚配る
  def initialize
    @all_cards = (1..52).to_a.shuffle
    @deck1 = @all_cards[0, 26]
    @deck2 = @all_cards[26, 26]
  end
end

# 1-56の数値をトランプのカードに変換する
class Card
  attr_reader :card

  def initialize(card)
    @card = card
    @reward_cards = []
  end
  # プレイヤーの手札管理
  def convert_to_suit_and_number # rubocop:disable Layout/EmptyLineBetweenDefs,Metrics/MethodLength
    # cardが配列の場合、最初の要素を使用
    card_value = @card.is_a?(Array) ? @card.flatten.last : @card
    if card_value <= 13
      suit = 'ハート'
      num = card_value
    elsif card_value <= 26
      suit = 'ダイヤ'
      num = card_value - 13
    elsif card_value <= 39
      suit = 'スペード'
      num = card_value - 26
    else
      suit = 'クラブ'
      num = card_value - 39
    end
    [suit, num]
  end
end

# プレイヤーの行動を管理
class Player
  attr_accessor :name, :reward_cards

  def initialize(name)
    @name = name
    @reward_cards = []
  end

  def draw_card(deck)
    # 配列の末尾から要素を取り除き、その要素を返す
    deck.pop
  end
end

# ゲームの挙動を管理
class WarGame
  def initialize(player1, player2)
    puts '戦争を開始します。'
    puts 'カードが配られました。'
    @player1 = player1
    @player2 = player2
    @deck = Deck.new
    @recursion_count = 0
    @card1 = []
    @card2 = []
    @field_cards1 = []
    @field_cards2 = []
  end

  # ゲーム実行
  def play_game # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    # 手札からカードを１枚引く
    @card1 << @player1.draw_card(@deck.deck1)
    @card2 << @player2.draw_card(@deck.deck2)
   
    # 場札に各プレイヤーのカードを追加
    @field_cards1.concat(@card1)
    @field_cards2.concat(@card2)
    # puts "@deck.deck1の枚数は、#{@deck.deck1.count}です"
    # puts "@deck.deck2の枚数は、#{@deck.deck2.count}です"

    suit1, num1 = Card.new(@card1.last).convert_to_suit_and_number
    suit2, num2 = Card.new(@card2.last).convert_to_suit_and_number
    puts '戦争！'
    puts "#{@player1.name}のカードは#{suit1}の#{num1}です。"
    puts "#{@player2.name}のカードは#{suit2}の#{num2}です。"
    # 場札の比較、勝者の決仮

    winner_deck_num = showdown_with_number(num1, num2)
    # 勝者の報酬手札に報酬カードを追加
    if winner_deck_num == 1
      @player1.reward_cards.concat(@field_cards2)
      puts "#{@player1.name}が勝ち、#{@field_cards1.size + @field_cards2.size}枚のカードを獲得しました。"
      # puts "#{@player1.name}の報酬カードの枚数は#{@player1.reward_cards.size}枚です"
      # puts "#{@player2.name}のデッキの枚数は#{@deck.deck2.size}枚です"
    elsif winner_deck_num == 2
      @player2.reward_cards.concat(@field_cards1)
      puts "#{@player2.name}が勝ち、#{@field_cards1.size + @field_cards2.size}枚のカードを獲得しました。"
      # puts "#{@player2.name}の報酬カードの枚数は#{@player2.reward_cards.size}枚です"
      # puts "#{@player1.name}のデッキの枚数は#{@deck.deck1.size}枚です"
    else
      # 引き分けの場合、上記のようにカードはクレアーしない
    end
    @card1.clear
    @card2.clear
    @field_cards1.clear
    @field_cards2.clear
    # どちらかのデッキが空なら報酬手札を加える
    if @deck.deck1.empty?
      puts "#{@player1.name}の手札がなくなりました"
      puts "#{@player1.name}の手札の枚数は#{@deck.deck1.size}枚です"
      puts "#{@player2.name}の手札の枚数は#{@deck.deck2.size}枚です"
      @deck.deck1.concat(@player1.reward_cards)
      @player1.reward_cards.clear
    end
    if @deck.deck2.empty?
      puts "#{@player2.name}の手札がなくなりました"
      puts "#{@player1.name}の手札の枚数は#{@deck.deck1.size}枚です"
      puts "#{@player2.name}の手札の枚数は#{@deck.deck2.size}枚です"
      @deck.deck2.concat(@player2.reward_cards)
      @player2.reward_cards.clear
    end
    # デッキが空かどうかを判断し、空なら終了処理
    end_game?(@player1, @player2, @deck.deck1, @deck.deck2)
    play_game if !@deck.deck1.empty? && !@deck.deck2.empty?
  end

  def showdown_with_number(num1, num2) # rubocop:disable Metrics/MethodLength
    # 1は一番強いカードなので例外処理、その他は不等式処理
    if num1 == 1 && num2 != 1
      puts 'プレイヤー1が勝ちました。'
      1
    elsif num1 != 1 && num2 == 1
      puts 'プレイヤー2が勝ちました。'
      2
    elsif num1 > num2
      puts 'プレイヤー1が勝ちました。'
      1
    elsif num1 < num2
      puts 'プレイヤー2が勝ちました。'
      2
    else
      puts '引き分けです。'
      nil
    end
  end

  def end_game?(player1, player2, deck1, deck2) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    return unless deck1.empty? && player1.reward_cards.empty? || deck2.empty? && player2.reward_cards.empty?

    puts "#{deck1.empty? ? player1.name : player2.name}の手札がなくなりました。"
    puts "#{player1.name}の手札の枚数は#{deck1.size}枚です。"
    puts "#{player2.name}の手札の枚数は#{deck2.size}枚です。"

    if deck1.size > deck2.size
      puts "#{player1.name}が1位、#{player2.name}が2位です。"
    else
      puts "#{player2.name}が1位、#{player1.name}が2位です。"
    end
    puts '戦争を終了します'
    exit
  end
end

# ゲームの実行
player1 = Player.new('プレイヤー1')
player2 = Player.new('プレイヤー2')
game = WarGame.new(player1, player2)
game.play_game
