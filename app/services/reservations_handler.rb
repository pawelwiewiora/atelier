class ReservationsHandler
  def initialize(user)
    @user = user
  end

  def take(book)
    return  unless book.can_take?(user)

    if book.available_reservation.present?
      book.available_reservation.update_attributes(status: 'TAKEN')
    else
      book.reservations.create(user: user, status: 'TAKEN')
    end
  end

  def give_back(book)
    ActiveRecord::Base.transaction do
      book.reservations.find_by(status: 'TAKEN').update_attributes(status: 'RETURNED')
      book.next_in_queue.update_attributes(status: 'AVAILABLE') if book.next_in_queue.present?
    end
  end

  def reserve(book)
    return unless book.can_reserve?(user)
    book.reservations.create(user: user, status: 'RESERVED')
  end

  def cancel_reservation(book)
    book.reservations.where(user: user, status: 'RESERVED').order(created_at: :asc).first.update_attributes(status: 'CANCELED')
  end 


  private 
  attr_reader :user

  
end
