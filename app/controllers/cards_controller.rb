class CardsController < ApplicationController
  require "payjp"
  before_action :set_card
  def index #CardのデータをPayjpに送って情報を取り出す
    card = current_user.card
    if card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = Rails.application.credentials[:payjp][:payjp_secret_key]
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @card_information = customer.cards.retrieve(@card.card_id)
    end
  end

  def new # カードの登録画面。送信ボタンを押すとcreateアクションへ。
    card = Card.find_by(user_id: current_user.id)
    redirect_to user_path(current_user.id) if card.present?
  end

  def create #PayjpとCardのデータベースを作成えぃt
    Payjp.api_key = Rails.application.credentials[:payjp][:payjp_secret_key]
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      # トークンが正常に発行されていたら、顧客情報をPAY.JPに登録します。
      customer = Payjp::Customer.create(
        description: 'test', # 無くてもOK。PAY.JPの顧客情報に表示する概要です。 
        email: current_user.email,
        card: params['payjp-token'], # 直前のnewアクションで発行され、送られてくるトークンをここで顧客に紐付けて永久保存します。
        metadata: {user_id: current_user.id} # 無くてもOK。
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save!
        redirect_to action: "index"
      else
        redirect_to action: "create"
      end
    end
  end

  def destroy 
    Payjp.api_key = Rails.application.credentials[:payjp][:payjp_secret_key]
    customer = Payjp::Customer.retrieve(@card.customer_id)
    customer.delete
    if @card.destroy #削除に成功した時にポップアップを表示します。
      redirect_to action: "new", notice: "削除しました"
    else #削除に失敗した時にアラートを表示します。
      redirect_to action: "index", alert: "削除できませんでした"
    end
  end
  private

  def set_card
    @card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end
end